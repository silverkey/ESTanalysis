#!/usr/bin/perl
use strict;
use warnings;

# SET UP THE VARIABLES CONTAINING THE NAMES OF THE FOLDERS AND THE LOCATIONS OF THE FILES
my $cap3 = '/home/remo/Desktop/POLPO_EST/PROGRAMS/CAP3/cap3'; # cap3 executable
my $fasta_dir = '/media/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/3_DB/'; # directory containing the fasta and the quality files - HERE WILL BE SAVED THE RESULTS ALSO
my $fasta = 'clone.fa'; # name of the fasta file - THE QUALITY IS TO BE IN THE SAME DIR WITH EXACTLY THE SAME NAME OF THE FASTA PLUS THE .QUAL EXTENSION
my $res_dir = '/media/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/4_CAP3/'; # directory in which to run

# go into directory with the fasta
chdir($fasta_dir);

# launch the analysis
system("$cap3 $fasta \> cap.out");

# mv the results to the results directory
system("mv \*\.cap\.\* $res_dir");
