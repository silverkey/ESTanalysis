#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use DBI;
use DBD::Sqlite;
use Bio::SearchIO; 

# DEFAULTS
my $COVERAGE_CUTOFF = 50;
my $IDENTITY_CUTOFF = 60;
my $DIR_BLAST_OUT = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/BLAST_DB/ACL_UNIGENE';
my $BLAST_OUT = 'ACL_blast.out';
my $OUT_TABLE = "$BLAST_OUT\_filtered.tab";
my $DB = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/3_DB/OCTO_EST_TEST';
my $TABNAME = 'unigene_acl_blast';
my $POPULATE_DB = 0;

my $params = GetOptions('coverage_cutoff|c=i' => \$COVERAGE_CUTOFF,
                        'identity_cutoff|i=i' => \$IDENTITY_CUTOFF,
                        'dir_blast_out|d=s' => \$DIR_BLAST_OUT,
                        'blast_output|b=s' => \$BLAST_OUT,
                        'out_table|o=s' => \$OUT_TABLE,
                        'db|db=s' => \$DB,
                        'tabname|t=s' => \$TABNAME,
                        'populate_db|pdb=i' => \$POPULATE_DB);

chdir($DIR_BLAST_OUT);

parse_blast_results();

my $DBH;
$DBH = DBI->connect("dbi:SQLite:dbname=$DB","","") if $POPULATE_DB;
create_table() if $POPULATE_DB;
populate_table() if $POPULATE_DB;

sub parse_blast_results {

  my $in = new Bio::SearchIO(-format => 'blast', 
                             -file => $BLAST_OUT);

  open(OUT,">$OUT_TABLE");

  # $result is a Bio::Search::Result::ResultI compliant object
  while(my $result = $in->next_result) {

    my $candidate = {};

    # $hit is a Bio::Search::Hit::HitI compliant object
    while(my $hit = $result->next_hit) {

      # $hsp is a Bio::Search::HSP::HSPI compliant object
      while(my $hsp = $hit->next_hsp) {

        my $coverage = $hsp->length('total') / $result->query_length * 100;
        $coverage =~ s/^(\d+)\.\d+$/$1/;

        my $identity = $hsp->percent_identity;
        $identity =~ s/^(\d+)\.\d+$/$1/;

        if($coverage >= $COVERAGE_CUTOFF) {

          if($identity >= $IDENTITY_CUTOFF) {

            if(! exists $candidate->{hsp}) {
              $candidate = {};
              $candidate->{hit} = $hit;
              $candidate->{hsp} = $hsp;
              $candidate->{coverage} = $coverage;
              $candidate->{identity} = $identity;
            }

            elsif($hsp->evalue < $candidate->{hsp}->evalue) {
              $candidate = {};
              $candidate->{hit} = $hit;
              $candidate->{hsp} = $hsp;
              $candidate->{coverage} = $coverage;
              $candidate->{identity} = $identity;
            }
          }
        }
      }  
    }
    if(exists $candidate->{hsp}) {

      print OUT $result->query_name ."\t".
                $candidate->{hit}->name ."\t".
                $candidate->{hit}->description ."\t".
                $candidate->{hsp}->evalue ."\t".
                $candidate->{coverage} ."\t".
                $candidate->{identity}, "\n";
    }
  }
  close(OUT);
}

sub create_table {
  $DBH->do(qq{
    CREATE TABLE $TABNAME(
    qid VARCHAR PRIMARY KEY,
    hid VARCHAR KEY,
    hdesc VARCHAR,
    evalue REAL KEY,
    coverage INTEGER KEY,
    identity INTEGER KEY)
  });
}

sub populate_table {
  system("sqlite3 -separator \"\t\" $DB \'.import $OUT_TABLE $TABNAME\'");
}

exit;
