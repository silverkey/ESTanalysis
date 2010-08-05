#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use DBD::Sqlite;
use Bio::SeqIO;

use Data::Dumper;

my $DB = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/3_DB/OCTO_EST_TEST'; # Name and path of the database
#my $FASTA = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/5_SEQTRIM/unique.trimmed.fa'; # Name and path of the fasta file
#my $QUAL =  '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/5_SEQTRIM/mod_unique.trimmed.fa.qual'; # Name and path of the quality file
#my $RES_DIR = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/';

my $FASTA = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/7_PORTRAIT/PORTRAIT_EYE/OctEye_NR.seq.fasta'; # Name and path of the fasta file
my $QUAL =  0; # Name and path of the quality file
my $RES_DIR = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/';

my $CREATE_TABLE = 1; # Create the table (1) or only add the rows (0)?
my $ID_IN_FA = 'name'; # The field of the table to use as ID in the fasta to generate
my $MINIMUM_LENGTH = 1; # The minimum length to put in the fasta to generate

# THE TABLE WITH THE PHRED OUTPUT MUST TO BE CALLED clone !!!!
# ALL THE OTHERS CAN BE CALLED AS YOU WANT....
# my $TABNAME = 'EST'; # Name of the table to populate
# THE TABLE WITH THE PHRED OUTPUT MUST TO BE CALLED clone !!!!
# ALL THE OTHERS CAN BE CALLED AS YOU WANT....
my $TABNAME = 'EYE';

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
    desc VARCHAR,
    length INTEGER KEY)
  });
}

sub prepare_data {
  my $fasta = Bio::SeqIO->new(-file => $FASTA,
                              -format => 'fasta');
  while(my $seq = $fasta->next_seq()) {
    $DATA->{$seq->id}->{seq} = $seq->seq;
    $DATA->{$seq->id}->{length} = $seq->length;
    $DATA->{$seq->id}->{desc} = $seq->desc;
  }
  return unless $QUAL;
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
    (name,seq,qual,desc,length)
    VALUES (?,?,?,?,?)
  });

  foreach my $name(keys %$DATA) {
    my $seq = $DATA->{$name}->{seq};
    my $qual = $DATA->{$name}->{qual} || 'NA';
    my $desc = $DATA->{$name}->{desc};
    my $length = $DATA->{$name}->{length};

    $sth->execute($name,$seq,$qual,$desc,$length);
  }
}

sub write_seqio {
  my $seqio = Bio::SeqIO->new(-file => ">$TABNAME\.fa",
                              -format => 'fasta');

  my $seqioq = Bio::SeqIO->new(-file => ">$TABNAME\.qual",
                               -format => 'qual') if $QUAL;

  my $sth = $DBH->prepare("SELECT * FROM $TABNAME WHERE length > $MINIMUM_LENGTH");

  $sth->execute;

  while(my $res = $sth->fetchrow_hashref) {

    my $id = $res->{$ID_IN_FA};
    my $seq = $res->{seq};
    my $qual = $res->{qual} if $QUAL;
    $qual =~ s/\,/ /g if $QUAL;

    my $seqobj = Bio::Seq->new(-id => $id,
                               -seq => $seq);

    my $qualobj = Bio::Seq::PrimaryQual->new(-id => $id,
                                             -qual => $qual) if $QUAL;

    $seqio->write_seq($seqobj);
    $seqioq->write_seq($qualobj) if $QUAL;
  }
}
