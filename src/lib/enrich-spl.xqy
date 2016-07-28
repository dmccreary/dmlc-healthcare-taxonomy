xquery version "1.0-ml";

module namespace enrich-spl = "http://marklogic.com/ns/enrich-spl";

import module namespace smartlogic = "http://marklogic.com/ns/smartlogic" at "/lib/smart-logic.xqy";

declare namespace hl7 = "urn:hl7-org:v3";

declare option xdmp:mapping "false";

declare variable $queue := map:map();

declare function enrich-spl:build-queue($nodes)
{
  let $_ :=
    for $n in $nodes
    return
      map:put($queue, xdmp:path($n), $n)
  return ()
};

declare function enrich-spl:walk-spl($nodes) {
  for $n in $nodes
  return
    typeswitch($n)
      case element(hl7:paragraph) return
        element hl7:paragraph { map:get($queue, xdmp:path($n))/node() }
      case element() return
        element { fn:node-name($n) }
        {
          enrich-spl:walk-spl(($n/@*, $n/node()))
        }
      case document-node() return
        enrich-spl:walk-spl($n/element())
      default return $n
};

declare function enrich-spl:enrich-spl($spl as element(hl7:document))
{
  let $_ := map:clear($queue)
  let $_ := enrich-spl:build-queue(($spl//hl7:paragraph))
  let $lookups :=
    for $key in map:keys($queue)
    let $node := map:get($queue, $key)
    return
      xdmp:spawn-function(function() {
        <lookup key="{$key}">
        { smartlogic:enrich($node) }
        </lookup>
      },
      <options xmlns="xdmp:eval">
        <result>{fn:true()}</result>
      </options>)
  let $_ :=
    for $lookup in $lookups
    return
      map:put($queue, $lookup/@key, $lookup/element())
  return
    enrich-spl:walk-spl($spl)
};
