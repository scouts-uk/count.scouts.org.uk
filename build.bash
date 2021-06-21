#!/bin/bash

a=$(($(date +%s%N)/1000000));
b=$a
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  BASE="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
BASE="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
ROOT="$( dirname "$BASE" )"
ROOT="$( dirname "$ROOT" )"
METHOD=sha512            #METHOD=sha256
tm () {
  c=$(($(date +%s%N)/1000000));
  printf '      Duration: %6dms    Elapsed: %6dms' "$((c-b))" "$((c-a))";
  b=$c;
  echo
}
if [[ ! -d "$BASE/checksums" ]]; then mkdir $BASE/checksums; fi
if [[ ! -d "$BASE/working"   ]]; then mkdir $BASE/working; fi
if [[ ! -d "$BASE/dist"      ]]; then mkdir $BASE/dist; fi
echo
echo '################################################################'
echo '##                                                            ##'
echo '##  Building web-interface for youth membership census tool   ##'
echo '##                                                            ##'
echo '################################################################'
echo
echo IN $BASE
echo

echo
echo "  Create PHP config file"
$BASE/scripts/make-config.pl
tm

cp $BASE/source/logo-compact.svg $BASE/source/logo.svg $BASE/source/login.js $BASE/working
echo
echo "  Retrieving districts from database and updating sections.js"
## Retrieve data from census database (and build nested json structure)
SIZE_JSON=`$BASE/scripts/update-sections.pl`
tm

echo
echo "  Fix CSS font families"
$BASE/scripts/write-arial.pl
tm

echo
echo "  Base 64 encoding favicon.png/build ico file"
## Convert favicon.ico to base64 encoded data string
convert -resize x16 -gravity center -crop 16x16+0+0 $BASE/source/favicon.png -flatten -colors 16 $BASE/htdocs/favicon.ico
echo "data:image/png;base64,$(base64 -w 0 $BASE/source/favicon.png)"\
  > $BASE/working/favicon.png.b64
tm

echo
echo "  Building development HTML"
## Merge together and optimize HTML into a single line!
$BASE/scripts/optimize-html.pl X
tm

## Compress javascript using Google closure compiler
JS=`sha512sum $BASE/working/script.js`
JS_OLD=`if [[ -f "$BASE/checksums/script.js-sum" ]]; then cat $BASE/checksums/script.js-sum; fi`
LI=`sha512sum $BASE/working/login.js`
LI_OLD=`if [[ -f "$BASE/checksums/login.js-sum" ]]; then cat $BASE/checksums/login.js-sum; fi`
if [[ "$JS" != "$JS_OLD" ]]
then
  echo
  echo "  Compressing Javascript [script]"
  echo -n '/*<![CDATA[*/'`google-closure-compiler --js $BASE/working/script.js -O advanced`'/*]]>*/' > $BASE/working/script-opt.js
  c=$(($(date +%s%N)/1000000));printf '      Duration: %6dms    Elapsed: %6dms' "$((c-b))" "$((c-a))";b=$c;echo
  sha512sum $BASE/working/script.js > $BASE/checksums/script.js-sum
else
  echo
  echo "  Javascript up to date"
fi
if [[ "$LI" != "$LI_OLD" ]]
then
  echo
  echo "  Compressing Javascript [login]"
  echo -n '/*<![CDATA[*/'`google-closure-compiler --js $BASE/working/login.js -O advanced`'/*]]>*/' > $BASE/working/login-opt.js
  c=$(($(date +%s%N)/1000000));printf '      Duration: %6dms    Elapsed: %6dms' "$((c-b))" "$((c-a))";b=$c;echo
  sha512sum $BASE/working/login.js > $BASE/checksums/login.js-sum
else
  echo
  echo "  Javascript up to date"
fi

## Compress CSS using Yahoo's yuicompressor
ARIAL=`sha512sum $BASE/working/arial.css`
ARIAL_OLD=`if [[ -f "$BASE/checksums/arial.css-sum" ]]; then cat $BASE/checksums/arial.css-sum; fi`
NUNITO=`sha512sum $BASE/working/nunito.css`
NUNITO_OLD=`if [[ -f "$BASE/checksums/nunito.css-sum" ]]; then cat $BASE/checksums/nunito.css-sum; fi`


if [[ "$ARIAL" != "$ARIAL_OLD" || "$NUNITO" != "$NUNITO_OLD" ]]
then
  echo
  echo "  Compressing CSS"
  
  if [[ "$ARIAL" != "$ARIAL_OLD" ]]
  then
    echo "    Compressing arial/sans version"
    /usr/bin/java -jar /www/utilities/jars/yuicompressor.jar -o $BASE/working/arial-opt.css $BASE/working/arial.css
    sha512sum $BASE/working/arial.css > $BASE/checksums/arial.css-sum
  fi
  if [[ "$NUNITO" != "$NUNITO_OLD" ]]
  then
    echo "    Compressing Nunito/arial/sans version"
    /usr/bin/java -jar /www/utilities/jars/yuicompressor.jar -o $BASE/working/nunito-opt.css $BASE/working/nunito.css
    sha512sum $BASE/working/nunito.css > $BASE/checksums/nunito.css-sum
  fi
  c=$(($(date +%s%N)/1000000));printf '      Duration: %6dms    Elapsed: %6dms' "$((c-b))" "$((c-a))";b=$c;echo
else
  echo
  echo "  CSS up to date"
fi

echo
echo "  Building live HTML"
## Merge together and optimize HTML into a single line!
$BASE/scripts/optimize-html.pl
tm

## Comptute the sha512 hashes of the files and process them into the CSP file...
echo
echo "  Generating CSP"
bef=`cat $BASE/checksums/js-sha.txt $BASE/checksums/css-sha.txt | md5sum`;
echo $METHOD-`cat $BASE/working/script-opt.js   | openssl $METHOD -binary | openssl base64 -A` >  $BASE/checksums/js-sha.txt
echo $METHOD-`cat $BASE/working/script.js       | openssl $METHOD -binary | openssl base64 -A` >> $BASE/checksums/js-sha.txt
echo $METHOD-`cat $BASE/working/login.js        | openssl $METHOD -binary | openssl base64 -A` >> $BASE/checksums/js-sha.txt
echo $METHOD-`cat $BASE/working/login-opt.js    | openssl $METHOD -binary | openssl base64 -A` >> $BASE/checksums/js-sha.txt
echo $METHOD-`cat $BASE/working/nunito-opt.css  | openssl $METHOD -binary | openssl base64 -A` >  $BASE/checksums/css-sha.txt
echo $METHOD-`cat $BASE/working/nunito.css      | openssl $METHOD -binary | openssl base64 -A` >> $BASE/checksums/css-sha.txt
echo $METHOD-`cat $BASE/working/arial.css       | openssl $METHOD -binary | openssl base64 -A` >> $BASE/checksums/css-sha.txt
echo $METHOD-`cat $BASE/working/arial-opt.css   | openssl $METHOD -binary | openssl base64 -A` >> $BASE/checksums/css-sha.txt
aft=`cat $BASE/checksums/js-sha.txt $BASE/checksums/css-sha.txt | md5sum`;

$BASE/scripts/generate-csp.pl
tm

## Switch in here to decide whether to generate live or dev site...
if [[ "`cat $BASE/config.yaml | yq e '.development' -`" == "false" ]]
then
  cp $BASE/dist/sections.html     $BASE/includes/main-page.php
  cp $BASE/dist/login.html        $BASE/includes/login-page.php
else
  cp $BASE/dist/sections-dev.html $BASE/includes/main-page.php
  cp $BASE/dist/login-dev.html    $BASE/includes/login-page.php
fi


## Calculate sizes of HTML files and "data" elements embedded within
SIZE_PNG=`stat --printf="%s" $BASE/working/favicon.png.b64`
SIZE_SVG=`stat --printf="%s" $BASE/working/logo-compact.svg`
SIZE_DEV=`stat --printf="%s" $BASE/dist/sections-dev.html`
SIZE_LIVE=`stat --printf="%s" $BASE/dist/sections.html`
LOGIN_DEV=`stat --printf="%s" $BASE/dist/login-dev.html`
LOGIN_LIVE=`stat --printf="%s" $BASE/dist/login.html`
((SIZE_DEV_EX=SIZE_DEV-SIZE_PNG-SIZE_SVG-SIZE_JSON))
((SIZE_LIVE_EX=SIZE_LIVE-SIZE_PNG-SIZE_SVG-SIZE_JSON))
((LOGIN_DEV_EX=LOGIN_DEV-SIZE_PNG-SIZE_SVG))
((LOGIN_LIVE_EX=LOGIN_LIVE-SIZE_PNG-SIZE_SVG))
LOGIN_LIVE_COMPRESSED=`cat $BASE/dist/login.html | brotli -c | wc -c`
LOGIN_DEV_COMPRESSED=`cat $BASE/dist/login-dev.html | brotli -c | wc -c`
SIZE_LIVE_COMPRESSED=`cat $BASE/dist/sections.html | brotli -c | wc -c`
SIZE_DEV_COMPRESSED=`cat $BASE/dist/sections-dev.html | brotli -c | wc -c`

## Just a quick summary....
echo
echo ================================================================
echo
echo "  Summary"
echo "  ======="
echo 
echo -n "    Size of dist.json:  ";printf "%7d" $SIZE_JSON; echo
echo -n "    Size of icon.b64:   ";printf "%7d" $SIZE_PNG;  echo
echo -n "    Size of logo.svg:   ";printf "%7d" $SIZE_SVG;  echo
echo
echo -n "    Size of live html:  ";printf "%7d" $SIZE_LIVE;
  echo -n "  (";printf "%7d" $SIZE_LIVE_EX; echo -n ") [";
  printf "%7d" $SIZE_LIVE_COMPRESSED;echo "]"
echo -n "    Size of dev html:   ";printf "%7d" $SIZE_DEV;
  echo -n "  (";printf "%7d" $SIZE_DEV_EX;  echo -n ") [";
  printf "%7d" $SIZE_DEV_COMPRESSED; echo "]"
echo
echo -n "    Size of live login: ";printf "%7d" $LOGIN_LIVE;
  echo -n "  (";printf "%7d" $LOGIN_LIVE_EX; echo -n ") [";
  printf "%7d" $LOGIN_LIVE_COMPRESSED;echo "]"
echo -n "    Size of dev login:  ";printf "%7d" $LOGIN_DEV;
  echo -n "  (";printf "%7d" $LOGIN_DEV_EX;  echo -n ") [";
  printf "%7d" $LOGIN_DEV_COMPRESSED; echo "]"
echo
echo -n "    Size of db script:  ";printf "%7d" `stat --printf="%s" $BASE/htdocs/index.php`; echo
echo
c=$(($(date +%s%N)/1000000));
printf '  Time taken to execute script:      %6dms'   "$((c-a))";echo
echo
if [[ "$aft" != "$bef" ]]
then
  echo '    #### '$METHOD hashes have updated - you will need
  echo '    #### 'to restart the apache instance
  echo '    #### '$ROOT/utilities/restart
  echo
fi
echo ================================================================
echo
