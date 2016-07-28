xquery version "1.0-ml";

module namespace geo = "http://marklogic.com/ns/geocode-lib";

(:import module namespace c = "http://marklogic.com/roxy/config" at "/app/config/config.xqy";:)

declare namespace gn = "http://geonames.org";

declare variable $CACHE := "/config/geocode-cache.xml";

declare variable $ABBREVIATIONS :=
    xdmp:from-json-string('{"vist":"vis", "crest":"crst", "avn":"ave", "northwest":"NW", "hiwy":"hwy", "mntns":"mtns", "bridge":"brg", "pkwys":"pkwy", "bot":"btm", "rnchs":"rnch", "club":"clb", "mtin":"mtn", "plaines":"plns", "street":"st", "throughway":"trwy", "northeast":"NE", "mntn":"mtn", "jctns":"jcts", "villages":"vlgs", "frry":"fry", "causeway":"cswy", "villg":"vlg", "vista":"vis", "landing":"lndg", "well":"wl", "expw":"expy", "prr":"pr", "ht":"hts", "freeway":"fwy", "junctions":"jcts", "stravenue":"stra", "valley":"vly", "rapids":"rpds", "spngs":"spgs", "vally":"vly", "tunnel":"tunl", "villag":"vlg", "div":"dv", "tr":"trl", "ford":"frd", "canyn":"cyn", "crssing":"xing", "knoll":"knl", "gateway":"gtwy", "lock":"lck", "causway":"cswy", "drives":"drs", "forge":"frg", "mnt":"mt", "radiel":"radl", "annex":"anx", "freewy":"fwy", "av":"ave", "cntr":"ctr", "hrbor":"hbr", "vsta":"vis", "cmp":"cp", "crossing":"xing", "extensions":"exts", "drv":"dr", "south":"S", "key":"ky", "vlly":"vly", "radial":"radl", "strave":"stra", "mssn":"msn", "underpass":"upas", "juncton":"jct", "sprngs":"spgs", "pines":"pnes", "squares":"sqs", "harbr":"hbr", "summit":"smt", "trpk":"tpke", "turnpk":"tpke", "bluffs":"blfs", "boulevard":"blvd", "centr":"ctr", "ferry":"fry", "east":"E", "forest":"frst", "cresent":"cres", "avenue":"ave", "lodge":"ldg", "parkway":"pkwy", "frt":"ft", "passage":"psge", "gardn":"gdn", "green":"grn", "prarie":"pr", "rapid":"rpd", "prairie":"pr", "square":"sq", "alley":"aly", "brooks":"brks", "crsnt":"cres", "estates":"ests", "harbor":"hbr", "mill":"ml", "shore":"shr", "grov":"grv", "spng":"spg", "drive":"dr", "la":"ln", "shoals":"shls", "traces":"trce", "trnpk":"tpke", "ridges":"rdgs", "viadct":"via", "branch":"br", "rivr":"riv", "crssng":"xing", "beach":"bch", "crossroad":"xrd", "ports":"prts", "parks":"park", "corners":"cors", "grdns":"gdns", "pine":"pne", "sqre":"sq", "views":"vws", "canyon":"cyn", "camp":"cp", "grden":"gdn", "tunnl":"tunl", "hgts":"hts", "streets":"sts", "burgs":"bgs", "dale":"dl", "holws":"holw", "place":"pl", "height":"hts", "trails":"trl", "cnter":"ctr", "mountin":"mtn", "locks":"lcks", "terrace":"ter", "fort":"ft", "islnds":"iss", "statn":"sta", "circles":"cirs", "crcl":"cir", "neck":"nck", "springs":"spgs", "inlet":"inlt", "burg":"bg", "gtway":"gtwy", "tpk":"tpke", "track":"trak", "trk":"trak", "trls":"trl", "tunls":"tunl", "rvr":"riv", "orchard":"orch", "forests":"frst", "courts":"cts", "pikes":"pike", "ville":"vl", "stn":"sta", "cent":"ctr", "tunnels":"tunl", "turnpike":"tpke", "points":"pts", "trace":"trce", "exp":"expy", "boulv":"blvd", "extension":"ext", "expr":"expy", "gardens":"gdns", "jctn":"jct", "plaza":"plz", "spurs":"spur", "shoal":"shl", "cliffs":"clfs", "mntain":"mtn", "shoar":"shr", "view":"vw", "squ":"sq", "bypas":"byp", "southwest":"SW", "meadow":"mdw", "falls":"fls", "grove":"grv", "union":"un", "anex":"anx", "plza":"plz", "lndng":"lndg", "pk":"park", "straven":"stra", "glens":"glns", "field":"fld", "corner":"cor", "fields":"flds", "ally":"aly", "sqr":"sq", "estate":"est", "forg":"frg", "brdge":"brg", "bypa":"byp", "fords":"frds", "express":"expy", "missn":"msn", "unions":"uns", "hill":"hl", "greens":"grns", "creek":"crk", "terr":"ter", "valleys":"vlys", "trail":"trl", "groves":"grvs", "havn":"hvn", "vst":"vis", "glen":"gln", "extn":"ext", "coves":"cvs", "bottm":"btm", "garden":"gdn", "strvnue":"stra", "trafficway":"trfy", "str":"st", "strt":"st", "walks":"walk", "lanes":"ln", "manors":"mnrs", "wy":"way", "mountains":"mtns", "ranch":"rnch", "motorway":"mtwy", "streme":"strm", "hllw":"holw", "byps":"byp", "plains":"plns", "expressway":"expy", "shoars":"shrs", "lights":"lgts", "sprng":"spg", "orchrd":"orch", "islands":"iss", "jction":"jct", "course":"crse", "cen":"ctr", "lodg":"ldg", "meadows":"mdws", "medows":"mdws", "allee":"aly", "bluff":"blf", "dvd":"dv", "island":"is", "junctn":"jct", "lane":"ln", "ridge":"rdg", "hollows":"holw", "parkwy":"pkwy", "avenu":"ave", "route":"rte", "junction":"jct", "harb":"hbr", "paths":"path", "crescent":"cres", "ck":"crk", "extnsn":"ext", "station":"sta", "villiage":"vlg", "vill":"vlg", "village":"vlg", "trks":"trak", "divide":"dv", "mount":"mt", "light":"lgt", "ldge":"ldg", "bypass":"byp", "crsent":"cres", "highwy":"hwy", "west":"W", "brnch":"br", "strvn":"stra", "mountain":"mtn", "flat":"flt", "crecent":"cres", "cliff":"clf", "road":"rd", "tracks":"trak", "point":"pt", "crt":"ct", "knolls":"knls", "stravn":"stra", "parkways":"pkwy", "dam":"dm", "frwy":"fwy", "southeast":"SE", "cnyn":"cyn", "river":"riv", "rdge":"rdg", "bluf":"blf", "circ":"cir", "manor":"mnr", "annx":"anx", "plain":"pln", "prk":"park", "cove":"cv", "center":"ctr", "court":"ct", "keys":"kys", "crcle":"cir", "mission":"msn", "rad":"radl", "viaduct":"via", "highway":"hwy", "common":"cmn", "centers":"ctrs", "fork":"frk", "grdn":"gdn", "gatewy":"gtwy", "isles":"isle", "bayoo":"byu", "north":"N", "spring":"spg", "bayou":"byu", "tunel":"tunl", "roads":"rds", "loops":"loop", "curve":"curv", "hway":"hwy", "avnue":"ave", "cr":"crk", "ovl":"oval", "harbors":"hbrs", "hiway":"hwy", "pky":"pkwy", "brook":"brk", "stream":"strm", "gatway":"gtwy", "hollow":"holw", "vdct":"via", "flats":"flts", "strav":"stra", "driv":"dr", "lake":"lk", "bend":"bnd", "circl":"cir", "knol":"knl", "heights":"hts", "port":"prt", "ranches":"rnch", "hills":"hls", "arcade":"arc", "cape":"cpe", "sumit":"smt", "boul":"blvd", "forges":"frgs", "frway":"fwy", "bottom":"btm", "pkway":"pkwy", "shores":"shrs", "circle":"cir", "islnd":"is", "sqrs":"sqs", "lakes":"lks", "skyway":"skwy", "wells":"wls", "loaf":"lf", "sumitt":"smt", "forks":"frks", "mills":"mls", "centre":"ctr", "overpass":"opas", "aven":"ave", "crscnt":"cres", "rest":"rst", "haven":"hvn"}');

declare variable $GEONAMES-URI := "http://van-dev1.demo.marklogic.com:8005";

declare function geo:lookup-abbrev($code as xs:string) as xs:string?
{
  (map:get($ABBREVIATIONS, $code), $code)[1]
};

declare function geo:normalize-address($addr as xs:string?)
{
  let $toks as xs:string* :=
    for $tok in fn:tokenize($addr, " ")
    let $tok := fn:replace($tok, "[.#,]", "")
    return
      geo:lookup-abbrev($tok)
  return
    fn:string-join($toks, " ")
};

declare function geo:geocode($addr-str as xs:string?)
{
  if ($addr-str) then
    let $geo-cache := geo:cache-lookup($addr-str)
    return
      if ($geo-cache) then
        $geo-cache
      else
        let $loc := geo:geonames-geocode($addr-str)
        (:let $loc := geo:google-geocode($addr-str):)
        return
        (
          geo:cache-record($addr-str, $loc),
          $loc
        )
    else ()
};

declare function geo:cache-lookup($loc-str)
{
  xdmp:invoke-function(function() {
    /geo-cache[@key = $loc-str]/node()
  })
};

declare function geo:cache-record($loc-str, $loc-record)
{
  xdmp:eval('
    declare variable $loc-str external;
    declare variable $loc-record external;

    xdmp:document-insert(
      "/geo-cache/" || fn:string(xdmp:random()) || ".xml",
      <geo-cache key="{$loc-str}">{$loc-record}</geo-cache>,
      xdmp:default-permissions(),
      "geo-cache"),
    xdmp:commit()',

    (
      xs:QName("loc-str"), $loc-str,
      xs:QName("loc-record"), $loc-record
    ),
    <options xmlns="xdmp:eval">
      <transaction-mode>update</transaction-mode>
    </options>)
};

declare function geo:google-geocode($location)
{
  geo:google-geocode($location, 1)
};

declare function geo:google-geocode($location, $request-count)
{
  (:xdmp:log($location),:)
  <loc lat="" lng=""/>
(:  let $url := fn:concat("http://maps.google.com/maps/api/geocode/xml?address=", xdmp:url-encode($location), "&amp;sensor=false")
  let $response := xdmp:http-get($url,
    <options xmlns="xdmp:document-get">
    </options>)
  let $geo-resp := $response[2]
  return
    if ($geo-resp/status = "OK") then
      <loc
        lat="{ $geo-resp/result/geometry/location/lat/fn:string() }"
        lng="{ $geo-resp/result/geometry/location/lng/fn:string() }"/>
    else if($geo-resp/status = "OVER_QUERY_LIMIT") then
      if ($request-count >= 2) then
        xdmp:log("Daily google geocode request quota exceeded")
      else
      (
        xdmp:sleep(2100),
        geo:google-geocode($location, $request-count + 1)
      )
    else
    (
      xdmp:log("Google geo-code response: " || $geo-resp/status)
    ):)
};

declare function geo:geonames-geocode($location)
{
  <loc lat="" lng=""/>(:
  let $response := xdmp:http-get(
    fn:concat($GEONAMES-URI, "/geocode.xqy?name=", xdmp:url-encode($location))
  )
  return
    element loc
    {
      $response/gn:geoname/gn:location/@lat,
      attribute lng { fn:data($response/gn:geoname/gn:location/@lon) }
    }:)
};

