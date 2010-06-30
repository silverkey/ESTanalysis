#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use DBD::Sqlite;
use Bio::SeqIO;

use Data::Dumper;

my $DB = 'OCTO_EST_3'; # Name and path of the database
my $FASTA = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/2_CROSS_MATCH/SEQs.fa.screen'; # Name and path of the fasta file
my $QUAL =  '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/2_CROSS_MATCH/SEQs.fa.screen.qual'; # Name and path of the quality file
my $CREATE_TABLE = 1; # Create the table (1) or only add the rows (0)?
my $RES_DIR = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/3_DB/';

# THE TABLE WITH THE PHRED OUTPUT MUST TO BE CALLED clone !!!!
my $TABNAME = 'clone'; # Name of the table to populate

chdir($RES_DIR);

my $DATA = {};

my $DBH = DBI->connect("dbi:SQLite:dbname=$DB","","");

create_table() if $CREATE_TABLE;

prepare_data();

insert_data();

write_seqio();

sub create_table {
  $DBH->do(qq{
    CREATE TABLE $TABNAME(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR KEY,
    seq VARCHAR,
    qual VARCHAR,
    length INTEGER KEY)
  });
}

sub prepare_data {
  my $fasta = Bio::SeqIO->new(-file => $FASTA,
                              -format => 'fasta');
  while(my $seq = $fasta->next_seq()) {
    $DATA->{$seq->id}->{seq} = $seq->seq;
    $DATA->{$seq->id}->{length} = $seq->length;
  }
  my $qual = Bio::SeqIO->new(-file => $QUAL,
                              -format => 'qual');
  while(my $seq = $qual->next_seq()) {
    next unless exists $DATA->{$seq->id};
    $DATA->{$seq->id}->{qual} = join("\,",@{$seq->qual});
  }
}

sub insert_data {
  my $sth = $DBH->prepare_cached(qq{
    INSERT INTO $TABNAME
    (name,seq,qual,length)
    VALUES (?,?,?,?)
  });

  foreach my $name(keys %$DATA) {
    my $seq = $DATA->{$name}->{seq};
    my $qual = $DATA->{$name}->{qual};
    my $length = $DATA->{$name}->{length};

    $sth->execute($name,$seq,$qual,$length);
  }
}

sub write_seqio {
  my $seqio = Bio::SeqIO->new(-file => ">$TABNAME\.fa",
                              -format => 'fasta');

  my $seqioq = Bio::SeqIO->new(-file => ">$TABNAME\.qual",
                               -format => 'qual');

  my $sth = $DBH->prepare("SELECT * FROM $TABNAME WHERE length > 0");

  $sth->execute;

  while(my $res = $sth->fetchrow_hashref) {

    my $id = $res->{id};
    my $seq = $res->{seq};
    my $qual = $res->{qual};
    $qual =~ s/\,/ /g;

    my $seqobj = Bio::Seq->new(-id => $id,
                               -seq => $seq);

    my $qualobj = Bio::Seq::PrimaryQual->new(-id => $id,
                                             -qual => $qual);

    $seqio->write_seq($seqobj);
    $seqioq->write_seq($qualobj);
  }
}
