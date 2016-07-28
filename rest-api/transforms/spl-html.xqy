xquery version "1.0-ml";

module namespace trns = "http://marklogic.com/rest-api/transform/spl-html";

import module namespace spl = "http://marklogic.com/dmlc-healthcare/spl/lib" at "/lib/spl-lib.xqy";

declare namespace roxy = "http://marklogic.com/roxy";

declare function trns:transform(
  $context as map:map,
  $params as map:map,
  $content as document-node()
) as document-node()
{
  map:put($context, "output-types", "text/html"),
  map:put($context, "output-status", (200, "OK")),
  document { spl:get-html($content) }
};
