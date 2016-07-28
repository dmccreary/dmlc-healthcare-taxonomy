xquery version "1.0-ml";

module namespace trns = "http://marklogic.com/rest-api/transform/faers-json";

import module namespace faers-json = "http://marklogic.com/dmlc-healthcare/faers/json" at "/lib/faers-json.xqy";

declare namespace roxy = "http://marklogic.com/roxy";

declare function trns:transform(
  $context as map:map,
  $params as map:map,
  $content as document-node()
) as document-node()
{
  map:put($context, "output-types", "application/json"),
  document { faers-json:transform($content/*) }
};
