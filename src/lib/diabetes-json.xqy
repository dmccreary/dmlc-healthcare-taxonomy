xquery version "1.0-ml";

module namespace diabetes-json = "http://marklogic.com/dmlc-healthcare/diabetes/json";

import module namespace json="http://marklogic.com/xdmp/json"
     at "/MarkLogic/json/json.xqy";

declare function diabetes-json:transform($report as element(diabetes))
{
  let $config := json:config("custom")
(:  let $_ := map:put($config, "array-element-names", ("drug", "reaction"))
  let $_ := map:put($config, "ignore-attribute-names", "code"):)
  return
    xdmp:to-json(json:transform-to-json($report, $config))
};
