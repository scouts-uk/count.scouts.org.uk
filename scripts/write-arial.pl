#!/usr/local/bin/perl

##----------------------------------------------------------------------
## Copyright (c) 2021 James Smith
##----------------------------------------------------------------------
## The census system is free software: you can redistribute
## it and/or modify it under the terms of the GNU Lesser General Public
## License as published by the Free Software Foundation; either version
## 3 of the License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## Lesser General Public License for more details.
##
## You should have received a copy of the GNU Lesser General Public
## License along with this program. If not, see:
##     <http://www.gnu.org/licenses/>.
##----------------------------------------------------------------------

## Author:  james@curtissmith.me.uk - James Smith
## Created: Jun 2021 - moved config into file
##
## Version history:
##  v1.0 - initial build
##

## Copy CSS file into dist - ready for inserting into HTML pages

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
