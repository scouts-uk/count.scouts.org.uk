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

(function $main(d){
  'use strict';
  // js5 package... see
  var _={
    qs:    function(el) {     return d.querySelector(el);   },
    st:    function(el,di) {  this.qs(el).style.display=di; },
    block: function(el) {     this.st(el,'block');          },
    flex:  function(el) {     this.st(el,'flex');           },
    hide:  function(el) {     this.st(el,'none');           },
    click: function(el,f) {   var t = this.qs(el); if( t ) t.onclick = f; },
    change: function(el,f) {  var t = this.qs(el); if( t ) t.onchange = f; },
    get:   function(url,callback){
      var h=new XMLHttpRequest(); h.overrideMimeType('application/json');
      h.open('GET',url); h.onreadystatechange=function $ors(){
      if(h.readyState===4&&h.status===200){callback(h.responseText);} }; h.send(null);                                     }
  };

  var d_cache = {}, c_s = _.qs('#c'), d_s = _.qs('#d'), g_s = _.qs('#g'), s_s = _.qs('#s'),
      d_str, g_str, s_str, ov = '<option value="', ox = '</option>', det;

  function $x(l) { return l.map(function($){ return ov+$[0]+'">'+$[1]+' ('+(10000000+$[0])+')'+ox;}    ).join(''); }
  function x(n,l) { return ov+'">== Select '+n+' =='+ox + $x(l); }
  function xx(n,l,ll) { return ov+'">== Select '+n+' =='+ox + '<optgroup label="Scout Groups">'+$x(l)+
   '</optgroup><optgroup label="Explorer Scout Units">'+$x(ll)+'</optgroup>'; }
  function show_form( v, f ) {
    if( v === '' ) {
      _.hide('#n');
    } else {
      _.flex('#n');
    }
    det = f === 'u' ? g_str[1] : s_str[2];
    var vv = parseInt(v);
    det = det.filter( function($) {return $[0] === vv;} ).pop();
    _.qs( '#y' ).value = det[2]>0 ? det[2] : '';
    _.qs('#n').scrollIntoView();
  }
  // Show district - populate the group/unit drop downs and hide the number part of the form...
  function show_district( ) {
    g_s.innerHTML = xx('Group/Unit',g_str[0],g_str[1]);
   // u_s.innerHTML = x('Unit',g_str[1]);
    _.block('#h');_.hide('#n');
    _.qs('#h').scrollIntoView();
  }
  function update(flag) {
    _.block('#px');
    _.get('/'+det[0]+'/'+_.qs('#y').value+'/'+flag,function( resptext ) {
      var res = JSON.parse( resptext );
      if( res[0] === 'OK' ) {
        message( res[1] );
      } else if( res[0] === 'CNF' ) {
        message( res[1] );
      }
    } );
  }
  function message( v ) {
    _.block('#p');
    _.block('#px');
    _.qs('#p').innerHTML = v + '<p class="footer">click anywhere to close</p>';
    var q = _.qs('#p input[type="button"]');
    if( q ) {
      q.onclick = function $upd(e){ e.stopPropagation(); update(1); };
    }
  }
  function rpop() { _.hide('#p');_.hide('#px'); }
  _.click('#p', rpop );
  _.click('#px',rpop );
  _.click('#a',function $op() { message(
    '<h2>Youth membership count - October 2021</h2>' +
    '<p>Rather than a full census this October, you just need to supply a count of the ' +
      'number of young people in your section. To do so please navigate to your section, '+
      'and send the numbers.</p>' +
    '<p>This will:</p>'+
    '<ul>'+
      '<li>inform The Scout Association how Scouting is recovering;</li>'+
      '<li>target support;</li>'+
      '<li>make better estimates of budgets at District, County and national levels.</li>'+
    '</ul>' ); });

  // County/District structure gets inserted here!
  /* */ /* */
  _.hide('#e');
  _.hide('#h');
  _.hide('#t');
  _.hide('#n');
  c_s.innerHTML = x('County',str);
  _.block('#f');
  // Add functionality to the county select drop down.
  // When changes we hide the form, the section area and the group area..
  if( _.qs('#z') ) { _.click('#z', function $lo() { d.location.href = '/logout'; } ); }
  c_s.onchange = function $cty() {
    var $self = this;
    _.hide('#n'); _.hide('#t'); _.hide('#h');
    // If we unselect the county then we hide the district are...
    if( this.value === '' ) {
      _.hide('#e');
    // Otherwise we get the District list from str and show the district drop down.
    } else {
      var v = parseInt($self.value);
      d_str = str.filter(function($){return $[0] === v;} ).pop();
      d_s.innerHTML = x('District',d_str[2]);
      _.block('#e');
      _.qs('#e').scrollIntoView();
    }
  };
  // Add funtionality to the change district...
  // Hide the seciton are...
  // If we unselect district then we hide the group area.
  // Otherwise we check to see if we have already retrieved district information
  // and stored it in the in memory cache - if we set g_str to it and call show_district
  // if we don't then we fetch it from the database, set g_str and then call show_district
  d_s.onchange = function $dst() {
    var $dist = this, dist_id = this.value;
    _.hide('#t');
    if( dist_id === '' ) {
      _.hide('#h');
    } else {
      if( Object.prototype.hasOwnProperty.call( d_cache, dist_id )) { // Already got district
        // CHECK VALUE OF district hasn't changed....
        g_str = d_cache[dist_id];         // So grab from cache
        show_district();                        // And render
      } else {
        // Fetch district details - and store in cache before rendering group/unit lists..
        _.get('/'+this.value,function( resptext ) {
          var t_str = JSON.parse( resptext );
          d_cache[dist_id] = t_str;
          if( $dist.value === dist_id ) {
            g_str = t_str;
            show_district( );
          }
        } );
      }
    }
  };
  // Add functionality to change group
  // We reset the section and unit drop downs and hide the form
  // If we deselect the group - then we hide the section drop down
  // Otherwise we populate the section dropdown.
  g_s.onchange = function $grp() {
    var $self = this;
    // Check to see if unit!!
    s_s.selectedIndex = 0;
    _.hide('#n');
    if( this.value === '' ) {
      _.hide('#t');
    } else {
      var v = parseInt($self.value);
      var is_unit = g_str[1].filter( function($) { return $[0] === v; } ).length;
      if( is_unit ) {
        show_form( this.value, 'u' );
      } else {
        s_str = g_str[0].filter( function($) {return $[0] === v;} ).pop();
        s_s.innerHTML = x('Section',s_str[2]);
        _.block('#t');
        s_s.scrollIntoView();
      }
    }
  };
  // Add functionality to the unit drop down
  // Reset group/section index, hide section from
  // Show numbers form
  // Section change..
  // Show hide form as appropiate...
  s_s.onchange = function $sct() {
    show_form(this.value,'s');
  };
  _.click('#n input[type="button"]',function $sub(){ update(0); });
}(document));
