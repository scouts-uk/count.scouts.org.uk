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

(function(d){
  'use strict';
// js5 package... see
var _={
  qs:    function(el,s) {   if('string'===typeof el) { s=el; el=d; }      return s==='' ? el : el.querySelector(s);        },
  st:    function(el,di) {  this.qs(el).style.display=di;           },
  block: function(el) {     this.st(el,'block');                    },
  flex:  function(el) {     this.st(el,'flex');                     },
  hide:  function(el) {     this.st(el,'none');                     },
  click: function(el,f) {   var t = this.qs(el); if( t ) t.onclick = f; },
  change: function(el,f) {  var t = this.qs(el); if( t ) t.onchange = f; },
  get:   function(url,callback){
    var h=new XMLHttpRequest(); h.overrideMimeType('application/json'); h.open('GET',url); h.onreadystatechange=function(){
      if(h.readyState==4&&h.status=='200'){callback(h.responseText);} }; h.send(null);                                     }
};
  _.click('#p', function() { _.hide('#p');_.hide('#px'); });
  _.click('#px',function() { _.hide('#p');_.hide('#px'); });
  _.click('#a',function() { message(
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
  /*if( _.qs('#login')) { return; }*/
  _.hide('#e');
  _.hide('#h');
  _.hide('#t');
  _.hide('#n');
  var d_cache = {}, c_s = _.qs('#c'), d_s = _.qs('#d'), g_s = _.qs('#g'), u_s = _.qs('#u'), s_s = _.qs('#s'),
      d_str, g_str, s_str, ov = '<option value="', ox = '</option>', det;
  function x(n,d) { return ov+'">== Select '+n+' =='+ox + d.map(function(_){ return ov+_[0]+'">'+_[1]+' ('+(10000000+_[0])+')'+ox;}).join(''); }
  c_s.innerHTML = x('County',str);
  _.block('#f');
  // Add functionality to the county select drop down.
  // When changes we hide the form, the section area and the group area..
  /*_.click('#z', function() { d.location.href = '/logout'; });*/
  c_s.onchange = function() {
    var $self = this;
    _.hide('#n'); _.hide('#t'); _.hide('#h');
    // If we unselect the county then we hide the district are...
    if( this.value === '' ) {
      _.hide('#e');
    // Otherwise we get the District list from str and show the district drop down.
    } else {
      d_str = str.filter(function(_){return _[0] == $self.value;} ).pop();
      d_s.innerHTML = x('District',d_str[2]);
      _.block('#e');
    }
  };
  // Add funtionality to the change district...
  // Hide the seciton are...
  // If we unselect district then we hide the group area.
  // Otherwise we check to see if we have already retrieved district information and stored it in the in
  // memory cache - if we set g_str to it and call show_district
  // if we don't then we fetch it from the database, set g_str and then call show_district
  d_s.onchange = function() {
    var _dist = this, dist_id = this.value;
    _.hide('#t');
    if( dist_id === '' ) {
      _.hide('#h');
    } else {
      if( d_cache.hasOwnProperty(dist_id)) { // Already retrieved this district
        // CHECK VALUE OF district hasn't changed....
        g_str = d_cache[dist_id];         // So grab from cache
        show_district();                        // And render
      } else {
        // Fetch district details - and store in cache before rendering group/unit lists..
        _.get('/'+this.value,function( resptext ) {
          var t_str = JSON.parse( resptext );
          d_cache[dist_id]=t_str;
          if( _dist.value == dist_id ) {
            g_str = t_str;
            show_district( );
          }
        } );
      }
    }
  };
  // Show district - populate the group/unit drop downs and hide the number part of the form...
  function show_district( ) {
    g_s.innerHTML = x('Group',g_str[0]);
    u_s.innerHTML = x('Unit',g_str[1]);
    _.block('#h');_.hide('#n');
  }
  // Add functionality to change group
  // We reset the section and unit drop downs and hide the form
  // If we deselect the group - then we hide the section drop down
  // Otherwise we populate the section dropdown.
  g_s.onchange = function() {
    var $self = this;
    u_s.selectedIndex = s_s.selectedIndex = 0;
    _.hide('#n');
    if( this.value === '' ) {
      _.hide('#t');
    } else {
      s_str = g_str[0].filter( function(_) {return _[0] == $self.value;} ).pop();
      s_s.innerHTML = x('Section',s_str[2]);
      _.block('#t');
    }
  };
  // Add functionality to the unit drop down
  // Reset group/section index, hide section from
  // Show numbers form
  u_s.onchange = function() {
    g_s.selectedIndex = s_s.selectedIndex = 0 ; // reset group/section indecies
    _.hide('#t');
    // Show hide form as appropiate...
    show_form(this.value,'u');
  };
  // Section change..
  // Show hide form as appropiate...
  s_s.onchange = function() {
    show_form(this.value,'s');
  };
  function show_form( v, f ) {
    if( v === '' ) {
      _.hide('#n');
    } else {
      _.flex('#n');
    }
    det = f === 'u' ? g_str[1] : s_str[2];
    det = det.filter( function(_) {return _[0] == v;} ).pop();
    _.qs( '#y' ).value = det[2]>0 ? det[2] : '';
  }
  function message( v ) {
    _.block('#p');
    _.block('#px');
    _.qs('#p').innerHTML = v + '<p class="footer">click anywhere to close</p>';
    var q = _.qs('#p input[type="button"]');
    if( q ) {
      q.onclick = function(){ update(1); };
    }
  }
  _.click('#n input[type="button"]',function(){ update(0); });
  function update(flag) {
    _.get('/'+det[0]+'/'+_.qs('#y').value+'/'+flag,function( resptext ) {
      var res = JSON.parse( resptext );
      if( res.status == 'OK' ) {
        message( res.message );
      } else if( res.status == 'CONFIRMATION_REQ' ) {
        message( res.message );
      }
    } );
  }
}(document));
