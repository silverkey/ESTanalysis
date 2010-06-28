#!/usr/bin/perl
use strict;
use warnings;

BEGIN {
	$ENV{BLASTDIR} = '/Users/Remo/Desktop/EST_ANALYSIS/blast-2.2.23/bin'; 
}

# SET UP THE VARIABLES CONTAINING THE NAMES OF THE FOLDERS AND THE LOCATIONS OF THE FILES
my $blast_dir = '/Users/Remo/Desktop/EST_ANALYSIS/blast-2.2.23/';
my $seqtrim_dir = '/Users/Remo/Desktop/EST_ANALYSIS/seqtrim/';
my $seqs_dir = '/Volumes/PACKY/POLPO_EST/ALL_ESTs/';
my $fasta = 'SEQs.fa';
my $qual = 'SEQs.qual';
my $out = 'SEQs.trimmed';

chdir($seqtrim_dir);

# update the database
system("perl seqtrim.pl -u");

# better order to run the analysis:
# q => quality filter
# n => N filter
# v => vector filter
# c => contamination filter
system("perl seqtrim.pl -C -v -f $seqs_dir$fasta -q $seqs_dir$qual --saveTrimmed $seqs_dir$out --outputRaw $seqs_dir$out\.bin --arrange qnvc");

chdir($seqs_dir);
system("cp $out $out\.fa");
