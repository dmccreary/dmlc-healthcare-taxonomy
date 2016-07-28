xquery version "1.0-ml";

module namespace tweet-json = "http://marklogic.com/dmlc-healthcare/tweet/json";

import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

declare namespace jsonb = "http://marklogic.com/xdmp/json/basic";

declare function tweet-json:transform($tweet as element(tweet-envelope))
{
  let $json :=
    xdmp:from-json(
      json:transform-to-json($tweet/content/jsonb:json))
  return (
    if (fn:exists($tweet/enriched))
    then
      map:put($json, "enriched", json:to-array(
        for $node in $tweet/enriched/node()
        return
          typeswitch ($node)
          case element(Semaphore) return
            map:new((
              map:entry("type", $node/@class),
              map:entry("value", $node/@value),
              map:entry("score", $node/@score),
              map:entry("text", fn:string($node))
            ))
          default return $node
      ))
    else (),
    xdmp:to-json($json)
  )
};
