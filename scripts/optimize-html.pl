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

## Writes HTML - inserting javascript/CSS & images
## either compressed or not..

use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use YAML::XS qw(LoadFile);

my $base   = dirname(dirname(abs_path(__FILE__)));
my $config = LoadFile( "$base/config.yaml" );
my $dev = @ARGV;
my $out = 1;

my %files = (
  'source/template.html' => 'dist/sections',
  'source/login.html'    => 'dist/login',
);

foreach my $source (keys %files ) {
  my $dest = $files{$source};
  my $template='';
  open my $fh, '<', "$base/$source";
  $template .= tidy($_) while <$fh>;
  close $fh;

  $template =~ s{\[\[([^\]]+)\]\]}{insert($1)}ge;
  open $fh, '>', $dev ? "$base/$dest-dev.html" : "$base/$dest.html";
  print {$fh} $template;
}

sub insert {
  my $fn = $_[0];
  $fn =~ s{-opt}{} if $dev;
  $fn =~ s{nunito}{arial} unless $config->{'use_google_fonts'};
  print "    Including working/$fn\n";
  open my $fh, '<', "$base/working/$fn";
  my $out = '';
  while($_ = <$fh>) {
    next if m{/[*] jshint};
    $out .= tidy($_);
  }
  return $out;
}

sub tidy {
  my $string = shift;#return $string;
  return $string if $dev;
  if( $string =~ m{\A<!--} ) { $out = 0; return ''; }
  if( $string =~ m{-->\Z}  ) { $out = 1; return ''; }
  return '' unless $out;
  return $string =~ s{^\s+}{}r=~ s{\s+$}{}r;
}
