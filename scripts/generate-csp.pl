#!/usr/local/bin/perl

## Generate Javascript/CSS hashes for CSP
## Generates all 4 CSS nunito/arial & opt/non-opt
## Generates 2 JS opt/non-opt...

use strict;
use warnings;

use File::Basename qw(dirname);
use Cwd qw(abs_path);

my $base  = dirname(dirname(abs_path(__FILE__)));
my $root  = dirname(dirname($base));

open my $fh, q(<), $base.'/checksums/js-sha.txt';
my $js_sha  = join ' ', map { chomp; sprintf q('%s'), $_ } <$fh>;
close $fh;
open    $fh, q(<), $base.'/checksums/css-sha.txt';
my $css_sha = join ' ', map { chomp; sprintf q('%s'), $_ } <$fh>;
close $fh;

open    $fh, q(>), $root.'/apache2/census_csp.conf';

printf {$fh} q(Header always set Content-Security-Policy: "%s"),
  join '; ',
    q(default-src 'none'),
    q(base-uri 'none'),
    q(connect-src 'self' https://fonts.gstatic.com),
    q(font-src 'self' https://fonts.gstatic.com),
    q(style-src 'self' https://fonts.googleapis.com ). $css_sha,
    q(img-src 'self' data:),
    q(script-src 'self' 'unsafe-inline' 'strict-dynamic' ). $js_sha,
    q(form-action 'self'),
    q(object-src 'none'),
    q(block-all-mixed-content),
    q(frame-ancestors 'none'),
    q(report-uri /),
#   q(require-trusted-types-for 'script'),
    q(upgrade-insecure-requests)
  ;

close $fh;
