use Getopt::Long;

my $cwl;
my $manifest;

GetOptions (
  "cwl=s" => \$cwl,
  "manifest=s" => \$manifest,
) or die ("Error parsing command lines");

open IN, "<$manifest" or die;
while(<IN>) {
  chmop;
  my @t = split /\w+/;
  print "$t[0]\n";
}
close IN;


# icgc://93d90a69-f6ad-5ec8-82db-dad24c66c923
