#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

my $folder = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_2/PORTRAIT'; # name of the folder containing the fasta
my $fasta = 'singlets_for_portraits.fa'; # name of the fasta to change

# go into the directory
chdir($folder);

my $in = Bio::SeqIO->new(-file => $fasta,
                         -format => 'fasta');

my $out = Bio::SeqIO->new(-file => ">$fasta\.N",
                          -format => 'fasta');

while(my $seq = $in->next_seq) {
  my $string = $seq->seq;
	$string =~ s/X/N/g;
	$seq->seq($string);
	$out->write_seq($seq);
}

# change also the quality
system("cp $fasta\.qual $fasta\.N\.qual");
