/*
========================================================================

The Scout Association's Census system - Head count summary - Javascript

========================================================================

  This file is part of The Scout Association's Census system
  (ScoutCensus).

  ScoutCensus is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  ScoutCensus is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with ScoutCensus. If not, see <https://www.gnu.org/licenses/>.

========================================================================

  Copyright The Scout Association - 2021
  Developer - James Smith (james@curtissmith.me.uk)

========================================================================

This software uses the js5 package by James Smith - a small portion
of which is included in this file. This is used to simplify the
manipulation of webpages and transmission of data. See:

  https://github.com/drbaggy/js5

========================================================================
*/

(function(){
  'use strict';
  function q(s){ return document.querySelector('#'+s); }
  function b(s){ q(s).style.display='block'; }
  function h(s){ q(s).style.display='none'; }
  q('p').onclick = q('px').onclick = function() { h('p');h('px'); }
  q('a').onclick = function() {b('p');b('px');
    q('p').innerHTML =
    '<h2>Youth membership count - October 2021</h2>' +
    '<p>Rather than a full census this October, you just need to supply a count of the ' +
      'number of young people in your section. To do so please navigate to your section, '+
      'and send the numbers.</p>' +
    '<p>This will:</p>'+
    '<ul>'+
      '<li>inform The Scout Association how Scouting is recovering;</li>'+
      '<li>target support;</li>'+
      '<li>make better estimates of budgets at District, County and national levels.</li>'+
    '</ul>'+
    '<p class="footer">click anywhere to close</p>';
  };
}());
