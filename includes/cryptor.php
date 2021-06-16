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

class Cryptor {
  protected $method = 'chacha20-poly1305'; // default
  private   $key;

  protected function iv_bytes() {
                  return openssl_cipher_iv_length($this->method);   }
  public function encrypt64(  $data ) {
                  return base64_encode(  $this->encrypt( $data ) ); }
  public function decrypt64(  $data ) {
                  return $this->decrypt( base64_decode(  $data ) ); }
  public function encrypthex( $data ) {
                  return bin2hex(        $this->encrypt( $data ) ); }
  public function decrypthex( $data ) {
                  return $this->decrypt( hex2bin(        $data ) ); }

  public function __construct( $key = FALSE, $method = FALSE ) {
    if(!$key) { // if you don't supply your own key,
                // this will be the default
      $key = gethostname().'|'.ip2long($_SERVER['SERVER_ADDR']);
    }
    // If string key is converted to binary usingl SHA256 digest!
    $this->key = ctype_print($key)
               ? openssl_digest( $key, 'SHA256', TRUE )
               : $key;
    if($method) {
      if( in_array( $method, openssl_get_cipher_methods() ) ) {
        $this->method = $method;
      } else {
        die( __METHOD__.": unrecognised encryption method: {$method}" );
      }
    }
  }

  public function encrypt($data) {
    $iv = openssl_random_pseudo_bytes( $this->iv_bytes() );
    $encrypted_string = bin2hex($iv) . openssl_encrypt(
      $data, $this->method, $this->key, 0, $iv );
    return $encrypted_string;
  }

  public function decrypt($data) {
    $iv_strlen = 2  * $this->iv_bytes();
    if(preg_match("/^(.{" . $iv_strlen . "})(.+)$/", $data, $regs)) {
      list(, $iv, $crypted_string) = $regs;
      $decrypted_string = openssl_decrypt(
        $crypted_string, $this->method, $this->key, 0, hex2bin($iv) );
      return $decrypted_string;
    } else {
      return FALSE;
    }
  }
}
