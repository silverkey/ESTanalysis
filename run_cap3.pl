#!/usr/bin/perl
use strict;
use warnings;

# SET UP THE VARIABLES CONTAINING THE NAMES OF THE FOLDERS AND THE LOCATIONS OF THE FILES
my $cap3 = '/home/remo/Desktop/POLPO_EST/PROGRAMS/CAP3/cap3'; # cap3 executable
my $fasta_dir = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_2/'; # directory containing the fasta and the quality files - HERE WILL BE SAVED THE RESULTS ALSO
my $fasta = 'SEQs.fa.screen'; # name of the fasta file - THE QUALITY IS TO BE IN THE SAME DIR WITH EXACTLY THE SAME NAME OF THE FASTA PLUS THE .QUAL EXTENSION

# go into directory in which to put results
chdir($fasta_dir);

# launch the analysis
system("$cap3 $fasta \> cap.out");
