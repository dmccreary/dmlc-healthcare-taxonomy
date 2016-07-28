xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/vitals";

import module namespace trns = "http://marklogic.com/transform/patient" at "/transform/patient-transform.xqy";

declare namespace roxy = "http://marklogic.com/roxy";
declare namespace rapi = "http://marklogic.com/rest-api";
declare namespace hl7 = "urn:hl7-org:v3";

(:
 : To add parameters to the functions, specify them in the params annotations.
 : Example
 :   declare %roxy:params("uri=xs:string", "priority=xs:int") ext:get(...)
 : This means that the get function will take two parameters, a string and an int.
 :)

(:
 :)
declare
%rapi:transaction-mode("update")
function ext:post(
    $context as map:map,
    $params  as map:map,
    $input   as document-node()*
) as document-node()*
{
  let $output-types := map:put($context, "output-types", "application/json")
  let $_ := xdmp:log(("input", $input))
  let $patient-uri := $input/patientID
  let $_ := xdmp:log(("patient-uri", $patient-uri))
  let $type := $input/type
  let $units := $input/units
  let $value := $input/value
  let $patient := fn:doc($patient-uri)/hl7:ClinicalDocument
  let $vitals :=
    if ($type eq "bp") then
      let $splits := fn:tokenize($value, "/")
      return
      (
        <vital><type>systolic</type><units>{$units}</units><value>{$splits[1]}</value></vital>,
        <vital><type>diastolic</type><units>{$units}</units><value>{$splits[2]}</value></vital>
      )
    else
      <vital>
        <type>{$type}</type>
        <units>{$units}</units>
        <value>{$value}</value>
      </vital>
  let $_ := xdmp:log($vitals)
  let $_ := xdmp:node-replace($patient, trns:add-vitals($patient, $vitals))
  let $response := json:object()
  return (xdmp:set-response-code(200,"OK"), document { xdmp:to-json($response) })
};
