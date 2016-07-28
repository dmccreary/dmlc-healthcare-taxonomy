xquery version "1.0-ml";

module namespace twl = "http://marklogic.com/dmlc-healthcare/tweets/lib";

import module namespace tw = "http://marklogic.com/roxy/twitter" at "/lib/external/lib-twitter.xqy";
import module namespace smartlogic = "http://marklogic.com/ns/smartlogic" at "/lib/smart-logic.xqy";
import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

declare namespace jsonb = "http://marklogic.com/xdmp/json/basic";

declare function twl:ingest-tweets()
{
  let $_ := xdmp:log("ingesting tweets")
  let $response := tw:search-json("diabetes OR diabetic OR Onglyza OR Farxiga")
  for $tweet in $response/statuses
  return twl:save-tweet($tweet)
};

declare function twl:save-tweet($tweet as object-node())
{
  let $uri := "/tweets/tweet-" || $tweet/id_str || ".xml"
  return
    if (fn:doc-available($uri))
    then () (: xdmp:log("skipping: " || $uri) :)
    else
      xdmp:document-insert(
        $uri,
        element tweet-envelope {
          element retrieved-at { fn:current-dateTime() },
          element enriched {
            smartlogic:enrich( $tweet/text )/node()
          },
          element content {
            json:transform-from-json(xdmp:from-json($tweet))
          }
        },
        (
          xdmp:permission("dmlc-healthcare-role", "read"),
          xdmp:permission("dmlc-healthcare-role", "update")
        ),
        "tweets")
};
