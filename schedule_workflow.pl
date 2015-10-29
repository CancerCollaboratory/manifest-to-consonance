use Getopt::Long;
use JSON;
use LWP::UserAgent;
use Data::Dumper;
use YAML::Perl;

#$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;
my $ua  = LWP::UserAgent->new();
$ua->ssl_opts('verify_hostname' => 0); #works

my $manifest;
my $mode = "local";
my $cid;
my $log = {};
my $inputs_hash = {};
my $yml_data;
my $outputs = "jsons";

my $url = "https://www.dockstore.org:8443";

# ARGS

GetOptions (
  "container-id=s" => \$cid,
  "manifest=s" => \$manifest,
  "mode=s" => \$mode,
  "output-dir=s" => \$outputs,
) or die ("Error parsing command lines");

# MAIN LOOP

print "GETTING DOCKER CWL FOR $cid\n";

my $cwl = get_cwl($cid);

system "mkdir -p $outputs";

print "READING MANIFEST FILE...\n";

open IN, "<$manifest" or die;
while(<IN>) {
  chmop;
  next if (/^repo_code/);
  my @t = split /\s+/;
  #print "$t[0]\n";
  order_workflow($t[0], $t[2], $t[3], $t[8], $t[9]);
}
close IN;
print "\n";

# reporting
report_status($log);


# SUBROUTINES

sub get_cwl {
  my ($cid) = @_;
  # get CWL and other info
  my $container_path = $cid;
  $container_path =~ s/\//%2F/g;

  my $container_info = decode_json($ua->get("$url/containers/search?pattern=".$container_path)->decoded_content);

  # print Dumper($container_info);

  my $container_id = $container_info->[0]{id};
  #print "ID: $container_id\n";

  my $cwl_json = decode_json($ua->get("$url/containers/$container_id/cwl")->decoded_content);

  #print Dumper $cwl_json;

  print "  READING CWL FROM DOCKSTORE\n";

  my $cwl_content = $cwl_json->{content};

  #print "CWL\n$cwl_content\n";

  $yml_data = YAML::Perl->new->loader()->open($cwl_content)->load();

  #print Dumper $yml_data;

  print "  EXAMINING TOOL INPUTS...\n";

  foreach my $inputs ($yml_data->{inputs}) {
    #print Dumper $inputs;
    my $id = $inputs->[0]{id};
    $id =~ /\#*(\w+)$/;
    print "  - $1\n";
    $inputs_hash->{$1} = $inputs->[0]{type};
  }

  #print Dumper $inputs_hash;

}

sub order_workflow {
  my ($repo_code, $object_id, $file_format, $donor_id, $project_id) = @_;

  # override variable
  $inputs_hash->{bam_input} = "icgc://$object_id";

  # make a JSON for this BAM
  open OUT, ">$outputs/$project_id.$donor_id.json" or die;
  print OUT to_json($inputs_hash);
  close OUT;

  print "GENERATING JSON FILES...\n";

  print "  - $outputs/$project_id.$donor_id.json\n";

  # if local mode just construct the command and run it

  if ($mode eq "local") {
    print "RUNNING DOCKER LOCALLY...\n";
    print "  - TODO: Denis, I need a sample command "
  }

  # else if consonance mode make the consonance command and execute (echo) it

  if ($mode eq "consonance") {
    print "SCHEDULING JOB WITH CONSONANCE ON THE CLOUD...\n";
    print "  - TODO: Denis, I need a sample command "
  }

  # if everything worked report success
}

sub report_status {
  my ($log) = @_;
  # for each log entry report it's status
}


# icgc://93d90a69-f6ad-5ec8-82db-dad24c66c923
