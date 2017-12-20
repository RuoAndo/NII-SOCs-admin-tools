#!/usr/bin/perl -w

# sent
my $filein1 = $ARGV[0];
open(FILEHANDLE1, $filein1);
@list1 = <FILEHANDLE1>;;
@list1 = sort { (split(/\,/,$a))[3] <=> (split(/\,/,$b))[3] } @list1;
print reverse((@list1));

# recv
my $filein1 = $ARGV[0];
open(FILEHANDLE1, $filein1);
@list1 = <FILEHANDLE1>;;
@list1 = sort { (split(/\,/,$a))[4] <=> (split(/\,/,$b))[4] } @list1;
print reverse((@list1));

close(FILEHANDLE1);
close(OUT1);
