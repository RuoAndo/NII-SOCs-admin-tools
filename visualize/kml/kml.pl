#!/usr/bin/perl -w

use DateTime;
my $dt = DateTime->now( time_zone=>'local' );
my $filein = $ARGV[0];

open(FILEHANDLE, $filein);
@list = <FILEHANDLE>;

$counter = 0;

print "\<?xml version=\"1.0\" encoding=\"UTF-8\"?\>\n";

print "<kml xmlns=\"http://www.opengis.net/kml/2.2\"";
print " xmlns:gx=\"http://www.google.com/kml/ext/2.2\"";
print " xmlns:kml=\"http://www.opengis.net/kml/2.2\" ";
print " xmlns:atom=\"http://www.w3.org/2005/Atom\">\n";

print "<Document>\n";
print "<name>";
print $dt->strftime('%Y/%m/%d %H:%M:%S');
print "</name>\n";
print "<Folder>\n";
print "<Style id=\"msn_ylw-pushpin1300\">\n";
print "<IconStyle>\n";
print "<color>ff0000ff</color>\n";
print "<scale>5</scale>\n";
print "</IconStyle>\n";
print "<LabelStyle>\n";
print "<color>ff0000ff</color>\n";
print "<scale>5</scale>\n";
print "</LabelStyle>\n";
print "</Style>\n";

foreach $data (@list)
{

    #@m = split(/,/,$data);        
    @n = split(/,/,$data);        

    #$n[1] =~ s/\s//g;
    #$n[1] =~ s/\"//g;

    $longitude = $n[8];
    $latitude = $n[7];
    $ip = $n[0];
    $city = $n[5];

    #@n = split(/:/,$m[8]);        

    #$n[1] =~ s/\s//g;
    #$n[1] =~ s/\"//g;
    #print "latitude;".$n[1]."\n";
    #$latitude = $n[1];

    #@n = split(/:/,$m[6]);        

    #$n[1] =~ s/\s//g;
    #$n[1] =~ s/\"//g;
    #print "city;".$n[1]."\n";
    #$city = $n[1];

    #@n = split(/:/,$m[3]);        

    #$n[1] =~ s/\s//g;
    #$n[1] =~ s/\"//g;
    #$n[1] =~ s/\./_/g;
    #$n[1] =~ s/\-/_/g;
    #print "version ".$n[1]."\n";
    #$version = $n[1];

    #@n = split(/:/,$m[0]);        

    #$n[1] =~ s/\s//g;
    #$n[1] =~ s/\"//g;
    #$n[1] =~ s/\./_/g;
    #$n[1] =~ s/\-/_/g;
    #print "IP ".$n[1]."\n";
    #$ip = $n[1];

    print "<Placemark>\n";
    print "<name>$city</name>\n";
    print "<description>\n";
    #print "dns version:$version ";
    print "IP:$ip ";
    print "</description>\n";
    print "<styleUrl>\#msn_ylw-pushpin1300</styleUrl>\n";
    print "<Point>\n";
    print "<coordinates>$longitude,$latitude</coordinates>\n";
    print "</Point>\n";
    print "</Placemark>\n";

}

print "</Folder>\n";
print "</Document>\n";
print "</kml>\n";

close(FILEHANDLE);
