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

  include_once( '../includes/config.php' );
  include_once( '../includes/cryptor.php' );
  include_once( '../includes/authenticate.php' );
  include_once( '../includes/queries.php' );

  $ip      = $_SERVER['HTTP_X_FORWARDED_FOR'];
  $user_id = get_cookie();
  $params  = isset($_SERVER['REQUEST_URI'])
           ? array_values(array_filter(explode('/',$_SERVER['REQUEST_URI'])))
           : []; 

// What to do if the user is not logged in
  if( ! $user_id ) {
    // Check to see if they are trying to login in 
    if( $_SERVER['REQUEST_METHOD'] === 'POST' ) { // Handle login
      $user = authenticate( $_POST['u'], $_POST['p'] );
      if( $user ) { // If authenticated set the cookie (and log in user)
        set_cookie( $user );
      }
      // Redirect back to this page - will then either show data form or
      // redisplay login page..
      header( 'Location: /' );
      exit;
    }
    // If not POST must be GET show login page...
    readfile('../includes/login-page.php');
    exit;
  }
// First check to see if we are being asked to logout!
  if( count($params) == 1 && $params[0] === 'logout' ) {
    clear_cookie( );
    header( 'Location: /' );
    exit;
  }
  if( count($params) == 0 ) {
    print preg_replace( '/XXXX/', $user_id,
      file_get_contents('../includes/main-page.php') );
    exit;
  }
  $db = new Database();
  if( count($params) == 1 ) {
    $district_no = (int)$params[0];
    header('Content-type: application/json');
    echo preg_replace( '/"(\d+)"/','$1',
      json_encode( $db->get_groups_and_units( $district_no )) );
    exit;
  }
// Now we need to see if the user is pushing values to the database....
  $section_no = (int)$params[0];
  $count      = (int)$params[1];
  $over       = count($params)>2 ? (int)$params[1] : 0;
  if( $over === 0 ) {
    $details = $db->get_details( $section_no );
    if( $details['yp_count']>0 && $details['yp_count'] != $count ) {
      header('Content-type: application/json');
      echo json_encode( [
        'status' => 'CONFIRMATION_REQ',
        'message' => sprintf( '<h2>%s (%s) of %s (%s)</h2>
  <p>
    Please confirm that you wish to change the number of %ss
    from %d to %d
  </p>
  <p>
    <input type="button" value="Update &raquo;">
  </p>',  HTMLentities( $details['name'] ), $details['username'],
          HTMLentities( $details['gp'  ] ), $details['gpid'],
          $details['member_name'], $details['yp_count'], $count
        )
      ] );
      exit;
    }
  }
  $details = $db->update_counts( $section_no, $count, $user_id, $ip );
  echo json_encode( [
    'status' => 'OK',
    'message' => sprintf( '<h2>%s (%s) of %s (%s)</h2>
<p>
  The number of %ss has been recorded in the database as %d.
</p>
<p>
  Thank you for submitting this information.
</p>', HTMLentities( $details['name'] ), $details['username'],
       HTMLentities( $details['gp'  ] ), $details['gpid'],
       $details['member_name'], $details['yp_count'] )
  ] );

// Now 
