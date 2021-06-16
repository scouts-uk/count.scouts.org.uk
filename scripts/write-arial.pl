#!/usr/local/bin/perl

use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd qw(abs_path);

my $base  = dirname(dirname(abs_path(__FILE__)));

my @FF = (
  [ 'nunito',  '"Nunito Sans",arial,sans-serif', q(@font-face{font-family:'Nunito Sans';font-style:normal;font-weight:400;font-display:swap;src:url(https://fonts.gstatic.com/s/nunitosans/v6/pe0qMImSLYBIv1o4X1M8cce9I9s.woff2) format('woff2')}
@font-face{font-family:'Nunito Sans';font-style:normal;font-weight:700;font-display:swap;src:url(https://fonts.gstatic.com/s/nunitosans/v6/pe03MImSLYBIv1o4X1M8cc8GBs5tU1E.woff2) format('woff2')}) ],
  [ 'arial', 'arial,sans-serif', '' ],
);

my $font = @ARGV ? $ARGV[0] : 'nunito';
my $inf  = "$base/source/$font.css";
die "Unable to open file $inf" unless -e $inf;

my($fl,$css,$ffx) = (0,'');
open my $fh, q(<), $inf;
while(<$fh>) {
  if( m#^(.*)\{\s*font-family.*\}# ) {
    $ffx = $1;
    $fl = 1;
    next;
  }
  next if $fl == 0;
  $css .= $_;
}

foreach my $f ( @FF ) {
  #next if $f->[0] eq $font;
  my $outf = "$base/working/$f->[0].css";
  open my $ofh, q(>), $outf;
  print {$ofh} join "\n",
    '/* External fonts */',
    $f->[2].($f->[2]?"\n":'').$ffx."{ font-family: $f->[1] }",
    $css;
  close $ofh;
}
#input,select, option, body {font-family:"Nunito Sans",arial,sans-serif;}
