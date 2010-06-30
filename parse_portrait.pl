#!/usr/bin/perl
use strict;
use warnings;

my $folder = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_2/PORTRAIT/APLYSIA'; # folder containing the portrait output
my $file = 'portrait_out.html'; # name of the portrait output
my $noncoding_cutoff = 0.01;

chdir($folder);
open(IN,$file);

while(my $row = <IN>) {
	# The next line function only if you save the html file from the firefox under mac
  next unless $row =~ /^\<Tr\>\<Td.bgcolor\=\#.+\>(.+)\<\/Td\>\<Td bgcolor\=\#.+align\=\"right\"\>(\d+\.\d+)\%\<\/Td\>\<Td.bgcolor\=\#.+.align\=\"right\"\>(\d+\.\d+)\%\<\/Td\>$/;
  my $id = $1;
  my $coding = 1 - ($2 / 100);
  my $noncoding = 1 - ($3 / 100);
  $id =~ s/ //g;
  $coding =~ s/^(\d+\.\d\d\d\d)\d+$/$1/;
  $noncoding =~ s/^(\d+\.\d\d\d\d)\d+$/$1/;
  my $found = 'N';
  $found = 'Y' if $noncoding <= $noncoding_cutoff;
  print "$id\t$coding\t$noncoding\t$found\n";
}
