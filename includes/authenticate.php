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


function clear_cookie() {
  setcookie ( USER_COOKIE_NAME, '', 1, '/', '', true, true );
  // setcookie ( USER_COOKIE_NAME, '',
  //  [ 'expires' => 1, 'path' => '/', 'domain' => '',
  //    'secure' => true, 'httponly' => true, 'samesite' => true ] );
}

function set_cookie( $res ) {
  $crypt = new Cryptor( CRYPT_KEY, CRYPT_METHOD );
  $value = $crypt->encrypt64( json_encode(
    [ 'id' => $res['id'], 'secret' => CS_SECRET ] ) );
  setcookie ( USER_COOKIE_NAME, $value, 0, '/', '', true, true );
  // setcookie ( USER_COOKIE_NAME, $value,
  //  [ 'expires' => 0, 'path' => '/', 'domain' => '',
  //    'secure' => true, 'httponly' => true, 'samesite' => true ] );
}

function get_cookie() {
  if( ! LOGINS_ENABLED ) {
error_log("***");
    return 1;
  }
  if( !isset( $_COOKIE[ USER_COOKIE_NAME ] ) ) {
    return false;
  }
error_log("*X*");
  $crypt = new Cryptor( CRYPT_KEY, CRYPT_METHOD );
  $dec = $crypt->decrypt64( $_COOKIE[ USER_COOKIE_NAME ] );
  if( ! $dec ) {
    return false;
  }
  $value = json_decode( $dec, true );
  if( is_array( $value ) && $value['secret'] == CS_SECRET ) {
    return $value['id'];
  }
  return false;
}

function authenticate( $un, $pw ) {
  // Create CURL object and set parameters
  $curl = curl_init( AUTH_URL );
  curl_setopt($curl, CURLOPT_POSTFIELDS,
                     sprintf( AUTH_TMPL, $un, $pw ) );
  curl_setopt($curl, CURLOPT_POST,           true  );
  curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false );
  curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false );
  curl_setopt($curl, CURLOPT_RETURNTRANSFER, true  );
  curl_setopt($curl, CURLOPT_HTTPHEADER,     AUTH_HEAD );

  // Run authentication - and extract tags.
  preg_match_all( '/<([ab]:[^>]+)>([^<]+)<\/\\1>/',
   curl_exec( $curl ), $matches );

  // Map tags to values
  $response = array_combine( $matches[1], $matches[2] );

  // Random sleep - helps confuse hackers!!!
  usleep( rand( MIN_SLEEP, rand( MIN_SLEEP, MAX_SLEEP ) ) );

  // No membership number - so return false.
  if( ! array_key_exists( 'a:MembershipNumber', $response ) ) {
    return false;
  }

  // Return id/username/name...
  return [
    'id' => $response['a:MembershipNumber'],
    'un' => $response['a:UserName'],
    'fn' => $response['b:FirstName'],
    'ln' => $response['b:LastName']
  ];
}

