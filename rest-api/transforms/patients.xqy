xquery version "1.0-ml";
module namespace trns = "http://marklogic.com/rest-api/transform/patients";

declare namespace search = "http://marklogic.com/appservices/search";

declare namespace hl7 = "urn:hl7-org:v3";

import module namespace patient-json = "http://marklogic.com/dmlc-healthcare/patient/json" at "/lib/patient-json.xqy";
(: REST API transforms managed by Roxy must follow these conventions:

1. Their filenames must reflect the name of the transform.

For example, an XQuery transform named add-attr must be contained in a file named add-attr.xqy
and have a module namespace of "http://marklogic.com/rest-api/transform/add-attr".

2. Must declare the roxy namespace with the URI "http://marklogic.com/roxy".

declare namespace roxy = "http://marklogic.com/roxy";

3. Must annotate the transform function with the transform parameters:

%roxy:params("uri=xs:string", "priority=xs:int")

These can be retrieved with map:get($params, "uri"), for example.

:)

declare function trns:walk($nodes as node()*)
{
  for $n in $nodes
  return
    typeswitch($n)
      case document-node() return
        trns:walk($n/*)
      case element(search:result) return
        let $d := fn:doc($n/@uri)/hl7:ClinicalDocument
        let $patient := $d/hl7:recordTarget/hl7:patientRole/hl7:patient
        return
          element { fn:node-name($n) }
          {
            trns:walk(($n/@*, $n/node())),
            text {
              let $o := json:object()
              let $_ := map:put($o, "name", fn:string-join($patient/hl7:name/*, ' '))
              let $_ := map:put($o, "gender", $patient/hl7:administrativeGenderCode/@displayName/fn:string())
              let $_ := map:put($o, "race", $patient/hl7:raceCode/@displayName/fn:string())
              let $_ := map:put($o, "language", $patient/hl7:languageCommunication/hl7:languageCode/@code/fn:string())
              let $_ := map:put($o, "dob",  patient-json:to-date($patient/hl7:birthTime/@value))
              return
                xdmp:to-json($o)
            }
          }
      case element() return
        element { fn:node-name($n) }
        {
          trns:walk(($n/@*, $n/node()))
        }
      default return
        $n
};

declare
function trns:transform(
  $context as map:map,
  $params as map:map,
  $content as document-node()
) as document-node()
{
  document {
    trns:walk($content)
  }
};
