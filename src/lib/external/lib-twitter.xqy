xquery version "1.0-ml";

(: with modifications from https://github.com/adamfowleruk/feedsxquery/blob/master/src/app/models/lib-twitter.xqy :)

module namespace tw = "http://marklogic.com/roxy/twitter";

import module namespace oa = "http://marklogic.com/ns/oauth" at "/lib/external/oauth.xqy";
import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace xh="xdmp:http";

(: CONFIGURATION ELEMENTS - CHANGE AT YOUR OWN RISK :)

declare variable $service-document :=
      <oa:service-provider realm="http://twitter.com">
       <oa:request-token>
         <oa:uri>http://twitter.com/oauth/request_token</oa:uri>
         <oa:method>GET</oa:method>
       </oa:request-token>
       <oa:user-authorization>
         <oa:uri>http://twitter.com/oauth/authorize</oa:uri>
       </oa:user-authorization>
       <oa:user-authentication>
         <oa:uri>http://twitter.com/oauth/authenticate</oa:uri>
         <oa:additional-params>force_login=true</oa:additional-params>
       </oa:user-authentication>
       <oa:access-token>
         <oa:uri>http://twitter.com/oauth/access_token</oa:uri>
         <oa:method>POST</oa:method>
       </oa:access-token>
       <oa:signature-methods>
         <oa:method>HMAC-SHA1</oa:method>
       </oa:signature-methods>
       <oa:oauth-version>1.0</oa:oauth-version>
       <oa:authentication>
         <oa:consumer-key>vllLqrxsDEQMVx0KNDA9fcg1N</oa:consumer-key>
         <oa:consumer-key-secret>kF6nx3I1FeuTK851EK8f4TyF9YgC7EskHEY4nDc5fPuhKLImy4</oa:consumer-key-secret>
       </oa:authentication>
      </oa:service-provider>;

  declare variable $access-token := "352494697-evQM8eZEte84662lFob4vT2H4dOTHeJlOU4uKmdE"; (: YOUR USER'S APP ACCESS TOKEN :)
  declare variable $access-token-secret := "cxTm3qUX8ZFubGEvgVngmLrtJ2HWOPwubwWpiPfO9lSnV"; (: YOUR USER'S APP ACCESS TOKEN SECRET :)

  declare variable $options
    := <oa:options>
       <screen_name>tmlukps</screen_name>
       <count>100</count>
       <page>1</page>
     </oa:options>;

  declare variable $optionssearch := <oa:options></oa:options>;

(: END CONFIGURATION ELEMENTS - DO NOT MODIFY PASSED THIS POINT!!! :)


(:
 : NB This module uses a test user account. This is rate limited. Please email adam.fowler@marklogic.com if you wish to use this,
 :    as it is used for demos.
 :)

(: UTILITY FUNCTIONS :)
declare function tw:repack($oaresult)
{
  $oaresult
};
(:
declare function tw:repack($oaresult as xs:string) as xs:string {
  (:)
  let $rawjsona := fn:substring-after($oaresult,"[")
  let $rawjson := fn:substring($rawjsona,1,fn:string-length($rawjsona) - 1)
  :)
  let $rawjson := fn:substring($oaresult,13)
    (:
  let $wrappedjson := fn:concat("{""response"": [",$rawjson, "]}")
  :)
  let $wrappedjson := fn:concat("{""response"":",$rawjson)
  return $wrappedjson
};
:)

(: CALLABLE FUNCTIONS :)
declare function tw:get-user-feed-json($lastid as xs:long?) (: as xs:string :) {
  let $opts := <oa:options>
       <screen_name>mluktfeed</screen_name>
       <count>100</count>
       <page>1</page>
       {if ($lastid) then
         <since_id>{$lastid}</since_id>
         else ()}
     </oa:options>

  let $oaresult := oa:signed-request($service-document,
                    "GET", "https://api.twitter.com/1.1/statuses/home_timeline.json",
                    $opts, $access-token, $access-token-secret)
  return
    if ($oaresult[1]/xh:code/fn:string() eq "200")
    then $oaresult[2]
    else (
      xdmp:log(xdmp:quote($oaresult[1]), "error"),
      xdmp:log(xdmp:quote($oaresult[2]), "error"),
      fn:error((), "OAUTH-ERROR", $oaresult[1]/xh:code/fn:string())
    )
  (:

  (: REMEMBER oaresult IS a string, not an xml node! :)
  let $wrappedjson := tw:repack($oaresult)
  return $wrappedjson
  :)
};

declare function tw:get-user-feed($lastid as xs:long?) as element() {
  json:transform-from-json(
    xdmp:from-json(
      tw:get-user-feed-json($lastid)))
};


declare function tw:search-json($query as xs:string) (: as xs:string  :) {
  let $search-params := <oa:options>
       <oa:q>{$query}</oa:q>
       <count>100</count>
       <result_type>recent</result_type>
     </oa:options>
  let $oaresult := oa:signed-request($service-document,
                    "GET", "https://api.twitter.com/1.1/search/tweets.json",
                    $search-params, $access-token, $access-token-secret)
  return
    if ($oaresult[1]/xh:code/fn:string() eq "200")
    then $oaresult[2]
    else (
      xdmp:log(xdmp:quote($oaresult[1]), "error"),
      xdmp:log(xdmp:quote($oaresult[2]), "error"),
      fn:error((), "OAUTH-ERROR", $oaresult[1]/xh:code/fn:string())
    )
  (:
  let $n := xdmp:log(fn:concat("tw:search-json: ",$oaresult))
  (: REMEMBER oaresult IS a string, not an xml node! :)
  let $wrappedjson := tw:repack($oaresult)
  return $wrappedjson
:)
};

declare function tw:search($query as xs:string) as element() {
  json:transform-from-json(
    xdmp:from-json(
      tw:search-json($query)))
};

declare function tw:geo-search-json($query as xs:string,$latitude as xs:string,$longitude as xs:string,$radiusmiles as xs:string) (: as xs:string :)
{
  let $search-params := <oa:options>
       <oa:q>{$query}</oa:q>
       <oa:geocode>{$latitude},{$longitude},{$radiusmiles}mi</oa:geocode>
       <count>100</count>
       <result_type>recent</result_type>
     </oa:options>
  let $oaresult := oa:signed-request($service-document,
                    "GET", "https://api.twitter.com/1.1/search/tweets.json",
                    $search-params, $access-token, $access-token-secret)
  return
    if ($oaresult[1]/xh:code/fn:string() eq "200")
    then $oaresult[2]
    else (
      xdmp:log(xdmp:quote($oaresult[1]), "error"),
      xdmp:log(xdmp:quote($oaresult[2]), "error"),
      fn:error((), "OAUTH-ERROR", $oaresult[1]/xh:code/fn:string())
    )
  (:
  let $n := xdmp:log(fn:concat("tw:search-json: ",$oaresult))
  (: REMEMBER oaresult IS a string, not an xml node! :)
  let $wrappedjson := tw:repack($oaresult)
  return $wrappedjson
  :)
};

declare function tw:geo-search($query as xs:string,$latitude as xs:string,$longitude as xs:string,$radiusmiles as xs:string) as element() {
  (:
  let $l := xdmp:log(fn:concat("TW:GEO-SEARCH: Query: ",$query,", lat: ",$latitude,", lon: ",$longitude,", radiusmiles: ",$radiusmiles))
  return
  :)
  json:transform-from-json(
    xdmp:from-json(
      tw:geo-search-json($query,$latitude,$longitude,$radiusmiles)))
};

declare function tw:profile-by-email-json($email as xs:string) (: as xs:string :) {
  let $search-params := <oa:options>
       <oa:q>{$email}</oa:q>
       <count>100</count>
     </oa:options>
  let $oaresult := oa:signed-request($service-document,
                    "GET", "https://api.twitter.com/1.1/users/search.json",
                    $search-params, $access-token, $access-token-secret)
  return
    if ($oaresult[1]/xh:code/fn:string() eq "200")
    then $oaresult[2]
    else (
      xdmp:log(xdmp:quote($oaresult[1]), "error"),
      xdmp:log(xdmp:quote($oaresult[2]), "error"),
      fn:error((), "OAUTH-ERROR", $oaresult[1]/xh:code/fn:string())
    )
  (:
  let $n := xdmp:log(fn:concat("tw:profile-by-email-json: ",$oaresult))
  (: REMEMBER oaresult IS a string, not an xml node! :)
  let $wrappedjson := tw:repack($oaresult)
  return $wrappedjson
  :)
};

declare function tw:profile-by-email($email as xs:string) as element() {
  json:transform-from-json(
    xdmp:from-json(
      tw:profile-by-email-json($email)))
};

declare function tw:get-profile($screenname as xs:string) as element() {
  json:transform-from-json(
    xdmp:from-json(
      tw:get-profile-json($screenname)))
};

(: Note: screen name MUST NOT start with @ character :)
declare function tw:get-profile-json($screenname as xs:string) as xs:string {
  let $search-params := <oa:options>
       <oa:screen_name>{$screenname}</oa:screen_name>
     </oa:options>
  let $oaresult := oa:signed-request($service-document,
                    "GET", "https://api.twitter.com/1.1/users/show.json",
                    $search-params, $access-token, $access-token-secret)
  return
    if ($oaresult[1]/xh:code/fn:string() eq "200")
    then $oaresult[2]
    else (
      xdmp:log(xdmp:quote($oaresult[1]), "error"),
      xdmp:log(xdmp:quote($oaresult[2]), "error"),
      fn:error((), "OAUTH-ERROR", $oaresult[1]/xh:code/fn:string())
    )
  (:
  let $n := xdmp:log(fn:concat("tw:profile-json: ",$oaresult))
  (: REMEMBER oaresult IS a string, not an xml node! :)
  let $wrappedjson := tw:repack($oaresult)
  return $wrappedjson
  :)
};
