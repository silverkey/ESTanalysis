#!/usr/bin/perl
use strict;
use warnings;

# SET UP THE VARIABLES CONTAINING THE NAMES OF THE FOLDERS AND THE LOCATIONS OF THE FILES
my $cross_match = '/Users/Remo/Desktop/EST_ANALYSIS/PHRED_PHRAP/distrib/cross_match'; # location of the cross_match executable
my $fasta_file = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_2/SEQs.fa'; # location of the fasta and quality files
my $vector_file = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/pSPORT1_Sfi.fa'; # location of the vector file
my $res_dir = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_2'; # location where to save the results

# go into the results directory
chdir($res_dir);

# launch the analysis
system("$cross_match $fasta_file $vector_file -minmatch 10 -minscore 20 -screen > SEQs.fa.crossm");
