xquery version "1.0-ml";

import module namespace enrich-spl = "http://marklogic.com/ns/enrich-spl" at "/lib/enrich-spl.xqy";

declare namespace hl7 = "urn:hl7-org:v3";

declare option xdmp:mapping "false";

declare variable $URI external;

try
{
  let $doc := fn:doc($URI)/hl7:document
  return
    xdmp:node-replace($doc, enrich-spl:enrich-spl($doc))
}
catch($ex) {
  xdmp:log($ex)
}
