xquery version "1.0-ml";

import module namespace smartlogic = "http://marklogic.com/ns/smartlogic" at "/lib/smart-logic.xqy";

declare namespace jsonb = "http://marklogic.com/xdmp/json/basic";

declare option xdmp:mapping "false";

declare variable $URI external;

try {
  let $doc := fn:doc($URI)/tweet-envelope
  return
    xdmp:node-insert-after(
      $doc/retrieved-at,
      element enriched {
        smartlogic:enrich( $doc/content/jsonb:json/jsonb:text )/node()
      })
}
catch($ex) {
  xdmp:log($ex)
}
