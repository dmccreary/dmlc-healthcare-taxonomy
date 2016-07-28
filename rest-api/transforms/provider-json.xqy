xquery version "1.0-ml";

module namespace trns = "http://marklogic.com/rest-api/transform/provider-json";

import module namespace provider-json = "http://marklogic.com/dmlc-healthcare/provider/json" at "/lib/provider-json.xqy";

declare namespace roxy = "http://marklogic.com/roxy";

declare function trns:transform(
  $context as map:map,
  $params as map:map,
  $content as document-node()
) as document-node()
{
  document { provider-json:transform($content/*) }
};
