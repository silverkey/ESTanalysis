#!/usr/bin/perl
use strict;
use warnings;

BEGIN {
  $ENV{BLASTDIR} = '/Users/Remo/Desktop/EST_ANALYSIS/blast-2.2.23/bin';
  $ENV{PHRED_PARAMETER_FILE} = '/Users/Remo/Desktop/EST_ANALYSIS/PHRED_PHRAP/phred-dist-020425.c-acd/phredpar.dat';
}

# SET UP THE VARIABLES CONTAINING THE NAMES OF THE FOLDERS AND THE LOCATIONS OF THE FILES
my $phred = '/Users/Remo/Desktop/EST_ANALYSIS/PHRED_PHRAP/phred-dist-020425.c-acd/phred'; # location of phred executable
my $chromas_dir = '/Volumes/PACKY/POLPO_EST/ALL_ESTs'; # location of chromatograms
my $phds_dir = '/Volumes/PACKY/POLPO_EST/ALL_ESTs'; # location where you want to save the .phd files
my $res_dir = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_2/'; # location where you want to save the log, the fasta and the quality files

# go into directory in which to put results
chdir($res_dir);

# launch the analysis
system("$phred -id $chromas_dir -sa SEQs.fa -qa SEQs.fa.qual -qr SEQs.fa.stat -pd $phds_dir -trim_alt \"\" -trim_out -log");

