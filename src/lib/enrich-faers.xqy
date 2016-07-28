xquery version "1.0-ml";

module namespace enrich-faers = "http://marklogic.com/ns/enrich-faers";

import module namespace smartlogic = "http://marklogic.com/ns/smartlogic" at "/lib/smart-logic.xqy";

declare namespace faers = "http://fda.gov/ns/faers";

declare option xdmp:mapping "false";

declare variable $queue := map:map();

declare function enrich-faers:build-queue($nodes)
{
  let $_ :=
    for $n in $nodes
    return
      map:put($queue, xdmp:path($n), $n)
  return ()
};

declare function enrich-faers:walk-doc($nodes) {
  for $n in $nodes
  return
    typeswitch($n)
      case element(narrativeincludeclinical) return
        element narrativeincludeclinical { map:get($queue, xdmp:path($n))/node() }
      case element() return
        element { fn:node-name($n) }
        {
          enrich-faers:walk-doc(($n/@*, $n/node()))
        }
      case document-node() return
        enrich-faers:walk-doc($n/element())
      default return $n
};

declare function enrich-faers:enrich-faers($spl as element(faers:faers))
{
  let $_ := map:clear($queue)
  let $_ := enrich-faers:build-queue(($spl//narrativeincludeclinical))
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
    enrich-faers:walk-doc($spl)
};
