use Getopt::Long;
use JSON;
use LWP::Simple;
use Data::Dumper;

my $manifest;
my $mode;
my $cid;
my $log = {};

# ARGS

GetOptions (
  "container-id=s" => \$cid,
  "manifest=s" => \$manifest,
  "mode=s" => \$mode,
) or die ("Error parsing command lines");

# MAIN LOOP

my $cwl = get_cwl($cid);

open IN, "<$manifest" or die;
while(<IN>) {
  chmop;
  next if (/^repo_code/);
  my @t = split /\s+/;
  print "$t[0]\n";
  order_workflow($t[0], $t[2], $t[3], $t[8], $t[9]);
}
close IN;

# reporting
report_status($log);


# SUBROUTINES

sub get_cwl {
  my ($cid) = @_;
  # get CWL and other info
  my $container_path = $cid;
  $container_path =~ s/\//%2F/g;
  my $container_info = decode_json(get("http://www.dockstore.org:8080/containers/search?pattern=".$container_path));

  print Dumper($container_info);

  my $container_id = $container_info->[0]{id};
  print "ID: $container_id\n";

  my $cwl_json = decode_json(get("http://www.dockstore.org:8080/containers/$container_id/cwl"));

  print Dumper $cwl_json;

}

sub order_workflow {
  my ($repo_code, $object_id, $file_format, $donor_id, $project_id) = @_;

  # make a JSON for this BAM

  # if local mode just construct the command and run it

  # else if consonance mode make the consonance command and execute (echo) it

  # if everything worked report success
}

sub report_status {
  my ($log) = @_;
  # for each log entry report it's status
}


# icgc://93d90a69-f6ad-5ec8-82db-dad24c66c923
