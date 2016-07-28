xquery version "1.0-ml";

module namespace trns = "http://marklogic.com/rest-api/transform/diabetes-json";

import module namespace diabetes-json = "http://marklogic.com/dmlc-healthcare/diabetes/json" at "/lib/diabetes-json.xqy";

declare namespace roxy = "http://marklogic.com/roxy";

declare function trns:transform(
  $context as map:map,
  $params as map:map,
  $content as document-node()
) as document-node()
{
  document { diabetes-json:transform($content/*) }
};
