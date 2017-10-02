#!/usr/bin/perl -w

my $filein1 = $ARGV[0];
open(FILEHANDLE1, $filein1);
@list1 = <FILEHANDLE1>;;
@list1 = sort { (split(/\_/,$a))[2] <=> (split(/\_/,$b))[2] } @list1;
print reverse(reverse((@list1)));

close(FILEHANDLE1);
close(OUT1);
