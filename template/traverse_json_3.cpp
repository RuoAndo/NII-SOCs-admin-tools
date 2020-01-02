#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include <pthread.h>
#include <alloca.h>
#include "timer.h"

#include <iostream>
#include <fstream>

#include<boost/spirit/include/qi.hpp>
#include <boost/fusion/include/std_pair.hpp>
#include <boost/any.hpp>
#include <boost/tokenizer.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>

#include <boost/algorithm/string.hpp>
#include <boost/filesystem/path.hpp>
#include <boost/filesystem/operations.hpp>
#include <boost/filesystem.hpp>


#include "csv.hpp"

#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"  

#define WORKER_THREAD_NUM (33)
#define MAX_QUEUE_NUM (1024)
#define END_MARK_FNAME   "///"
#define END_MARK_FLENGTH 3

static int ingress_counter_global = 0;
static int egress_counter_global = 0;
static int miss_counter = 0;

typedef struct _tms_string {
    std::string timestamp_string;
    pthread_mutex_t mutex;    
} tms_string_t;
tms_string_t tms_string;

namespace qi = boost::spirit::qi;
namespace ascii = boost::spirit::ascii;

using namespace std;
using namespace tbb;

using namespace tbb;

struct HashCompare {
    static size_t hash( std::string x ) {
    return x.length();
  }
    static bool equal( std::string x, std::string y ) {
    return x==y;
  }
};

typedef concurrent_hash_map<std::string, int, HashCompare> TimeStamp_msec;
static TimeStamp_msec timestamp_msec;    

template<typename Iterator>
struct json_grammar : qi::grammar<Iterator, boost::any(), ascii::space_type>
{
  json_grammar()
    : json_grammar::base_type(element)
  {
    number %= qi::double_;
    date %= qi::lexeme['"' >> (qi::long_ - '/') >> (qi::long_ - '/') >> (qi::long_ - '/') >>
		       (qi::long_ - ':') >> (qi::long_ - ':') >> (qi::long_) >> '"'];

    array %= qi::eps >> '[' >> element % ',' >> ']';
    array2 %= qi::eps >> '[' >> element >> ']';
    
    string %= qi::lexeme['"' >> *(ascii::char_ - '"' | '/' | '-' )>> '"'];
    key_value %= string >> ':' >> element;
    object %= qi::eps >> '{' >> key_value % ',' >> '}';
    element %= array | object | string | number | array2 | date;
  }

  qi::rule<Iterator, std::vector<boost::any>(), ascii::space_type> array;
  qi::rule<Iterator, std::vector<boost::any>(), ascii::space_type> array2;
  qi::rule<Iterator, std::pair<std::string, boost::any>(), ascii::space_type> key_value;
  qi::rule<Iterator, std::map<std::string, boost::any>(), ascii::space_type> object;
  qi::rule<Iterator, std::string(), ascii::space_type> string;
  qi::rule<Iterator, double(), ascii::space_type> number;

  qi::rule<Iterator, boost::any(), ascii::space_type> date;
  qi::rule<Iterator, boost::any(), ascii::space_type> element;
};

typedef struct _result {
    int num;
    char* fname;
    pthread_mutex_t mutex;    
} result_t;
result_t result;

typedef struct _queue {
    char* fname[MAX_QUEUE_NUM];
    int flength[MAX_QUEUE_NUM];
    int rp, wp;
    int remain;
    pthread_mutex_t mutex;
    pthread_cond_t not_full;
    pthread_cond_t not_empty;
} queue_t;

typedef struct _thread_arg {
    int cpuid;
    int thread_id;
    queue_t* q;
    char* srchstr;
    char* dirname;
    char* filelist_name;
    int filenum;
} thread_arg_t;

std::vector<std::string> split_string_2(std::string str, char del) {
  int first = 0;
  int last = str.find_first_of(del);

  std::vector<std::string> result;

  while (first < str.size()) {
    std::string subStr(str, first, last - first);

    result.push_back(subStr);

    first = last + 1;
    last = str.find_first_of(del, first);

    if (last == std::string::npos) {
      last = str.size();
    }
  }

  return result;
}

std::string now_str()
{
  const boost::posix_time::ptime now =
  boost::posix_time::microsec_clock::local_time();
  const boost::posix_time::time_duration td = now.time_of_day();

  const long hours        = td.hours();
  const long minutes      = td.minutes();
  const long seconds      = td.seconds();
  const long milliseconds = td.total_milliseconds() -
    ((hours * 3600 + minutes * 60 + seconds) * 1000);

  char buf[40];
  sprintf(buf, "%02ld:%02ld:%02ld.%03ld",
	  hours, minutes, seconds, milliseconds);

  return buf;
}

int traverse_file(char* filename, char* filelist_name, int thread_id) {

  typedef json_grammar<std::string::const_iterator> Parser;
  Parser p;

  int linecounter = 0;

  int counter = 0;
  int addr_counter = 0;
  int netmask;
  std::map <int,int> found_flag;
  std::map <int,int> found_flag_2;
  
  const string list_file = string(filelist_name); 
  vector<vector<string>> list_data; 
    	
  try {
    Csv objCsv(list_file);
    if (!objCsv.getCsv(list_data)) {
      cout << "read ERROR" << endl;
      return 1;
    }
  }
  catch (...) {
    cout << "EXCEPTION (session)" << endl;
    return 1;
  }
  
  counter = 0;
  for (unsigned int row = 0; row < list_data.size(); row++) {

    vector<string> rec = list_data[row];
    const string argIP = rec[0]; 
    std::string argIPstring;

    netmask = atoi(rec[1].c_str());

    char del2 = '.';
    
    for (const auto subStr : split_string_2(argIP, del2)) {
      unsigned long ipaddr_src;
      ipaddr_src = atol(subStr.c_str());
      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
      std::string trans_string = trans.to_string();
      argIPstring = argIPstring + trans_string;
    }

    /* counting size of file */
    
    ifstream ifs0(filename, ios::in);
    if(!ifs0){
      cerr << "Error: file not opened." << endl;
      return 1;
    }

    linecounter = 0;
  
    string tmp;
    while(getline(ifs0, tmp)){
      linecounter++;
    }

    /* init map */
    
    for(int i = 0; i<linecounter; i++)
      {
	found_flag[i] = 0;
	found_flag_2[i] = 0;
      }

    ////
    
    ifstream ifs(filename, ios::in);
    if(!ifs){
      cerr << "Error: file not opened." << endl;
      return 1;
    }

    linecounter = 0;
    while(getline(ifs, tmp)){
      const std::string str = tmp;
    
      boost::any result;
      if(qi::phrase_parse(str.begin(), str.end(), p, ascii::space, result))
	{
	  std::map<std::string, boost::any> p = boost::any_cast<std::map<std::string, boost::any>>(result);

	  std::string timestamp_string =  boost::any_cast<std::string>(p["capture_time"]);

	  std::string srcIP =  boost::any_cast<std::string>(p["source_ip"]);
	  std::string destIP =  boost::any_cast<std::string>(p["destination_ip"]);
	  
	  //std::cout << srcIP << std::endl;

	  for(size_t c = srcIP.find_first_of("\""); c != string::npos; c = c = srcIP.find_first_of("\"")){
	    srcIP.erase(c,1);
	  }
	
	  for(size_t c = destIP.find_first_of("\""); c != string::npos; c = c = destIP.find_first_of("\"")){
	    destIP.erase(c,1);
	  }
	  
	std::string sessionIPstring;
	for (const auto subStr : split_string_2(srcIP, del2)) {
	  unsigned long ipaddr_src;
	  ipaddr_src = atol(subStr.c_str());
	  std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	  std::string trans_string = trans.to_string();
	  sessionIPstring = sessionIPstring + trans_string;
	}
		
	std::bitset<32> bit_argIP(argIPstring);
	std::bitset<32> bit_sessionIP(sessionIPstring);
	
	std::bitset<32> trans2(0xFFFFFFFF);
	trans2 <<= netmask;
	bit_sessionIP &= trans2;
	
	if(bit_sessionIP == bit_argIP)
	  {
	    std::string all_line;
	    all_line = "1";
	    all_line = all_line + "," + str;
	    found_flag[linecounter] = 1;
	    ingress_counter_global++;
	  }

	std::string sessionIPstring_2;
	for (const auto subStr : split_string_2(destIP, del2)) {
	  unsigned long ipaddr_dest;
	  ipaddr_dest = atol(subStr.c_str());
	  std::bitset<8> trans =  std::bitset<8>(ipaddr_dest);
	  std::string trans_string = trans.to_string();
	  sessionIPstring_2 = sessionIPstring_2 + trans_string;
	}
		
	std::bitset<32> bit_argIP_2(argIPstring);
	std::bitset<32> bit_sessionIP_2(sessionIPstring_2);
	
	std::bitset<32> trans2_2(0xFFFFFFFF);
	trans2_2 <<= netmask;
	bit_sessionIP_2 &= trans2_2;
	
	if(bit_sessionIP_2 == bit_argIP_2)
	  {
	    std::string all_line;
	    all_line = "0";
	    all_line = all_line + "," + str;
	    found_flag_2[linecounter] = 1;
	    egress_counter_global++;
	  }
    
	  /*
	  TimeStamp_msec::accessor a;
	  timestamp_msec.insert(a, timestamp_string);
	  a->second += 1;
	  */

	  if(linecounter%100==0 && linecounter > 10)
	    {
	    std::cout << "[" << now_str() << "] "
		      << "threadID:" << thread_id << ":"
	              << filename << ":" 
		      << linecounter << " lines - done. "
	              << "ingress:" << ingress_counter_global << ":"
		      << "egress:" << egress_counter_global << ":"
		      << endl;
	    }
	  
	}
      
      linecounter++;
      // std::cout << thread_id << ":" << linecounter << std::endl;
    }
    ifs.close();
  }

  /*
  cout << "INGRESS:" << found_flag.size() << endl;
  cout << "EGRESS:" << found_flag_2.size() << endl;
  */  

  int ingress_counter = 0;
  int egress_counter = 0;
    
  for(auto itr = found_flag.begin(); itr != found_flag.end(); ++itr) {
    if(itr->second==1)
      ingress_counter++;
  }
    
  for(auto itr = found_flag_2.begin(); itr != found_flag_2.end(); ++itr) {
    if(itr->second==1)
      egress_counter++;
  }

  boost::filesystem::path full_path(boost::filesystem::current_path());
  cout << full_path << endl;
  boost::filesystem::path dir = full_path.parent_path();
  cout << dir << endl;

  string tmp_filename = string(filename);
  cout << tmp_filename << endl;

  string delim ("/");
  list<string> list_string;
  boost::split(list_string, tmp_filename, boost::is_any_of(delim));
  cout << list_string.back() << endl;
  
  string filename_dst = full_path.string() + "/" + list_string.back() + "_egress";
  cout << filename_dst << endl;
   
  const string file_rendered_outward = string(filename) + "_egress";
  ofstream outputfile_outward(file_rendered_outward);
    
  const string file_rendered_inward = string(filename) + "_ingress";
  ofstream outputfile_inward(file_rendered_inward);

  string tmp;
  linecounter = 0;
  for(int i = 0; i < found_flag.size(); i++)
    {
    const std::string str2 = tmp;
    if(found_flag[linecounter]==1)
      {
	std::string all_line;
	all_line = "1";
	all_line = all_line + "," + str2;
	outputfile_outward << all_line << std::endl;
      }
    if(found_flag_2[linecounter]==1)
      {
	std::string all_line;
	all_line = "1";
	all_line = all_line + "," + str2;
	outputfile_inward << all_line << std::endl;
      }

    linecounter++;
    }

  outputfile_inward.close();
  outputfile_outward.close();

  return 0;
}

void initqueue(queue_t* q) {
    int i;
    q->rp = q->wp = q->remain = 0;
    for (i = 0; i < MAX_QUEUE_NUM; ++i) q->fname[i] = NULL;
    pthread_mutex_init(&q->mutex,    NULL);
    pthread_cond_init(&q->not_full,  NULL);
    pthread_cond_init(&q->not_empty, NULL);
    return;
}

void enqueue(queue_t* q, char* path, int size) {
  
    pthread_mutex_lock(&q->mutex);
    while (q->remain == MAX_QUEUE_NUM) {
        pthread_cond_wait(&q->not_full, &q->mutex);
    }
    char** fname = (char**)&q->fname[q->wp];
    if (*fname != NULL) free(*fname);
    *fname = (char*)malloc(size);
    strcpy(*fname, path);
    q->flength[q->wp] = size;
    q->wp++; q->remain++;

    if (q->wp == MAX_QUEUE_NUM) q->wp = 0;

    pthread_cond_signal(&q->not_empty);
    pthread_mutex_unlock(&q->mutex);
    return;
}

void dequeue(queue_t* q, char** fname, int* flen) {

    pthread_mutex_lock(&q->mutex);
    while (q->remain == 0) 
        pthread_cond_wait(&q->not_empty, &q->mutex);

    *flen  = q->flength[q->rp];
    if (*fname != NULL) free(*fname);
    *fname = (char*)malloc(*flen);
    strcpy(*fname, q->fname[q->rp]);
    q->rp++; q->remain--;
    if (q->rp == MAX_QUEUE_NUM) q->rp = 0;
    pthread_cond_signal(&q->not_full);
    pthread_mutex_unlock(&q->mutex);
    if (strcmp(*fname,"")==0) printf("rp=%d\n", q->rp-1);
    return;
}

int traverse_dir_thread(queue_t* q, char* dirname) {
    static int cnt = 0;
    struct dirent* dent;
    DIR* dd = opendir(dirname);

    if (dd == NULL) {
        printf("Could not open the directory %s\n", dirname); return 0;
    }

    while ((dent = readdir(dd)) != NULL) {
        if (strncmp(dent->d_name, ".",  2) == 0) continue;
        if (strncmp(dent->d_name, "..", 3) == 0) continue;	

        int size = strlen(dirname) + strlen(dent->d_name) + 2;
#if 0
        char* path = (char*)malloc(size);
        sprintf(path, "%s/%s", dirname, dent->d_name);

        struct stat fs;
        if (stat(path, &fs) < 0)
            continue;
        else {
            if (S_ISDIR(fs.st_mode))
                traverse_dir_thread(q, path);
            else if (S_ISREG(fs.st_mode)) {
                enqueue(q, path, size);
                cnt++;
            }
        }
#else
        {
            char* path = (char*)alloca(size);
            sprintf(path, "%s/%s", dirname, dent->d_name);

            struct stat fs;
            if (stat(path, &fs) < 0)
                continue;
            else {
                if (S_ISDIR(fs.st_mode))
                    traverse_dir_thread(q, path);
                else if (S_ISREG(fs.st_mode)) {
                    enqueue(q, path, size);
                    cnt++;
                }
            }
        }
#endif
    }
    closedir(dd);
    return cnt;
}

void master_func(thread_arg_t* arg) {
    queue_t* q = arg->q;
    int i;
    arg->filenum = traverse_dir_thread(q, arg->dirname);
    /* enqueue END_MARK */
    for (i = 0; i < WORKER_THREAD_NUM; ++i) 
        enqueue(q, END_MARK_FNAME, END_MARK_FLENGTH);
    return;
}

void worker_func(thread_arg_t* arg) {
    int flen;
    char* fname = NULL;
    queue_t* q = arg->q;
    char* srchstr = arg->srchstr;

    int thread_id = arg->thread_id;
    char* filelist_name = arg->filelist_name;
    
#ifdef __CPU_SET
    cpu_set_t mask;    
    __CPU_ZERO(&mask);
    __CPU_SET(arg->cpuid, &mask);
    if (sched_setaffinity(0, sizeof(mask), &mask) == -1)
        printf("WARNING: faild to set CPU affinity...\n");
#endif

#if 0
    while (1) {
        int n;

        dequeue(q, &fname, &flen));

        if (strncmp(fname, END_MARK_FNAME, END_MARK_FLENGTH + 1) == 0)
            break;

        n = traverse_file(fname, flielist_name, thread_id);
        pthread_mutex_lock(&result.mutex);

        if (n > result.num) {
            result.num = n;
            if (result.fname != NULL) free(result.fname);
            result.fname = (char*)malloc(flen);
            strcpy(result.fname, fname);
        }
        pthread_mutex_unlock(&result.mutex);
    }
#else
    char* my_result_fname;
    int my_result_num = 0;
    int my_result_len = 0;
    while (1) {
        int n;

        dequeue(q, &fname, &flen);

        if (strncmp(fname, END_MARK_FNAME, END_MARK_FLENGTH + 1) == 0)
            break;

        n = traverse_file(fname, filelist_name, thread_id);

        if (n > my_result_num) {
            my_result_num = n;
            my_result_len = flen;
            my_result_fname = (char*)alloca(flen);
            strcpy(my_result_fname, fname);
        }
    }
    pthread_mutex_lock(&result.mutex);
    if (my_result_num > result.num) {
        result.num = my_result_num;
	if (result.fname != NULL) free(result.fname);
        result.fname = (char*)malloc(my_result_len);
        strcpy(result.fname, my_result_fname);	
    }
    pthread_mutex_unlock(&result.mutex);
#endif
    return;
}

void print_result(thread_arg_t* arg) {
    if (result.num) {
        printf("Total %d files\n", arg->filenum);
        printf("Max include file: %s[include %d]\n", result.fname, result.num);	
    }
    return;
}

int main(int argc, char* argv[]) {
    int i;
    int thread_num = 1 + WORKER_THREAD_NUM;
    unsigned int t, travdirtime;
    queue_t q;
    thread_arg_t targ[thread_num];
    pthread_t master;
    pthread_t worker[thread_num];
    int cpu_num;

    int line_counter = 0;
    
    if (argc != 3) {
      printf("Usage: ./traverse [DIR] list_name \n"); return 0;
    }
    cpu_num = sysconf(_SC_NPROCESSORS_CONF);

    initqueue(&q);

    for (i = 0; i < thread_num; ++i) {
        targ[i].q = &q;
        // targ[i].srchstr = argv[1];
        targ[i].dirname = argv[1];
	targ[i].filelist_name = argv[2];
        targ[i].filenum = 0;
	targ[i].thread_id = i;
        targ[i].cpuid = i%cpu_num;
    }
    result.fname = NULL;

    start_timer(&t);

    pthread_mutex_init(&result.mutex, NULL);

    pthread_create(&master, NULL, (void*)master_func, (void*)&targ[0]);
    for (i = 1; i < thread_num; ++i)
        pthread_create(&worker[i], NULL, (void*)worker_func, (void*)&targ[i]);
	
    for (i = 1; i < thread_num; ++i) 
        pthread_join(worker[i], NULL);

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);

    print_result(&targ[0]);
    for (i = 1; i < thread_num; ++i) {
        if ((targ[i].q)->fname[i] != NULL) free((targ[i].q)->fname[i]);
    }
    if(result.fname != NULL) free(result.fname);

    line_counter = 0;
    for( TimeStamp_msec::iterator i=timestamp_msec.begin(); i!=timestamp_msec.end(); ++i )
      {
	if(line_counter % 10000000 && line_counter > 1)
	    cout << i->first << "," << i->second << endl;

	line_counter++;
      }                         

    return 0;
}
