<?php

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
// Created: Jun 2021 - tidied up cryptor script from census
//
// Version history:
//  2021-06-01 - importing.

class Database {
  private $dbh;
  function __construct() {
    $this->dbh = new PDO(
        'mysql:host=localhost;dbname='.DB_NAME.';charset=utf8mb4',
        DB_USER, DB_PASS
    );
  }

  function get_details( $section_no ) {
    // Fetches information about a section (and their parent information Group/District)
    // Used to give simple confirmation messages..
    $sth = $this->dbh->prepare(
      'select ot.member_name, sc.yp_count, sc.updated_by_username,
              o.object_id, o.username, o.name, p.name as gp,
              p.username as gpid
         from objecttype ot, object p, object o
         left join short_count sc on 
              o.object_id = sc.object_id and sc.census_id = ?
        where ot.objecttype_id = o.objecttype_id and
              o.username = ? and
              o.parent_id = p.object_id' );
    $sth->execute([CENSUS_ID, OFFSET + $section_no]);
    $obj = $sth->fetch( PDO::FETCH_ASSOC );
    if( $obj['member_name'] == 'Explorer Scout' ) {
      $obj['gpid'] -= 6*OFFSET;
      $obj['gp'] = preg_replace( '/Explorer Scout provision/',
                                 'District', $obj['gp'] );
    }
    return $obj;
  }
  
  function update_counts( $section_no, $count, $user_id, $ip ) {
    // Set the count of members in section,
    // creates (if required) and entry in short_count
    // then updates it to the latest figures
    // finally writes an entry in the "audit-log" table...
    $t = $this->get_details( $section_no );
    $this->dbh->prepare( 'insert ignore into short_count
                                 (object_id,census_id)
                                 values(?,?)' )
              ->execute( [ $t['object_id'], CENSUS_ID ] );
    $this->dbh->prepare( 'update short_count set yp_count = ?,
                                 updated_by_username = ?,
                                 updated_from_ip = ?
                           where object_id = ? and census_id = ?' )
              ->execute( [ $count, $user_id, $ip,
                           $t['object_id'], CENSUS_ID ] );
    $this->dbh->prepare( 'insert into audit_short_count
                                 (yp_count,updated_by_username,
                                   updated_from_ip,object_id,census_id)
                           values(?,?,?,?,?)' )
              ->execute([ $count, $user_id, $ip,
                          $t['object_id'], CENSUS_ID ]);
    return $this->get_details( $section_no );
  }

  function get_groups_and_units( $district_no ) {
    // Given a "district" number {-$OFFSET} get a list of all Groups
    // (with sections) and Units apply the "heuristic" sort to sort
    // by "place" then "ordinal"...
    $sth = $this->dbh->prepare( '
      select if(g.objecttype_id=6,"g","u") as type,
             (g.username-:offset) as group_id,
             g.name as group_name, (s.username-:offset) as section_id,
             s.name as section_name, sc.yp_count
        from (object d, object g, object s, summary gs, summary ss)
        left join short_count sc
          on sc.census_id = :census_id and sc.object_id = s.object_id
       where d.username = :duser and d.objecttype_id = 5 and
             g.parent_id = d.object_id and
               g.objecttype_id in (6,16) and
               gs.census_id = :census_id and
               gs.object_id = g.object_id and gs.status != "closed" and
             s.parent_id = g.object_id and
               s.objecttype_id in (10,11,12,13) and
               ss.census_id = :census_id and
               ss.object_id = s.object_id and ss.status != "closed"
       order by type, group_id, s.name' );
    $sth->execute( [ ':offset'    => OFFSET,
                     ':census_id' => CENSUS_ID,
                     ':duser'     => $district_no + OFFSET ] );
    $data = $sth->fetchAll( PDO::FETCH_ASSOC );
    // Roll data into structure to return in json format:
    // List of Groups (containing a list of sections) and
    // list of Explorer Scouts units
    $groups = [];
    $units  = [];
  
    foreach( $data as $row ) {
      if( $row['type'] == 'u' ) {
        $units[] =
          [ $row['section_id'], $row['section_name'], $row['yp_count'] ];
      } else {
        if( !array_key_exists( $row['group_id'], $groups ) ) {
          $groups[ $row['group_id'] ] =
            [ $row['group_id'], $row['group_name'], [] ];
        }
        $groups[ $row['group_id'] ][2][] =
          [ $row['section_id'], $row['section_name'], $row['yp_count'] ];
      }
    }
  
    $groups = $this->group_sort( array_values( $groups ) );
    $units  = $this->group_sort( $units );
   
    return [ $groups, $units ];  
  }
  
  //======================================================================
  // Support functions..
  //======================================================================
  
  // group_sort
  // ----------
  //
  // "heuristic sort" which uses a "schwartzian transform" to order
  // groups order is initially by "area" - and then the ordinal number..
  // e.g. 15th Durham (Elvet) would be sorted as
  // Durham / 15 / 15th Durham (Elvet)
  //
  // anything starting with Sea/Air/Scout or a "(" will be trimmed from
  // the name to get the "Area"
  //
  // Groups without ordinals have the ordinal number set to 0.
  
  function group_sort( $arr ) {
    // Split into "City" "Ordinal" "Name"
    $t = array_map( function( $_ ) {
      return preg_match(
        '/^(\d+)[a-z]{2}\b\S*\s*(.*?)(?:\s*(?:\(|(?:Sea |Air )?Scout).*)?$/',
        $_[1],
        $matches
      ) ? [ $matches[1], $matches[2], $_ ]
        : [ 0,           $_[1],       $_ ];
    }, $arr );
    // Sort by "City" "Ordinal" "Name"
    usort( $t, function($a,$b) {
      return $a[1] < $b[1] ? -1 : ( $a[1] > $b[1] ? 1 :
           ( $a[0] < $b[0] ? -1 : ( $a[0] > $b[0] ? 1 :
           ( $a[2] < $b[2] ? -1 : ( $a[2] > $b[2] ? 1 : 0
      )) )) );
    });
    // Return list of "Name"s
    return array_map( function($_) { return $_[2]; }, $t );
  }
}  

/** Schema
create table short_count (
  object_id           int(10) unsigned not null,
  census_id           int(10) unsigned not null,
  yp_count            int(10) unsigned not null default '0',
  updated_by_username int(10) unsigned not null default '0',
  updated_at          timestamp not null default
                      current_timestamp on update current_timestamp,
  updated_from_ip     char(39) not null,
  unique by_census  ( census_id, object_id  ),
  unique by_object  ( object_id, census_id  ),
  index  by_date    ( census_id, updated_at )
);

create table audit_short_count (
  object_id           int(10) unsigned not null,
  census_id           int(10) unsigned not null,
  yp_count            int(10) unsigned not null default '0',
  updated_by_username int(10) unsigned not null default '0',
  updated_at          timestamp not null default current_timestamp,
  updated_from_ip     char(39) not null,
  index  by_object  ( census_id, object_id, updated_at ),
  index  by_date    ( census_id, updated_at )
);
**/
