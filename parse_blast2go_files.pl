#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use DBI;
use DBD::Sqlite;
use Data::Dumper;

# DEFAULTS
my $FOLDER = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/8_BLAST2GO/BLAST2GO_NR_DEF/'; # folder containing the bl2g output
my $ANN_FILE = 'blast2go_txt_ANNEX_20100804_1422.txt'; # name of the bl2go annotation output
my $IPR_FILE = 'blast2go_Ipsr_26072010.txt'; # name of the bl2go interpro file annotation
my $TOP_FILE = 'top_blast.txt'; # name of the bl2go tophit file annotation
my $TABNAME = 'brain_b2g_ann';
my $POPULATE_DB = 0;
my $DB = '/Volumes/PACKY/POLPO_EST/ALL_ESTs_ANALYSIS/TEST_3/3_DB/OCTO_EST_TEST';

my $HREF = {};
my $href = {};

my $params = GetOptions('directory|d=s' => \$FOLDER,
                        'ann_file|af=s' => \$ANN_FILE,
                        'ipr_file|if=s' => \$IPR_FILE,
                        'tabname|t=s' => \$TABNAME,
                        'populate_db|pdb=i' => \$POPULATE_DB,
                        'db|db=s' => \$DB);

chdir($FOLDER);

parse_ann();
parse_ipr();
parse_top();

write_out();

my $DBH;
$DBH = DBI->connect("dbi:SQLite:dbname=$DB","","") if $POPULATE_DB;
create_table() if $POPULATE_DB;
populate_table() if $POPULATE_DB;

sub parse_ann {
  open(IN,$ANN_FILE);
  my $head = <IN>;
  while(my $row = <IN>) {
    chomp($row);
    my($id,$desc,$GO,$EC,$KEGG) = split(/\t/,$row);
    $HREF->{$id}->{desc} = $desc;
    $HREF->{$id}->{go} = $GO;
    $HREF->{$id}->{ec} = $EC;
    $HREF->{$id}->{kegg} = $KEGG;
    $HREF->{$id}->{hdesc} = '';
    $HREF->{$id}->{hid} = '';
    $HREF->{$id}->{ipr} = '';
  }
  close(IN);
}

sub parse_top {
  open(IN,$TOP_FILE);
  my $head =<IN>;
  while(my $row = <IN>) {
    chomp($row);
    # Sequence name	Sequence desc.	Sequence length	Hit desc.	Hit ACC	E-Value	Similarity	Score	Alignment length	Positives
    my($qid,$qdesc,$qlength,$hdesc,$hid,$eval,$simil,$score,$alnlength,$pos) = split(/\t/,$row);
    $HREF->{$qid}->{hdesc} = $hdesc;
    $HREF->{$qid}->{hid} = $hid;
  }
  close(IN);
}

sub parse_ipr {
  open(IN,$IPR_FILE);
  while(my $row = <IN>) {
    next if $row =~ /unintegrated/;
    chomp($row);
    my($id,$bla,$iprid,$desc,$analysis,$program) = split(/\t/,$row);
    $href->{$id}->{$desc} ++;
  }
  close(IN);
}

sub write_out {
  open(OUT,">$ANN_FILE\.plus_intepro");
  foreach my $id(keys %$HREF) {
    $HREF->{$id}->{ipr} = join(';', keys %{$href->{$id}});
    print OUT $id."\t".
              $HREF->{$id}->{desc}."\t".
              $HREF->{$id}->{hid}."\t".
              $HREF->{$id}->{hdesc}."\t".
              $HREF->{$id}->{go}."\t".
              $HREF->{$id}->{ec}."\t".
              $HREF->{$id}->{kegg}."\t".
              $HREF->{$id}->{ipr}."\n";
  }
  close(OUT);
}

sub populate_table {
  system("sqlite3 -separator \"\t\" $DB \'.import $ANN_FILE\.plus_intepro $TABNAME\'");
}

sub create_table {
  $DBH->do(qq{
    CREATE TABLE $TABNAME(
    id VARCHAR PRIMARY KEY,
    desc VARCHAR KEY,
    hid VARCHAR KEY,
    hdesc VARCHAR KEY,
    go VARCHAR KEY,
    ec VARCHAR KEY,
    kegg VARCHAR KEY,
    ipr VARCHAR KEY
    )
  });
}

#print Dumper $HREF;
