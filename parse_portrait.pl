#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use DBI;
use DBD::Sqlite;

# DEFAULTS
my $FOLDER = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/7_PORTRAIT/'; # folder containing the portrait output
my $FILE = 'EST.fa_results_all.scores'; # name of the portrait output
my $WEBRES = 0;
my $TABNAME = 'brain_portrait';
my $POPULATE_DB = 0;
my $DB = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/3_DB/OCTO_EST_TEST';

my $params = GetOptions('directory|d=s' => \$FOLDER,
                        'file|f=s' => \$FILE,
                        'webres|w=i' => \$WEBRES,
                        'tabname|t=s' => \$TABNAME,
                        'populate_db|pdb=i' => \$POPULATE_DB,
                        'db|db=s' => \$DB);

chdir($FOLDER);

parse_html() if $WEBRES;

parse_text();

my $DBH;
$DBH = DBI->connect("dbi:SQLite:dbname=$DB","","") if $POPULATE_DB;
create_table() if $POPULATE_DB;
populate_table() if $POPULATE_DB;

sub parse_text {
  open(IN,$FILE);
  open(OUT,">$FILE\.tab");
  while(my $row = <IN>) {
    chomp($row);
    my($id,$class,$coding,$noncoding) = split(/ /,$row);
    $id =~ s/\>//;
    $class =~ s/\://g;
    print OUT "$id\t$class\t$coding\t$noncoding\n";
  }
  close(OUT);
}

sub populate_table {
  system("sqlite3 -separator \"\t\" $DB \'.import $FILE\.tab $TABNAME\'");
}

sub parse_html {
  my $NONCODING_CUTOFF = 0.01;
  open(IN,$FILE);
  while(my $row = <IN>) {
  	# The next line function only if you save the html file from the firefox under mac
    next unless $row =~ /^\<Tr\>\<Td.bgcolor\=\#.+\>(.+)\<\/Td\>\<Td bgcolor\=\#.+align\=\"right\"\>(\d+\.\d+)\%\<\/Td\>\<Td.bgcolor\=\#.+.align\=\"right\"\>(\d+\.\d+)\%\<\/Td\>$/;
    my $id = $1;
    my $coding = 1 - ($2 / 100);
    my $noncoding = 1 - ($3 / 100);
    $id =~ s/ //g;
    $coding =~ s/^(\d+\.\d\d\d\d)\d+$/$1/;
    $noncoding =~ s/^(\d+\.\d\d\d\d)\d+$/$1/;
    my $found = 'N';
    $found = 'Y' if $noncoding <= $NONCODING_CUTOFF;
    print "$id\t$coding\t$noncoding\t$found\n";
  }
  close(IN);
  exit;
}

sub create_table {
  $DBH->do(qq{
    CREATE TABLE $TABNAME(
    id VARCHAR PRIMARY KEY,
    classified INTEGER KEY,
    coding REAL KEY,
    noncoding REAL KEY)
  });
}
