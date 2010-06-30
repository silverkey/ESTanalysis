#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use DBD::Sqlite;
use Bio::Assembly::IO;
use Bio::SeqIO;
use Bio::Seq;
use Bio::Seq::PrimaryQual;

use lib '/Users/Remo/src/bioperl-live/';

use Data::Dumper;

my $ACE_FOLDER = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/4_CAP3/'; # directory containing the .ace file
my $ACE = 'clone.fa.cap.ace'; # name of the .ace file
my $DB_FOLDER = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/3_DB/'; # folder containing the sqlite db
my $DB = 'OCTO_EST_3'; # name of the sqlite db

my $BASENAME = "$ACE";
$BASENAME =~ s/\.ace//;
my $CONTIG_FA = "$BASENAME\.contigs";
my $CONTIG_QUAL = "$BASENAME\.contigs.qual";
my $SINGLET_FA = "$BASENAME\.singlets";
my $TABNAME = "cap3";

chdir($DB_FOLDER);
my $DBH = DBI->connect("dbi:SQLite:dbname=$DB","","");

chdir($ACE_FOLDER);

my $UNIQUE_FA = Bio::SeqIO->new(-file => ">unique.fa",
                                -format => 'fasta');
my $UNIQUE_QUAL = Bio::SeqIO->new(-file => ">unique.fa.qual",
                                  -format => 'qual');

write_contig_seq_on_fasta();

write_contig_quality_on_fasta();

create_table();

populate_table();

get_singlets();

sub create_table {
  $DBH->do(qq{
    CREATE TABLE $TABNAME(
    contig_id VARCHAR KEY,
    clone_id INTEGER KEY)
  });
}

sub write_contig_seq_on_fasta {
  my $in = Bio::SeqIO->new(-file => $CONTIG_FA,
                           -format => 'fasta');
  while(my $seq = $in->next_seq) {
    my $string = $seq->seq;
    $string =~ s/[Xx]/N/g;
    $seq->seq($string);
	  $UNIQUE_FA->write_seq($seq);
  }
}

sub write_contig_quality_on_fasta {
  my $in = Bio::SeqIO->new(-file => $CONTIG_QUAL,
                           -format => 'qual');
  while(my $seq = $in->next_seq) {
    $UNIQUE_QUAL->write_seq($seq);
  }
}

sub populate_table {
  my $IO = Bio::Assembly::IO->new(-file => $ACE,
                                  -format => 'ace');

	my $sth = $DBH->prepare_cached(qq{
    INSERT INTO $TABNAME
    (contig_id,clone_id)
    VALUES (?,?)
  });

  while(my $contig = $IO->next_contig) {
    my $contig_id = $contig->id;

    # Alternative ways to have sequences from the ace
    # We do not use it because in any case we will have to parse the fasta
    # containing the singlets given that cap3 does not put singlets in the .ace
  	# my $contig_seq = $contig->get_consensus_sequence->seq;
  	# my $contig_qual = join(" ",@{$contig->get_consensus_quality->qual});

    foreach my $seq($contig->each_seq()) {
      my $seq_id = $seq->id;
      $sth->execute($contig_id,$seq_id);
    }
  }
}

sub get_singlets {
  my $sth = $DBH->prepare('SELECT * FROM clone WHERE id NOT IN (SELECT DISTINCT clone_id FROM CAP3) AND length > 0');
  $sth->execute;
  while(my $href = $sth->fetchrow_hashref) {
    my $id = $href->{id};
    my $seq = $href->{seq};
    my $qual = $href->{qual};
    $qual =~ s/\,/ /g;
    $seq =~ s/[Xx]/N/g;

    my $seqobj = Bio::Seq->new(-id => $id,
                               -seq => $seq);
    $UNIQUE_FA->write_seq($seqobj);

    my $qualobj = Bio::Seq::PrimaryQual->new(-id => $id,
                                             -qual => $qual);
    $UNIQUE_QUAL->write_seq($qualobj);
  }
}
