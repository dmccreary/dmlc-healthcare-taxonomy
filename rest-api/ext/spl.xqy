xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/spl";

import module namespace spl = "http://marklogic.com/dmlc-healthcare/spl/lib" at "/lib/spl-lib.xqy";

declare namespace roxy = "http://marklogic.com/roxy";
declare namespace hl7 = "urn:hl7-org:v3";

declare
  %roxy:params("spl=xs:string", "drugName=xs:string")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  let $content :=
    if (map:contains($params, 'spl'))
    then spl:find-by-spl-code(map:get($params, 'spl'))
    else spl:find-by-drug-name(map:get($params, 'drugName'))
  return
    if ($content)
    then (
      map:put($context, "output-types", "text/html"),
      map:put($context, "output-status", (200, "OK")),
      document { spl:get-html($content) }
    )
    else (
      xdmp:log("error time"),
      map:put($context, "output-status", (404, "Not Found")),
      fn:error((), "RESTAPI-EXTNERR", ("404", "Not Found", "json", '{"status": "Not Found"}'))
    )
};
