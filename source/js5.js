(function(d){
'use strict';
window._={
  // Find elements (first param optional - use document as el if none give.
  qs:    function(el,s)   { if('string'===typeof el) { s=el; el=d; }      return s==='' ? el : el.querySelector(s);        },
  qm:    function(el,s)   { if('string'===typeof el) { s=el; el=d; }      return Array.from(document.querySelectorAll(s)); },
  // Apply function to set of elements
  m:     function(el,s,f) { if('string'===typeof el) { f=s; s=el; el=d; } this.qm(el,s).forEach(f);                        },
  s:     function(el,s,f) { if('string'===typeof el) { f=s; s=el; el=d; } var z=this.qs(el,s); if(z) f(z);                 },
  // Active/inactive class
  dis:   function(el)     { el.classList.remove('active');          },
  act:   function(el)     { el.classList.add('active');             },
  isact: function(el)     { return el.classList.contains('active'); },
  // Turn on and off elements.
  st:    function(el,di)  { this.qs(el).style.display=di;           },
  block: function(el)     { this.st(el,'block');                    },
  inline:function(el)     { this.st(el,'inline');                   },
  flex:  function(el)     { this.st(el,'flex');                     },
  hide:  function(el)     { this.st(el,'none');                     },
  // AJAX/XHR
  get:   function(url,callback){
    var h=new XMLHttpRequest(); h.overrideMimeType('application/json'); h.open('GET',url); h.onreadystatechange=function(){
      if(h.readyState==4&&h.status=='200'){callback(h.responseText);} }; h.send(null);                                     }
};}(document));
