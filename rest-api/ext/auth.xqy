xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/auth";

import module namespace json = "http://marklogic.com/xdmp/json"
  at "/MarkLogic/json/json.xqy";

declare namespace roxy = "http://marklogic.com/roxy";

declare namespace user = "http://marklogic.com/ns/user";

declare namespace json-basic = "http://marklogic.com/xdmp/json/basic";

(:
 : To add parameters to the functions, specify them in the params annotations.
 : Example
 :   declare %roxy:params("uri=xs:string", "priority=xs:int") ext:get(...)
 : This means that the get function will take two parameters, a string and an int.
 :)

(:
 :)
declare
%roxy:params("user=xs:string", "password=xs:string")
function get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  map:put($context, "output-types", "application/json"),
  let $user-name := map:get($params, "user")
  let $password := map:get($params, "password")
  let $user-doc := fn:doc("/users/" || $user-name || ".json")
  return
    if ($user-doc) then
    (
      xdmp:set-response-code(200, "OK"),
      document {
        json:transform-to-json($user-doc)
      }
    )
    else
    (
      fn:error(
        (),
        "RESTAPI-EXTNERR",
        (
          "401",
          "Not Authorized",
          "json",
          xdmp:to-json(
            map:new((
              map:entry("authenticated", fn:false())
            ))
          )
        )
      )
    )
};
