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
my $test = 0;
my $s3_output_path = "s3://oicr.temp/testing-manifest-to-consonance";
my $mem = 5;

my $url = "https://www.dockstore.org:8443";

# ARGS

GetOptions (
  "container-id=s" => \$cid,
  "manifest=s" => \$manifest,
  "mode=s" => \$mode,
  "output-dir=s" => \$outputs,
  "s3-output-path=s" => \$s3_output_path,
  "test" => \$test,
  "mem=i" => \$mem,
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
    print Dumper $inputs;
    foreach my $currInput (@{$inputs}) {
      my $id = $currInput->{id};
      $id =~ /\#*(\w+)$/;
      print "  - $1\n";
      if ($currInput->{type} eq "File") {
        $inputs_hash->{$1}{path} = $currInput->{type};
        $inputs_hash->{$1}{class} = $currInput->{type};
      } else {
        $inputs_hash->{$1} = $currInput->{type};
      }
    }
  }

  print "  EXAMINING TOOL OUTPUTS...\n";
  foreach my $inputs (@{$yml_data->{outputs}}) {
    #print Dumper $inputs;
    my $id = $inputs->[0]{id};
    $id =~ /\#*(\w+)$/;
    print "  - $1\n";
    $inputs_hash->{$1}{path} = $inputs->[0]{type};
    $inputs_hash->{$1}{class} = $inputs->[0]{type};
  }

  print Dumper $inputs_hash;

die;

  open OUT, ">$outputs/Dockstore.cwl" or die;
  print OUT $cwl_content;
  close OUT;

}

sub order_workflow {
  my ($repo_code, $object_id, $file_format, $donor_id, $project_id) = @_;

  # HACK!!!
  # override variable
  ########$inputs_hash->{bam_input}{path} = "icgc:$object_id";
  $inputs_hash->{bam_input}{path} = "ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/data/NA12878/alignment/NA12878.chrom20.ILLUMINA.bwa.CEU.low_coverage.20121211.bam";
  $inputs_hash->{mem_gb} = $mem;
  # output
  $inputs_hash->{bamstats_report}{path} = "$s3_output_path/$project_id\:\:$donor_id\_bamstats_report.zip";

  # make a JSON for this BAM
  open OUT, ">$outputs/$project_id.$donor_id.json" or die;
  print OUT to_json($inputs_hash);
  close OUT;

  print "GENERATING JSON FILES...\n";

  print "  - $outputs/$project_id.$donor_id.json\n";

  # if local mode just construct the command and run it

  if ($mode eq "local") {
    print "RUNNING DOCKER LOCALLY...\n";
    # TODO: you're going to need to output the cwl to a file and replace collab.cwl
    my $cmd = "java -cp lib/uber-io.github.collaboratory.launcher-1.0.4.jar io.github.collaboratory.LauncherCWL --config config/launcher.ini --descriptor $outputs/Dockstore.cwl --job $outputs/$project_id.$donor_id.json";
    print "$cmd\n";
    if (!$test) {
      my $result = system("/bin/bash -l -c '$cmd'");
      if ($result) { print "ERROR! problems with command\n"; }
    }
  }

  # else if consonance mode make the consonance command and execute (echo) it

  if ($mode eq "consonance") {
    print "SCHEDULING JOB WITH CONSONANCE ON THE CLOUD...\n";
    # TODO: you're going to need to output the cwl to a file and replace collab.cwl
    my $cmd = "consonance run  --flavour m1.xlarge --image-descriptor $outputs/Dockstore.cwl --run-descriptor $outputs/$project_id.$donor_id.json --extra-file cwl-launcher.config=cwl-launcher.config=true  --extra-file /icgc/dcc-storage/conf/application-amazon.properties=application-amazon.properties=false";
    print "$cmd\n";
    if (!$test) {
      my $result = system("/bin/bash -l -c '$cmd'");
      if ($result) { print "ERROR! problems with command\n"; }
    }
  }

  # if everything worked report success
}

sub report_status {
  my ($log) = @_;
  # for each log entry report it's status
}


# icgc://93d90a69-f6ad-5ec8-82db-dad24c66c923
