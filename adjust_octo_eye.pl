#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

# SET UP THE VARIABLES CONTAINING THE NAMES OF THE FOLDERS AND THE LOCATIONS OF THE FILES
my $seqs_dir = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/BLAST_DB/OctEye/NEW/';
my $fasta = 'OctEye_NR.seq';

chdir($seqs_dir);

system("mac2unix $fasta");

work_around();

sub work_around {
  my $io = Bio::SeqIO->new(-file => ">$fasta\.fasta",
                           -format => 'fasta');
  open(IN,$fasta);
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
      $s =~ s/X/N/g;
      $first ++;
    }
  }
  $id =~ s/\>//;
  $seq = Bio::Seq->new(-id => $id,
                       -desc => $desc,
                       -seq => $s);
  $io->write_seq($seq);
}
