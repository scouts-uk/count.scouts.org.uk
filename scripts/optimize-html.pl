#!/usr/local/bin/perl

use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd qw(abs_path);

my $base  = dirname(dirname(abs_path(__FILE__)));

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
