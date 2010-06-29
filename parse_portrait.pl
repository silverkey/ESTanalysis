#!/usr/bin/perl
use strict;
use warnings;

my $folder = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_2/PORTRAIT'; # folder containing the portrait output
my $file = 'PORTRAIT_results_on_contigs'; # name of the portrait output
my $noncoding_cutoff = 95;

chdir($folder);
open(IN,$file);

while(my $row = <IN>) {
  next unless $row =~ /^\<Tr\>\<Td.bgcolor\=\#.+\>(.+)\<\/Td\>\<Td bgcolor\=\#.+align\=\"right\"\>(\d+\.\d+)\%\<\/Td\>\<Td.bgcolor\=\#.+.align\=\"right\"\>(\d+\.\d+)\%\<\/Td\>$/;
  my $id = $1;
  my $coding = $2;
  my $noncoding = $3;
  $id =~ s/ //g;
  $coding =~ s/ //g;
  $noncoding =~ s/ //g;
  my $found = '';
  $found .= '<===' if $noncoding >= $noncoding_cutoff;
  print "$id\t$coding\t$noncoding\t$found\n";
}
