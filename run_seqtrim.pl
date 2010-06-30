#!/usr/bin/perl
use strict;
use warnings;

BEGIN {
  $ENV{BLASTDIR} = '/Users/Remo/Desktop/EST_ANALYSIS/blast-2.2.23/bin'; 
}

# SET UP THE VARIABLES CONTAINING THE NAMES OF THE FOLDERS AND THE LOCATIONS OF THE FILES
my $blast_dir = '/Users/Remo/Desktop/EST_ANALYSIS/blast-2.2.23/';
my $seqtrim_dir = '/Users/Remo/Desktop/EST_ANALYSIS/seqtrim/';
my $seqs_dir = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/4_CAP3/';
my $fasta = 'unique.fa';
my $qual = 'unique.fa.qual';
my $out_dir = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/5_SEQTRIM/'; # directory where to save the output
my $out = 'unique.trimmed.fa';

chdir($seqtrim_dir);

# update the database
system("perl seqtrim.pl -u");

# better order to run a complete analysis:
# q => quality filter
# n => N filter
# v => vector filter
# c => contamination filter
# system("perl seqtrim.pl -C -v -f $seqs_dir$fasta -q $seqs_dir$qual --saveTrimmed $seqs_dir$out --outputRaw $seqs_dir$out\.bin --arrange qnvc");

# to run a partial analysis after the cap3:
# q => quality filter
# n => N filter
# c => contamination filter
system("perl seqtrim.pl -C -v -f $seqs_dir$fasta -q $seqs_dir$qual --saveTrimmed $out_dir$out --outputRaw $out_dir$out\.bin --arrange qnc");

# Need a workaround to generate real fasta and quality file from the seqtrim output
# The program infact generate a fake fasta and quality file with the id on one line and the seq on a single subsequent line

