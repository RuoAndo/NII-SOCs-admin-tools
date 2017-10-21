'''
Created on Oct 21, 2015

For each project tag in a given project, this script will identify the specific information associated with each IP address that
has a system tag.  It will also identify which system tags were added or removed from each IP address since the last run of the script.

@author: JJohnson


'''
import os
import ssl
import sys
import csv
import gzip
import time
import codecs
import cPickle
import urllib2
import argparse
import StringIO
import xlsxwriter
import ConfigParser
import multiprocessing

from netaddr import IPAddress, IPNetwork
from datetime import date, timedelta
from pprint import pprint as pp
from json import loads

from scoutvision import scoutWrapper, Project, Tagging, Tag, AutonomousSystem
from scoutvision import IPAddress as sv_IPA

from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email.MIMEText import MIMEText
from email import Encoders

import smtplib

#Set up some globals
today = date.today()
NUM_THREADS = 10 #The number of multiprocessing threads to use
max_attempts = 5

ssl._create_default_https_context = ssl._create_unverified_context

'''
UTF-16 encoding/decoding
'''
class UnicodeWriter16:
    def __init__(self, f, dialect=csv.excel_tab, encoding="utf-16", **kwds):
        # Redirect output to a queue
        self.queue = StringIO.StringIO()
        self.writer = csv.writer(self.queue, dialect=dialect, **kwds)
        self.stream = f
    
        # Force BOM
        if encoding=="utf-16":
            f.write(codecs.BOM_UTF16)
    
        self.encoding = encoding
    
    def writerow(self, row):
        # Modified from original: now using unicode(s) to deal with e.g. ints
        self.writer.writerow([unicode(s).encode("utf-8") for s in row])
        # Fetch UTF-8 output from the queue ...
        data = self.queue.getvalue()
        data = data.decode("utf-8")
        # ... and reencode it into the target encoding
        data = data.encode(self.encoding)
    
        # strip BOM
        if self.encoding == "utf-16":
            data = data[2:]
    
        # write to the target stream
        self.stream.write(data)
        # empty queue
        self.queue.truncate(0)
    
    def writerows(self, rows):
        for row in rows:
            self.writerow(row)
            
class Recoder(object):
    def __init__(self, stream, decoder, encoder, eol='\r\n'):
        self._stream = stream
        self._decoder = decoder if isinstance(decoder, codecs.IncrementalDecoder) else codecs.getincrementaldecoder(decoder)()
        self._encoder = encoder if isinstance(encoder, codecs.IncrementalEncoder) else codecs.getincrementalencoder(encoder)()
        self._buf = ''
        self._eol = eol
        self._reachedEof = False

    def read(self, size=None):
        r = self._stream.read(size)
        raw = self._decoder.decode(r, size is None)
        return self._encoder.encode(raw)

    def __iter__(self):
        return self

    def __next__(self):
        if self._reachedEof:
            raise StopIteration()
        while True:
            line,eol,rest = self._buf.partition(self._eol)
            if eol == self._eol:
                self._buf = rest
                return self._encoder.encode(line + eol)
            raw = self._stream.read(1024)
            if raw == '':
                self._decoder.decode(b'', True)
                self._reachedEof = True
                return self._encoder.encode(self._buf)
            self._buf += self._decoder.decode(raw)
    next = __next__

    def close(self):
        return self._stream.close()

'''
End UTF-16 encoding/decoding
'''

#pickle and unpickle
#pickle the tag network file
def pickle_file(pickle_file_name, tag_dict):
    with open(pickle_file_name, 'wb') as newPkl:
        cPickle.dump(tag_dict, newPkl)

#unpickle the tag network file
def unpickle_file(pickle_file_name):
    mtf = dict()
    if os.path.isfile(pickle_file_name):
        with open(pickle_file_name, 'r') as savedPkl:
            mtf = cPickle.load(savedPkl)
    else:
        pickle_file(pickle_file_name, mtf)
    return mtf

#load configuration file
def _loadConfig(hConfigFile):
    if not os.path.exists(hConfigFile):
        raise IOError('Config file not found - %s' % hConfigFile)
    config = ConfigParser.RawConfigParser()
    config.read(hConfigFile)
    
    return config.get('ScoutParams', 'filepath'), config.get('ScoutParams', 'baseurl')

#This function was added because there is a limit on the length of a worksheet name in Excel
#Each project tag gets it's own worksheet so we need to make sure that the names are short enough
def load_tag_file(filename):
    projecttags = dict()
    tagnames = dict()
    
    with open(filename, 'rU') as f:
            reader = csv.reader(f)
            for row in reader:
                if row[0] not in projecttags.keys():
                    projecttags[str(row[0]).strip()] = None
                    tagnames[str(row[0]).strip()] = str(row[1]).strip()
    return projecttags, tagnames

def load_desc_file(filename):
    tags = dict()
    
    with open(filename, 'rU') as f:
        reader = csv.reader(f)
        for row in reader:
            if row[0] not in tags.keys():
                tags[str(row[0]).strip()] = str(row[1]).strip()
    
    return tags

#basic csv file reader
def _read_from_csv(filename):
    data = []
    with open(filename, 'rU') as f:
        reader = csv.reader(f)
        try:
            for row in reader:
                if str(row[0]).strip() not in data:
                    data.append(str(row[0]).strip()) 
        except csv.Error, e:
            print'Error reading file %s, line %d: %s' % (filename, reader.line_num, e)
    return data

def load_ip_results(filename):
    data = dict()
    
    with open(filename,'rb') as f:
        sr = Recoder(f, 'utf-16', 'utf-8')
        try:
            for row in csv.reader(sr, delimiter='\t', quotechar='"'):
                if len(row) > 0:
                    raw_data = [x.decode('utf-8') for x in row]
                    data[raw_data[0]] = raw_data[1:]
        except csv.Error, e:
            print 'Error: %s' % e
    
    return data

def get_inherited_tags(s_tag, pid, tag_name, entity_url, exclusion_list):
    tag_dict = dict()
    
    results_obtained = False
    attempts = 1
    while results_obtained == False and attempts <= max_attempts:
        try:
            results = s_tag.view_sub_tag_items(tag_name.encode('utf8'), entity_url, projectid=pid)
            results_obtained = True
        except:
            #print 'Attempt: %s - Error getting inherited tags for %s' % (attempts, tag_name)
            #pp(sys.exc_info()[0])
            time.sleep(10)
        attempts += 1

    if results_obtained == False and attempts > max_attempts:
        print "Could not get inherited tags for %s." % tag_name
    
    if results_obtained:
        if results['tag'] not in exclusion_list:
            if 'ip_address' in results['items'].keys():
                for ip in results['items']['ip_address']:
                    tag_dict[ip['ip_address']['address']] = []
    
    return tag_dict

#This could be multi-threaded to decrease the time required for the script to run
#this might cause poor performance on SV during the script run.
#Would need to implement a managed dictionary to do this.
def get_project_data(config, project, p_tags, ex_list, verbose):
    #set up ScoutVision
    s = scoutWrapper.GetAPISession(config)
    s.verbose = verbose
    sv_project = Project(s)
    sv_tagging = Tagging(s)
    sv_tag = Tag(s)
    
    done = False
    try_count = 1
    
    while not done:
        try:
            sv_project.find_and_set_current(project)
            done = True
        except:
            try_count += 1
            if try_count == 11:
                print 'Could not get set the project: %' % project
                sys.exit()
            time.sleep(10)
    
    if done:
        #we'll need this project ID for later
        p_id = str(sv_project.get_current()['project']['id'])
        
        #get list of project tags in the current project - we'll exclude those from further lookups
        project_tag_list = [t["tag"]["tag"] for t in sv_tagging.summary()]
        
        #get IPs tagged for each project tag
        for tagname in p_tags.keys():
            p_tags[tagname] = dict()
            
            #get summary of tags associated with this project tag - filter out unwanted tags
            results_obtained = False
            attempts = 1
            while results_obtained == False and attempts <= max_attempts:
                try:
                    results = sv_tag.view_sub_tag_items_summary('tag/%s' % tagname, p_id)
                    results_obtained = True
                except:
                    print 'Attempt: %s - Error getting inherited tags for %s' % (attempts, tagname)
                    pp(sys.exc_info()[0])
                    time.sleep(10)
                attempts += 1
            
            #pull the data in to the data structure
            if results_obtained:
                for t_data in results:
                    if t_data['tag'] not in ex_list:
                        if t_data['tag'] not in project_tag_list:
                            p_tags[tagname][t_data['tag']] = dict()
            else:
                print "Could not load the project tag data.  Terminating script."
                sys.exit()
            
            #lookup IPs associated with each system tag remaining
            for system_tag in p_tags[tagname].keys():
                p_tags[tagname][system_tag] = get_inherited_tags(sv_tag, p_id, system_tag, '/tag/%s' % tagname, ex_list)

    else:
        print 'Could not find the project: %s' % project
        s.logout()
        sys.exit()
    
    s.logout()
    
    return p_tags

#The worker class that will save the data from the workers
class Result_Worker(multiprocessing.Process):
    def __init__(self, file_name, queue, verbose):
        super(Result_Worker, self).__init__()
        self.filename = file_name
        self.queue = queue
        self.verbose = verbose
    
    def run(self):
        with open(self.filename, 'wb') as f:
            #writer = csv.writer(f, dialect='excel')
            #writer = UnicodeWriter16(f)
            writer = UnicodeWriter16(f, quoting=csv.QUOTE_ALL)
            data = self.queue.get()
            while data is not None:
                writer.writerow(data)
                data = self.queue.get()
            
            if self.verbose: print 'Data saved, Result worker shutting down....'

def GetCIDRfromIP(s_as, asn, ipAddress):
    #get the announced CIDR from the ASN
    if asn != "":
        try:
            fmtCIDRResp = s_as.announcements(asn)
            #find the smallest CIDR that contains the IP address
            cidr_dict = dict()
            for cidr in fmtCIDRResp:
                cidr_dict[cidr['cidr']['fullvalue']] = IPNetwork(cidr['cidr']['fullvalue'])
                #print 'CIDR block %s added to network' % cidr['cidr']['fullvalue']
            #find the smallest CIDR that contains the IP address
            smallest_cidr = None
            my_ip = IPAddress(ipAddress)
            for cidr in cidr_dict.keys():
                if my_ip in cidr_dict[cidr]:
                    if smallest_cidr == None:
                        smallest_cidr = cidr_dict[cidr]
                    else:
                        if smallest_cidr.size > cidr_dict[cidr].size:
                            smallest_cidr = cidr_dict[cidr]
            return str(smallest_cidr)
        except:
            return ""
    else:
        return ""

#The worker class that will process the data on the work queue
class Worker( multiprocessing.Process ):
    def __init__( self, id_num, config_file, data_queue, results_queue, verbose ):
        super( Worker, self ).__init__()
        self.id_num = id_num
        self.config = config_file
        self.queue = data_queue
        self.results = results_queue
        self.v = verbose
        
    def run( self ):
        #Set up ScoutVision connection
        s = scoutWrapper.GetAPISession(self.config)
        s.verbose = self.v
        sv_ip = sv_IPA( s )
        sv_as = AutonomousSystem( s )
           
        ip = self.queue.get()
        while ip is not None:
            if self.v: print 'Worker: %s --- looking up %s' % (self.id_num, ip)
            try:
                result = sv_ip.overview(ip)
                if "autonomous_system" in result.keys():
                    asn = result["autonomous_system"]["number"]
                    asn_o = result["autonomous_system"]["owner"]
                else:
                    asn = ''
                    asn_o = ''
                cidr = GetCIDRfromIP(sv_as, asn, ip)
                if "location" in result.keys():
                    lon = result["location"]["coordinates"][0]
                    lat = result["location"]["coordinates"][1]
                else:
                    lat = ''
                    lon = ''
                
                ip_data = [ip, asn, asn_o, cidr, lat, lon]
            except:
                ip_data = [ip,'','','','','']
            if self.v: print '%s   -->  %s' % (ip, ip_data)
            
            self.results.put(ip_data) 
            ip = self.queue.get()
        #close SV connection
        s.logout()

def getCidrOwner( burl, ip ):
    try:
        page = urllib2.urlopen( "%s/ip/%s" % ( burl, ip ) ).read()
        cidrs = page.split( "<li><strong>Unannounced Cidrs</strong></li>" )[1] \
                .split( "</ul>" )[0] \
                .strip( " \r\n\t" ) \
                .split( "<ul class=\"cidrs\">")[1] \
                .split( "</li>" )
    except:
        return {}
    
    cidr_dict = { }
    for c in cidrs:
        try:
            cidr = c.split( "</a>" )[0].split( "\">" )[1]
            owner = c.split( "</a>" )[1]
            cidr_dict[cidr] = owner
        except IndexError:
            pass
    
    return cidr_dict

def GetCIDRfromIP2(burl, s_as, asn, cidr_dict, ipAddress):
    #get the announced CIDR from the ASN
    if asn != "":
        #try:
        if cidr_dict is None:
            cidr_dict = dict()
            fmtCIDRResp = s_as.announcements(asn)
            #find the smallest CIDR that contains the IP address
            for cidr in fmtCIDRResp:
                cidr_dict[cidr['cidr']['fullvalue']] = dict()
                cidr_dict[cidr['cidr']['fullvalue']]['network'] = IPNetwork(cidr['cidr']['fullvalue'])
                cidr_dict[cidr['cidr']['fullvalue']]['owner'] = None
        #find the smallest CIDR that contains the IP address
        smallest_cidr = None
        my_ip = IPAddress(ipAddress)
        for cidr in cidr_dict.keys():
            if my_ip in cidr_dict[cidr]['network']:
                if smallest_cidr == None:
                    smallest_cidr = cidr_dict[cidr]['network']
                else:
                    if smallest_cidr.size > cidr_dict[cidr]['network'].size:
                        smallest_cidr = cidr_dict[cidr]['network']
        #find the CIDR owner
        if cidr_dict[str(smallest_cidr)]['owner'] is None:
            #print 'CIDR owner is not in the dictionary'
            cidr_dict[str(smallest_cidr)]['owner'] = getCidrOwner( burl, ipAddress )
        #else:
        #    print 'Already have CIDR'
            
        #return the smallest owned cidr that the IP address fits in
        if len(cidr_dict[str(smallest_cidr)]['owner']) == 0:
            return str(smallest_cidr), "Unknown", cidr_dict
        smallest_owned_cidr = None
        for owner in cidr_dict[str(smallest_cidr)]['owner'].keys():
            if my_ip in IPNetwork(owner):
                if smallest_owned_cidr == None:
                    smallest_owned_cidr = IPNetwork(owner)
                else:
                    if smallest_owned_cidr.size > IPNetwork(owner).size:
                        smallest_owned_cidr = IPNetwork(owner)
        return str(smallest_owned_cidr), str(cidr_dict[str(smallest_cidr)]['owner'][str(smallest_owned_cidr)]).strip(), cidr_dict
        #except:
        #    return "","", None
    else:
        return "","", None

def worker2(id_num, config_file, baseurl, data_queue, results_queue, as_dict, verbose):
    #Set up ScoutVision connection
    s = scoutWrapper.GetAPISession(config_file)
    s.verbose = verbose
    sv_ip = sv_IPA( s )
    sv_as = AutonomousSystem( s )
       
    ip = data_queue.get()
    while ip is not None:
        if verbose: print 'Worker: %s --- looking up %s' % (id_num, ip)
        try:
            result = sv_ip.overview(ip)
            if "autonomous_system" in result.keys():
                asn = result["autonomous_system"]["number"]
                asn_o = result["autonomous_system"]["owner"]
            else:
                asn = ''
                asn_o = ''
            #cidr = GetCIDRfromIP(sv_as, asn, ip)
            #Add CIDR information
            if asn in as_dict.keys():
                #print 'ASN is in the dictionary'
                CIDR, CIDR_owner, asn_result = GetCIDRfromIP2(baseurl, sv_as, asn, as_dict[asn], ip)
            else:
                #print 'ASN %s is not in the dictionary' % asn
                CIDR, CIDR_owner, asn_result = GetCIDRfromIP2(baseurl, sv_as, asn, None, ip)
                if asn_result is not None:
                    as_dict[asn] = asn_result
            if "location" in result.keys():
                lon = result["location"]["coordinates"][0]
                lat = result["location"]["coordinates"][1]
            else:
                lat = ''
                lon = ''
            
            ip_data = [ip, asn, asn_o, CIDR, CIDR_owner, lat, lon]
        except:
            ip_data = [ip,'','','','','','']
        if verbose: print '%s   -->  %s' % (ip, ip_data)
        
        results_queue.put(ip_data) 
        ip = data_queue.get()
    #close SV connection
    s.logout()

def create_ip_set2(mp_tag_dict):
    ip_set = set()
    
    for action in mp_tag_dict.keys(): 
        for p_key in mp_tag_dict[action].keys():
            for s_key in mp_tag_dict[action][p_key].keys():
                for ip in mp_tag_dict[action][p_key][s_key]:
                    ip_set.add(ip)
    
    return ip_set

#multi-threaded methods to pull IP overview information from SV
def lookup_detailed_data2(config_file, project_name, mp_tag_dict, verbose):
    output_filename = '%s_temp_ip_data_results.csv' % project_name
    fp, baseurl = _loadConfig(config_file)
    
    #We're going to use multiple workers to speed this process up
    #Set up queues and work structures
    manager = multiprocessing.Manager()
    result_queue = multiprocessing.Queue()
    work_queue = multiprocessing.Queue()
    asn_dict = manager.dict()
    
    #create and start workers
    result_worker = Result_Worker(output_filename, result_queue, verbose)
    result_worker.start()
    threads = []
    for i in range(NUM_THREADS):
        threads.append(multiprocessing.Process(target = worker2, args=(i, config_file, baseurl, work_queue, result_queue, asn_dict, verbose)))
        #threads.append( Worker( i, config_file, work_queue, result_queue, verbose ) )
        threads[i].start()
    
    #put all the data on the queue for processing
    for ip in create_ip_set2(mp_tag_dict):
        work_queue.put(ip)
    
    #queue a shutdown for each thread
    for i in range(NUM_THREADS):
        work_queue.put(None)
    
    #wait for all of the threats to finish getting their data
    for t in threads:
        t.join()
    
    #close the results queue
    result_queue.put( None )
    result_worker.join()    
    
    return load_ip_results(output_filename)

def find_diff(dict1, dict2):
    result_dict = dict()
    
    #need to determine if tags were added or removed from the data set for today and yesterday
    for p_tag in dict1.keys():
        if p_tag in dict2.keys():
            for s_tag in dict1[p_tag].keys():
                if s_tag in dict2[p_tag].keys():
                    for ip in dict1[p_tag][s_tag].keys():
                        if ip in dict2[p_tag][s_tag].keys():
                            pass
                        else:
                            try:
                                result_dict[p_tag][s_tag][ip] = dict1[p_tag][s_tag][ip]
                            except:
                                try:
                                    result_dict[p_tag][s_tag] = dict()
                                    result_dict[p_tag][s_tag][ip] = dict1[p_tag][s_tag][ip]
                                except:
                                    result_dict[p_tag] = dict()
                                    result_dict[p_tag][s_tag] = dict()
                                    result_dict[p_tag][s_tag][ip] = dict1[p_tag][s_tag][ip]
                else:
                    try:
                        result_dict[p_tag][s_tag] = dict1[p_tag][s_tag]
                    except:
                        result_dict[p_tag] = dict()
                        result_dict[p_tag][s_tag] = dict1[p_tag][s_tag]
        else:
            result_dict[p_tag] = dict1[p_tag]
    return result_dict

#Now we assemble all the data parts we have
def do_the_monster_mash(previous_tags, current_tags):
    result_dict = {'added':{}, 'removed': {}}
    
    #need to determine if tags were added or removed from the data set for today and yesterday
    result_dict['removed'] = find_diff(previous_tags, current_tags)
    result_dict['added'] = find_diff(current_tags, previous_tags)
    
    return result_dict

def get_ip_details(config, project_name, mp_tags, skip, verbose):
    ip_deets_file = '%s_detailed_ip_data.pkl' % project_name
    if skip:
        ip_detailed_data = unpickle_file(ip_deets_file)
    else:
        ip_detailed_data = lookup_detailed_data2(config, project_name, mp_tags, verbose)
        pickle_file(ip_deets_file, ip_detailed_data)
    
    #match up detailed data for IPs
    for action in mp_tags.keys():
        for ptag in mp_tags[action].keys():
            for stag in mp_tags[action][ptag].keys():
                for ip in mp_tags[action][ptag][stag].keys():
                    try:
                        mp_tags[action][ptag][stag][ip] = ip_detailed_data[ip]
                    except:
                        mp_tags[action][ptag][stag][ip] = [ip,'','','','','','']
    
    return mp_tags

def get_source(tag_name):
    if '[' in tag_name:
        return tag_name.split("] ",1)[0].split('[', 1)[-1]
    else:
        return ''

def create_addition_file(filename, datadict, tag_name_dict, verbose):
    with open(filename, 'wb') as f:
        #writer = csv.writer(f, dialect='excel')
        #writer = UnicodeWriter16(f)
        writer = UnicodeWriter16(f, quoting=csv.QUOTE_ALL)
        
        for p_tag in sorted(datadict['added'].keys()):
            for s_tag in sorted(datadict['added'][p_tag].keys()):
                for ip in sorted(datadict['added'][p_tag][s_tag].keys()):
                    writer.writerow([ip, p_tag, s_tag])
        
        if verbose: print 'IPs added data saved...'

def create_xlsx_file(filename, datadict, tag_name_dict, tag_description_file, tag_category_file, verbose):
    header = ['Organization', 'ASN', 'ASN Owner', 'CIDR', 'CIDR Owner','IP', 'Action', 'Latitude', 'Longitude','System Tag','Tag Source']
    summary_header = ['Organization','Added','Removed']
    stats_header = ['Type', 'Entity', 'Owner', 'Added', 'Removed']
    actions = ['added', 'removed']
    p_tag_dict = dict()
    
    #load augmenting data
    tag_descriptions = dict()
    if tag_description_file:
        tag_descriptions = load_desc_file(tag_description_file)
    tag_categories = dict()
    if tag_category_file:
        cat_file = open( tag_category_file, "rb" )
        tag_categories = loads( cat_file.read() )
        cat_file.close()
    
    #create workbook
    book = xlsxwriter.Workbook(filename)
    # Add a bold format to use to highlight cells.
    bold = book.add_format({'bold': True})
    
    #create summary worksheet
    worksheet = book.add_worksheet( "Summary" )
    row = col = 0
    
    if len(tag_categories.keys()) > 0:
        header.append('Tag Category')
    if len(tag_descriptions.keys()) > 0:
        header.append('Tag Description')
    for item in header:
        worksheet.write( row, col, item, bold )
        col += 1
    col += 1
    for item in summary_header:
        worksheet.write( row, col, item, bold )
        col += 1
    
    #Add the data
    row += 1
    summary_stats = dict()
    for action in actions:
        for p_tag in sorted(datadict[action].keys()):
            if p_tag not in summary_stats.keys():
                summary_stats[p_tag] = {'added':0, 'removed':0}
            if p_tag not in p_tag_dict.keys():
                p_tag_dict[p_tag] = []
            for s_tag in sorted(datadict[action][p_tag].keys()):
                for ip in sorted(datadict[action][p_tag][s_tag].keys()):
                    if action == 'added':
                        summary_stats[p_tag][action] += 1
                    else:
                        summary_stats[p_tag][action] -= 1
                    ddata = datadict[action][p_tag][s_tag][ip]
                    values = [p_tag, ddata[0], ddata[1], ddata[2], ddata[3], ip, action, ddata[4], ddata[5], s_tag, get_source(s_tag)]
                    if len(tag_categories.keys()) > 0:
                        try:
                            values.append("|".join(x for x in tag_categories[s_tag]))
                        except:
                            values.append('')
                    if len(tag_descriptions.keys()) > 0:
                        try:
                            values.append(tag_descriptions[s_tag])
                        except:
                            values.append('')
                    col = 0
                    p_tag_dict[p_tag].append(values)
                    for item in values:
                        worksheet.write( row, col, item )
                        col += 1
                    row += 1
    
    #create summary data chart
    #write data
    row = 1
    for p_tag in sorted(summary_stats.keys()):
        values = [p_tag, summary_stats[p_tag]['added'], summary_stats[p_tag]['removed']]
        col = len(header) + 1
        for item in values:
            worksheet.write( row, col, item )
            col += 1
        row += 1
    #create chart
    bar_chart = book.add_chart( { "type" : "column", "subtype": "stacked" } )
    col_start = len(header) + 1
    num_items = len(summary_stats.keys())
    bar_chart.add_series( { "values" : ["Summary", 1, col_start + 1, num_items, col_start + 1],
                            "categories" : ["Summary", 1, col_start, num_items, col_start],
                            "name" : "Added" } )
    bar_chart.add_series( { "values" : ["Summary", 1, col_start + 2, num_items, col_start + 2],
                            "categories" : ["Summary", 1, col_start, num_items, col_start],
                            "name" : "Removed" } )
    bar_chart.set_title( { "name" : "Total System Tags Added and Removed" } )
    worksheet.insert_chart( "C6", bar_chart )
    
    #create a worksheet for each project tag
    col_start += 1
    for p_tag in sorted(p_tag_dict):
        worksheet = book.add_worksheet( tag_name_dict[p_tag] )
        
        #add header row
        row = col = 0
        for item in header:
            worksheet.write( row, col, item, bold )
            col += 1
        
        #write data and gather metrics for charts
        row += 1
        s_tag_totals = dict()
        net_totals = {'asn':{},'cidr':{}}
        for values in p_tag_dict[p_tag]:
            #get system tag metrics
            s_tag = values[9]
            if s_tag not in s_tag_totals.keys():
                s_tag_totals[s_tag] = {'added':0,'removed':0}
            if values[6] == 'added':
                s_tag_totals[s_tag]['added'] += 1
            else:
                s_tag_totals[s_tag]['removed'] += 1
            #get network element metrics
            #get ASN information
            asn = values[1]
            if asn not in net_totals['asn'].keys():
                net_totals['asn'][asn] = {'owner':values[2],'added':0,'removed':0}
            if values[6] == 'added':
                net_totals['asn'][asn]['added'] += 1
            else:
                net_totals['asn'][asn]['removed'] += 1
            #get CIDR information
            cidr = values[3]
            if cidr not in net_totals['cidr'].keys():
                net_totals['cidr'][cidr] = {'owner':values[4],'added':0,'removed':0}
            if values[6] == 'added':
                net_totals['cidr'][cidr]['added'] += 1
            else:
                net_totals['cidr'][cidr]['removed'] += 1
            #write data to the worksheet
            col = 0
            for item in values:
                worksheet.write( row, col, item )
                col += 1
            row += 1
        
        #write the stats to the worksheet
        row = 0
        col = len(header) + 1
        for item in stats_header:
            worksheet.write( row, col, item, bold )
            col += 1
        
        row += 1
        for s_tag in sorted(s_tag_totals.keys()):
            values = ['system tag', s_tag, '', s_tag_totals[s_tag]['added'], s_tag_totals[s_tag]['removed']]
            col = len(header) + 1
            for item in values:
                worksheet.write( row, col, item )
                col += 1
            row += 1
        for net_ent in sorted(net_totals.keys()):
            for entity in sorted(net_totals[net_ent].keys()):
                values = [net_ent, entity, net_totals[net_ent][entity]['owner'], net_totals[net_ent][entity]['added'], net_totals[net_ent][entity]['removed']]
                col = len(header) + 1
                for item in values:
                    worksheet.write( row, col, item )
                    col += 1
                row += 1
        
        #create the stats charts
        #system tags added
        bar_chart = book.add_chart( { "type" : "bar" } )
        bar_chart.add_series( { "values" : ["'%s'" % tag_name_dict[p_tag], 1, col_start + 2, len(s_tag_totals.keys()), col_start + 2],
                                "categories" : ["'%s'" % tag_name_dict[p_tag], 1, col_start, len(s_tag_totals.keys()), col_start],
                                "name" : "Added" } )
        bar_chart.set_title( { "name" : "Total System Tags Added" } )
        bar_chart.set_style(3)
        worksheet.insert_chart( "C6", bar_chart )
        #system tags removed
        bar_chart = book.add_chart( { "type" : "bar" } )
        bar_chart.add_series( { "values" : ["'%s'" % tag_name_dict[p_tag], 1, col_start + 3, len(s_tag_totals.keys()), col_start + 3],
                                "categories" : ["'%s'" % tag_name_dict[p_tag], 1, col_start, len(s_tag_totals.keys()), col_start],
                                "name" : "Removed" } )
        bar_chart.set_title( { "name" : "Total System Tags Removed" } )
        bar_chart.set_style(4)
        worksheet.insert_chart( "L6", bar_chart )
        #create asn charts
        asn_start = len(s_tag_totals.keys()) + 1
        asn_end = asn_start + len(net_totals['asn'].keys()) - 1
        #asn added
        bar_chart = book.add_chart( { "type" : "bar" } )
        bar_chart.add_series( { "values" : ["'%s'" % tag_name_dict[p_tag], asn_start, col_start + 2, asn_end, col_start + 2],
                                "categories" : ["'%s'" % tag_name_dict[p_tag], asn_start, col_start, asn_end, col_start],
                                "name" : "Added" } )
        bar_chart.set_title( { "name" : "System Tags Added to ASN" } )
        bar_chart.set_style(5)
        worksheet.insert_chart( "C22", bar_chart )
        #asn removed
        bar_chart = book.add_chart( { "type" : "bar" } )
        bar_chart.add_series( { "values" : ["'%s'" % tag_name_dict[p_tag], asn_start, col_start + 3, asn_end, col_start + 3],
                                "categories" : ["'%s'" % tag_name_dict[p_tag], asn_start, col_start, asn_end, col_start],
                                "name" : "Removed" } )
        bar_chart.set_title( { "name" : "System Tags Removed from ASN" } )
        bar_chart.set_style(6)
        worksheet.insert_chart( "L22", bar_chart )
        #create cidr charts
        cidr_start = asn_end + 1
        cidr_end = cidr_start + len(net_totals['cidr'].keys()) - 1
        #cidr added
        bar_chart = book.add_chart( { "type" : "bar" } )
        bar_chart.add_series( { "values" : ["'%s'" % tag_name_dict[p_tag], cidr_start, col_start + 2, cidr_end, col_start + 2],
                                "categories" : ["'%s'" % tag_name_dict[p_tag], cidr_start, col_start, cidr_end, col_start],
                                "name" : "Added" } )
        bar_chart.set_title( { "name" : "System Tags Added to CIDR" } )
        bar_chart.set_style(7)
        worksheet.insert_chart( "C38", bar_chart )
        #cidr removed
        bar_chart = book.add_chart( { "type" : "bar" } )
        bar_chart.add_series( { "values" : ["'%s'" % tag_name_dict[p_tag], cidr_start, col_start + 3, cidr_end, col_start + 3],
                                "categories" : ["'%s'" % tag_name_dict[p_tag], cidr_start, col_start, cidr_end, col_start],
                                "name" : "Removed" } )
        bar_chart.set_title( { "name" : "System Tags Removed from CIDR" } )
        bar_chart.set_style(8)
        worksheet.insert_chart( "L38", bar_chart )
    
    #close workbook
    book.close()


def load_email_configuration(file_name):
    data = dict()
    
    if not os.path.exists(file_name):
        raise IOError('Email config file not found - %s' % file_name)
    config = ConfigParser.RawConfigParser()
    config.read(file_name)
    
    data['host'] = config.get('EmailParams', 'host')
    data['subject'] = config.get('EmailParams', 'subject')
    data['message'] = config.get('EmailParams', 'message')
    data['recipients'] = [str(x).strip() for x in str(config.get('EmailParams', 'recipients')).split(',')]
    
    return data

#def zip_files(file_list):
#    zipped_files = []
#    for filename in file_list:
#        with gzip.open( '%s.gz' % filename, "wb" ) as zip_out, open( filename, "rb" ) as file_in:
#            zip_out.writelines( file_in )
#        zipped_files.append('%s.gz' % filename)
#    return zipped_files

def send_mail( msg_to, msg_from, subject=None, text="", files=[], verbose = False ):
    if subject is None:
        subject = "Files from %s" % msg_from
    
    host = "localhost"
    port = 25
    server = smtplib.SMTP( host, port )
    
    msg = MIMEMultipart()
    msg["Subject"] = subject 
    msg["From"] = msg_from
    msg["To"] = ", ".join( i for i in msg_to )
    msg["CC"] = ""
    
    if not text == "": msg.attach( MIMEText( text ) )

    for f in files:
        if verbose: print "[+] Attaching %s" % f
        attachment_in = open( f, "rb" )
        attachment = MIMEBase( "application", "octet-stream" )
        attachment.set_payload( attachment_in.read() )
        Encoders.encode_base64( attachment )
        attachment.add_header( "Content-Type", "multipart/mixed", name=f )
        attachment.add_header( "Content-Disposition", "attachment", filename=str(f).split('/')[-1:][0] )
        
        msg.attach( attachment )
        if verbose: print "[+] File attached"
        
        attachment_in.close()
    
    if verbose: print "[+] Sending email..."
    
    server.sendmail( msg_from, msg_to, msg.as_string() )
    if verbose: print "[+] Email sent"
        
    server.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Script that will identify specific information for IPs tagged in a project.')
    parser.add_argument('hostConfigFile', help='The host config file with baseurls, apiurls, usernames and passwords defined.')
    parser.add_argument('project', help='The SV project to pull tag data from.')
    parser.add_argument('tag_file', help='A csv file with a list of project tags to use.')
    parser.add_argument('-sl', action='store_true', default=False, dest='skip_load',help='Run the script without downloading new data from SV.')
    parser.add_argument('-np', action='store_true', default=False, dest='no_proxy',help='Disables use of detected proxy settings.')
    parser.add_argument('-s', action='store_true', default=False, dest='store_old', help='Store the old SV ip_tag_report files')
    parser.add_argument('-v', action='store_true', default=False, dest='verbose', help='print messages to stdout')
    parser.add_argument('-z', action='store_true', default=False, dest='zipup_files', help='zip output files before emailing')
    parser.add_argument('-td', default=None, dest='tag_descriptions', help='A CSV file containing system tag descriptions to append to the output.')
    parser.add_argument('-tc', default=None, dest='tag_categories', help='A CSV file containing system tag categories to append to the output.')
    parser.add_argument('-e', default=None, dest='email_output', help='The email config file with host, subject, message and recipients defined.')
    parser.add_argument('-tx', default=None, dest='exclude', help='A CSV file containing a list of system tags to exclude from the report.')
    args = parser.parse_args()
    if args.verbose: print args
    if args.no_proxy: urllib2.getproxies = lambda: { }

    #set up the files
    file_path, base_url = _loadConfig(args.hostConfigFile)
    #file_path = "/home/soliton/api/local/nii/daily_report/" 
    p_name = str(args.project).replace(' ','_').replace('\'', '').replace('.','')
    today_filename = os.path.join(file_path, "%s_ip_tag_report_%s.pkl" % (p_name, today))
    yesterday_file = os.path.join(file_path, "%s_ip_tag_report_%s.pkl" % (p_name, today - timedelta(days=1)))
    yesterday_yesterday_file = os.path.join(file_path, "%s_ip_tag_report_%s.pkl" % (p_name, today - timedelta(days=2)))
    today_xl_file = os.path.join(file_path, "%s_ip_tag_report_%s.xlsx" % (p_name, today))
    todays_additions_file = os.path.join(file_path, "%s_ip_tag_additions_%s.csv" % (p_name, today))
    yesterday_yesterday_add_file = os.path.join(file_path, "%s_ip_tag_additions_%s.csv" % (p_name, today - timedelta(days=2)))
    yesterday_yesterday_xl_file = os.path.join(file_path, "%s_ip_tag_report_%s.xlsx" % (p_name, today - timedelta(days=2)))
    
    #load the project tag file
    project_tags = dict()
    if os.path.exists(args.tag_file):
        project_tags, tag_names = load_tag_file(args.tag_file)
    else:
        print 'Could not locate the tag file: %s' % args.tag_file
        sys.exit()
    
    #load the system tag exclusion file
    exclusions = []
    if args.exclude:
        exclusions = _read_from_csv(args.exclude)
    
    #get the project data
    if args.skip_load:
        project_tags = unpickle_file(today_filename) 
    else:
        project_tags = get_project_data(args.hostConfigFile, args.project, project_tags, exclusions, args.verbose)
        pickle_file(today_filename, project_tags)
   
    #Figure out what has changed since yesterday
    mashed_data = do_the_monster_mash(unpickle_file(yesterday_file), project_tags)
    
    #Look up detailed information about the mashed data
    mashed_data = get_ip_details(args.hostConfigFile, p_name, mashed_data, args.skip_load, args.verbose)
    
    #Create the output files
    create_xlsx_file(today_xl_file, mashed_data, tag_names, args.tag_descriptions, args.tag_categories, args.verbose)
    create_addition_file(todays_additions_file, mashed_data, tag_names, args.verbose)
    
    #Email the results
    #file_list = [today_xl_file, todays_additions_file]
    #if args.email_output:
        #zip files
    #    if args.zipup_files:
    #        file_list = zip_files(file_list)
    #    email_config = load_email_configuration(args.email_output)
    #    send_mail( email_config['recipients'], email_config['host'], 
    #               '%s' % email_config['subject'], 
    #               '%s' % email_config['message'], 
    #               file_list )
    
    #clean up files
    if not args.store_old:
        #remove the old tag data file
        if os.path.exists(yesterday_yesterday_file):
            os.remove(yesterday_yesterday_file)
            if args.verbose: print 'Removed file %s' % yesterday_yesterday_file
        #remove the old Excel file
        if os.path.exists(yesterday_yesterday_xl_file):
            os.remove(yesterday_yesterday_xl_file)
            if args.verbose: print 'Removed file %s' % yesterday_yesterday_xl_file
        #remove the old CSV file
        if os.path.exists(yesterday_yesterday_add_file):
            os.remove(yesterday_yesterday_add_file)
            if args.verbose: print 'Removed file %s' % yesterday_yesterday_add_file
    
    
