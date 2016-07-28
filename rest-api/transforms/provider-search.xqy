xquery version "1.0-ml";
module namespace trns = "http://marklogic.com/rest-api/transform/provider-search";

declare namespace search = "http://marklogic.com/appservices/search";

declare namespace hl7 = "urn:hl7-org:v3";

declare namespace cms = "http://marklogic.com/cms";

declare function trns:walk($nodes as node()*)
{
  for $n in $nodes
  return
    typeswitch($n)
      case document-node() return
        trns:walk($n/*)
      case element(search:result) return
        let $d := fn:doc($n/@uri)/cms:provider
        return
          element { fn:node-name($n) }
          {
            trns:walk(($n/@*, $n/node())),
            text {
              let $o := json:object()
              let $name := fn:string-join(($d/cms:first-name[. ne ''], $d/cms:middle-name[. ne ''], $d/cms:last-name[. ne '']), " ")[. ne '']
              let $org-name := $d/cms:org-name/fn:string()
              let $_ := map:put($o, "name", ($name, $org-name)[1])
              let $_ := map:put($o, "gender", $d/cms:gender/fn:string())
              let $_ := map:put($o, "type", $d/cms:entity-type/fn:string())
              let $address := json:object()
              let $_ := map:put($address, "line1", $d/cms:addresses/cms:address[@type="location address"]/cms:addr-line1[. ne '']/fn:string())
              let $_ := map:put($address, "line2", $d/cms:addresses/cms:address[@type="location address"]/cms:addr-line2[. ne '']/fn:string())
              let $_ := map:put($address, "city", $d/cms:addresses/cms:address[@type="location address"]/cms:city[. ne '']/fn:string())
              let $_ := map:put($address, "state", $d/cms:addresses/cms:address[@type="location address"]/cms:state[. ne '']/fn:string())
              let $_ := map:put($address, "zip", $d/cms:addresses/cms:address[@type="location address"]/cms:zip5[. ne '']/fn:string())
              let $_ := map:put($address, "lat", $d/cms:addresses/cms:address[@type="location address"]/@lat[. ne '']/fn:string())
              let $_ := map:put($address, "lng", $d/cms:addresses/cms:address[@type="location address"]/@lng[. ne '']/fn:string())
              let $_ := map:put($o, "address", $address)
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
