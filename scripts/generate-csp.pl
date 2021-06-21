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
  ( join '; ',
    q(style-src                 'self' https://fonts.googleapis.com ).
                                $css_sha,
    q(script-src                'self' 'unsafe-inline'
                                'strict-dynamic' ). $js_sha,
    q(default-src               'none'),
    q(base-uri                  'none'),
    q(connect-src               'self' https://fonts.gstatic.com),
    q(font-src                  'self' https://fonts.gstatic.com),
    q(img-src                   'self' data:),
    q(form-action               'self'),
    q(object-src                'none'),
    q(block-all-mixed-content),
    q(frame-ancestors           'none'),
    q(report-uri                /),
#   q(require-trusted-types-for 'script'),
    q(upgrade-insecure-requests) ) =~ s{\s+}{ }gr;
  ;

close $fh;
