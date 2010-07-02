#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

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
######system("perl seqtrim.pl -C -v -f $seqs_dir$fasta -q $seqs_dir$qual --saveTrimmed $out_dir$out --outputRaw $out_dir$out\.bin --arrange qnc");

# Need a workaround to generate real fasta and quality file from the seqtrim output
# The program infact generate a fake fasta and quality file with the id on one line and the seq on a single subsequent line

chdir($out_dir);

work_around($out);
work_around_qual("$out\.qual");

sub work_around {
  my $file = shift;
  my $io = Bio::SeqIO->new(-file => ">mod_$file",
                           -format => 'fasta');
  open(IN,$file);
  my $id;
  my $s;
  my $desc;
  my @desc;
  my $seq;
  my $first = 0;
  while(my $row = <IN>) {
    chomp($row);
    if($row =~ /^\>/ && $first) {
      $id =~ s/\>//;
      $seq = Bio::Seq->new(-id => $id,
                           -desc => $desc,
                           -seq => $s);
      $io->write_seq($seq);
      undef($id);
      undef($desc);
      undef(@desc);
      undef($s);
      undef($seq);
      ($id,@desc) = split(/ /,$row);
      $desc = join(" ",@desc);
    }
		elsif($row =~ /^\>/) {
      ($id,@desc) = split(/ /,$row);
      $desc = join(" ",@desc);
    }
    elsif($row =~ /^\w+/) {
      $s .= $row;
      $first ++;
    }
  }
  $id =~ s/\>//;
  $seq = Bio::Seq->new(-id => $id,
                       -desc => $desc,
                       -seq => $s);
  $io->write_seq($seq);
}

sub work_around_qual {
  my $file = shift;
  my $io = Bio::SeqIO->new(-file => ">mod_$file",
                           -format => 'qual');
  open(IN,$file);
  my $id;
  my $s;
  my $desc;
  my @desc;
  my $seq;
  my $first = 0;
  while(my $row = <IN>) {
    chomp($row);
    if($row =~ /^\>/ && $first) {
      $id =~ s/\>//;
      $seq = Bio::Seq::PrimaryQual->new(-id => $id,
                                        -qual => $s);
      $io->write_seq($seq);
      undef($id);
      undef($desc);
      undef(@desc);
      undef($s);
      undef($seq);
      ($id,@desc) = split(/ /,$row);
      $desc = join(" ",@desc);
    }
		elsif($row =~ /^\>/) {
      ($id,@desc) = split(/ /,$row);
      $desc = join(" ",@desc);
    }
    elsif($row =~ /^\w+/) {
      $s .= $row;
      $first ++;
    }
  }
  $id =~ s/\>//;
  $seq = Bio::Seq::PrimaryQual->new(-id => $id,
                                    -qual => $s);
  $io->write_seq($seq);
}

