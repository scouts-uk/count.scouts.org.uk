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
// Created: Jun 2021 - moved config into file
//
// Version history:
//  2021-06-01 - importing.

include_once( 'config-site.php' );
// Base number in compass - makes downloads smaller!
const OFFSET           = 10000000;

// Related census ID - source of active groups/sections
const CENSUS_ID        = 22;

// Login sleep parameters....
const MIN_SLEEP        =  10000;
const MAX_SLEEP        = 500000;

