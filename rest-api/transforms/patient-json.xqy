xquery version "1.0-ml";

module namespace trns = "http://marklogic.com/rest-api/transform/patient-json";

import module namespace patient-json = "http://marklogic.com/dmlc-healthcare/patient/json" at "/lib/patient-json.xqy";

declare namespace roxy = "http://marklogic.com/roxy";

declare function trns:transform(
  $context as map:map,
  $params as map:map,
  $content as document-node()
) as document-node()
{
  document { patient-json:transform($content/*) }
};
