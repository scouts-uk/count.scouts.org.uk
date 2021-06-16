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

## Accesses District/County information from the Scout Census database
## and inserts the resultant JSON data structure into the javascript
## code for embedding in HTML pages

use strict;
use warnings;
use DBI;
use JSON::XS;
use YAML::XS qw(LoadFile);
use File::Basename qw(dirname);
use Cwd qw(abs_path);

my $base  = dirname(dirname(abs_path(__FILE__)));

my $config = LoadFile( $base.'/config.yaml' );

my $json = JSON::XS->new->ascii->allow_nonref;

$/=undef;
open my $fh, '<', "$base/source/flow.js";
my $contents = <$fh>;
close $fh;

my $dbh = DBI->connect( "dbi:mysql:$config->{'db'}{'name'}",
  $config->{'db'}{'user'}, $config->{'db'}{'pass'}, { 'mysql_enable_utf8' => 1 } );

my $SQL_QUERY_COUNTY = '
select distinct( o.username - 10000000) uid, o.name
  from object o,object d
 where o.object_id = d.parent_id and d.objecttype_id = 5 and
       (o.objecttype_id in (2,3,4,9) or o.object_id = 430209)
 order by o.name,uid
';

my $SQL_QUERY_DISTRICT = '
select p.username - 10000000 as pid, o.username - 10000000 as uid,o.name
  from object o, object p
 where o.objecttype_id = 5 and o.parent_id = p.object_id
 order by pid,o.name
';

my $counties  = [ map { [ 1*$_->[0], $_->[1] ] }
                  @{$dbh->selectall_arrayref( $SQL_QUERY_COUNTY   )} ];

my $t_dist   = {};
push @{ $t_dist->{ 1*$_->[0]} },   [ 1*$_->[1], $_->[2] ]
  foreach @{$dbh->selectall_arrayref( $SQL_QUERY_DISTRICT )};

$_->[2] = $t_dist->{ 1*$_->[0] } foreach @{$counties};

my $dists = $json->encode( $counties );

print length $dists;

$contents =~ s{/[*] [*]/.*?/[*] [*]/}{'/* */var str='.$dists.';/* */'}e;

open $fh, '>', $base.'/working/script.js';
print {$fh} '/*<![CDATA[*/',$contents,'/*]]>*/';
close $fh;

