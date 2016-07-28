xquery version "1.0-ml";

import module namespace enrich-faers = "http://marklogic.com/ns/enrich-faers" at "/lib/enrich-faers.xqy";

declare namespace faers = "http://fda.gov/ns/faers";

declare option xdmp:mapping "false";

declare variable $URI external;

try
{
  let $patient := fn:doc($URI)/faers:faers
  return
    xdmp:node-replace($patient, enrich-faers:enrich-faers($patient))
}
catch($ex) {
  xdmp:log($ex)
}
