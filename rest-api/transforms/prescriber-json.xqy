xquery version "1.0-ml";

module namespace trns = "http://marklogic.com/rest-api/transform/prescriber-json";

import module namespace prescriber-json = "http://marklogic.com/dmlc-healthcare/prescriber/json" at "/lib/prescriber-json.xqy";

declare function trns:transform(
  $context as map:map,
  $params as map:map,
  $content as document-node()
) as document-node()
{
  document { prescriber-json:transform($content/*) }
};
