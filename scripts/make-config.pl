#!/usr/local/bin/perl

## Generate Javascript/CSS hashes for CSP
## Generates all 4 CSS nunito/arial & opt/non-opt
## Generates 2 JS opt/non-opt...

use strict;
use warnings;

use File::Basename qw(dirname);
use YAML::XS qw(LoadFile);
use Cwd qw(abs_path);

my $base  = dirname(dirname(abs_path(__FILE__)));

my $config = LoadFile( $base.'/config.yaml' );

open my $fh, q(>), $base.'/includes/config-site.php';
printf {$fh} q(<?php

/*---------------------------------------------------------------------
*| Copyright (c) 2021 James Smith
*+----------------------------------------------------------------------
*| The census system is free software: you can redistribute
*| it and/or modify it under the terms of the GNU Lesser General Public
*| License as published by the Free Software Foundation; either version
*| 3 of the License, or (at your option) any later version.
*|
*| This program is distributed in the hope that it will be useful, but
*| WITHOUT ANY WARRANTY; without even the implied warranty of
*| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*| Lesser General Public License for more details.
*|
*| You should have received a copy of the GNU Lesser General Public
*| License along with this program. If not, see:
*|     <http://www.gnu.org/licenses/>.
*+--------------------------------------------------------------------*/

// Author:  james.me.uk James Smith
// Created: Jun 2021 - moved config into file
//
// Version history:
//  2021-06-01 - importing.

const LOGINS_ENABLED   = false;

// Database configuration - stores information about Sections/Groups....
const DB_NAME          = '%s';
const DB_USER          = '%s';
const DB_PASS          = '%s';

// Compass authentication configuration.
const AUTH_URL         = '%s';
const AUTH_HEAD        = [ '%s' ];
const AUTH_TMPL        = '%s';

// Cryptographic methods/keys used for cookies...
const USER_COOKIE_NAME = '%s';
const CRYPT_METHOD     = '%s';
const CRYPT_KEY        = '%s';
const CS_SECRET        = '%s';

),
  @{$config->{'db'}}{qw(name user pass)},
  $config->{'auth'}{'url'},
  join( q(', '), @{ $config->{'auth'}{'head'}     } ),
  join( q(),     @{ $config->{'auth'}{'template'} } ),
  @{$config->{'crypt'}}{qw(cookie method key secret)};
close $fh;
