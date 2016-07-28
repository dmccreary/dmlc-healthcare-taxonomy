xquery version "1.0-ml";

module namespace trns = "http://marklogic.com/rest-api/transform/claim-json";

import module namespace claim-json = "http://marklogic.com/dmlc-healthcare/claim/json" at "/lib/claim-json.xqy";

declare function trns:transform(
  $context as map:map,
  $params as map:map,
  $content as document-node()
) as document-node()
{
  document { claim-json:transform($content/*) }
};
