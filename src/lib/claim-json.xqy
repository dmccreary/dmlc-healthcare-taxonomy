xquery version "1.0-ml";

module namespace claim-json = "http://marklogic.com/dmlc-healthcare/claim/json";

declare function claim-json:to-camel-case($str as xs:string) as xs:string
{
  if( fn:matches($str , "[-_]" ) ) then
    let $subs :=  fn:tokenize($str,"[-_]")
    return
     fn:string-join((
        $subs[1] ,
          for $s in $subs[ fn:position() gt 1 ]
          return (
               fn:upper-case( fn:substring($s , 1 , 1 )) , fn:lower-case(fn:substring($s,2)))),"")
   else $str
};

declare function claim-json:transform($claim as element(claim))
{
  let $o := json:object()
  let $procedures := json:array()
  let $_ :=
    for $procedure-name as xs:string in $claim/*:procedures/*:procedure/*:name
    return
      json:array-push($procedures, $procedure-name)
  let $_ := map:put($o, "procedures", $procedures)
  let $diagnoses := json:array()
  let $_ :=
    for $diagnosis-name as xs:string in $claim/*:diagnoses/*:diagnosis/*:name
    return
      json:array-push($diagnoses, $diagnosis-name)
  let $_ := map:put($o, "diagnoses", $diagnoses)
  let $_ := map:put($o, "claimType", $claim/*:type/fn:string())
  let $_ :=
    for $x in $claim/*[fn:not(self::type or self::procedures or self::diagnoses)]
    let $local-name := fn:local-name($x)
    let $value :=
      if ($local-name = ("quantity", "days-supply", "patient-pay-amount", "gross-drug-cost", "payment-amount", "primary-payer-paid-amount", "bene-part-b-deductible-amount", "bene-part-b-coinsurance-amount", "blood-deductible-liability-amount")) then
        xs:decimal($x)
      else
        fn:data($x)
    return
      map:put($o, claim-json:to-camel-case($local-name), $value)
  return
    xdmp:to-json($o)
};
