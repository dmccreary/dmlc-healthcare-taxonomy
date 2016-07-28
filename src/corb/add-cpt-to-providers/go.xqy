xquery version "1.0-ml";

declare namespace cms = "http://marklogic.com/cms";

declare option xdmp:mapping "false";

declare variable $URI external;
(:declare variable $CODEPOINT := "collation=http://marklogic.com/collation/codepoint";:)

try
{
  let $provider := fn:doc($URI)/cms:provider
  let $npi as xs:string := $provider/cms:npi
  let $cpt-codes as xs:string* :=
      fn:collection("provider-charge-data")/provider-charge-data[npi = $npi]/hcpcs_code
  where $provider and fn:exists($cpt-codes)
  return
    xdmp:node-insert-child($provider,
      element cms:cpt-codes {
        $cpt-codes ! element cms:cpt-code { . }
      })
}
catch($ex) {
  xdmp:log($ex)
}
