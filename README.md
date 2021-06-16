# Head count only census

This is the "public facing" application for the head count (password less) census code for October 2021

## Structure:

  * `build.bash` - build script
  * `checksums` - [generated] stores checksums of javascript and css files {to see if mungers need running}
  * `dist` - [generated] mark-up for "live"/"dev" page
  * `htdocs` - main htdocs directory (just contains the index.php) script
  * `includes` - php files for site
  * `LICENSE` - License
  * `README.md` - This file
  * `scripts` - scripts used to generate final HTML files
  * `source` - templates, css, javascript and images
  * `working` - [generated] optimized javascript/css/images

## Front end templates

  * `template.html` - Page with placeholders for the javascript, css and images
  * `sections.js` - The front end workhorse - handles showing/hiding drop downs and retrieving/sending from the server (`sec.php`)
  * `sections-nunito.css` / `sections-arial.css` - CSS for the page - with Google font 'Nunito' or just plain "Arial">...
  * `logo.svg` / `logo-compact.svg` - main Scout logo used at the top of the form, `logo-compact.svg` is a more compact version which is about half the size of `logo.svg`
  * `favicon.png` - Small 16x16 png favicon file

## Backend script

  * `index.php` - has two purposes
    1. Return the structure of Groups/Sections and Units within a district
    2. Update a youth count when requested from the webpage via XHR
    3. Implements passwords if required

## Management scripts

  * `build.bash` - Wrapper script that updates section, merges files into templates and generate the live and dev webpages.
  * `optimize-html.pl` - Used to merge the favicon, svg logo, CSS and Javascript into the page
  * `update-sections.pl` - Retrieve information about the County/District structure in the database into a JSON object.
  * `generate-csp.pl` - Generates a CSP file to include the SHA hashes of the javascript and CSS
  * `write-arial.pl` - Writes an "arial" version of the CSS {does not include google font files}

## Extra files:

  * `sections.html` - "Live web page" made by merging the optimized javascript and css
  * `sections-dev.html` - "Dev web page" made by merging the raw javascript and css
  * `favicon.png.b64` - Base 64 encode favicon png - so it can be embedded in the HTML
  * `sections-arial-opt.css` - "Packed CSS" - for arial only page (packed with YUIcompressor)
  * `sections-nunito-opt.css` - "Packed CSS" - for nunito/arial page (packed with YUIcompressor)
  * `sections-opt.js` - "Packed Javascript" - for the page (packed with Google closure compiler)
  * `sections.js.bak` - Back up for `sections.js` when `update-sections.pl` is run

