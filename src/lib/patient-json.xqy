xquery version "1.0-ml";

module namespace patient-json = "http://marklogic.com/dmlc-healthcare/patient/json";

import module namespace claim-json = "http://marklogic.com/dmlc-healthcare/claim/json" at "/lib/claim-json.xqy";

declare namespace hl7 = "urn:hl7-org:v3";

declare function patient-json:json($x)
{
  map:new((
    for $y in $x/*
    return map:entry(fn:local-name($y), fn:string($y))))
};

declare function patient-json:name($name)
{
  map:entry("name", $name/fn:string-join(*, " "))
};

declare function patient-json:address($address)
{
  map:entry("address", patient-json:json($address))
};

declare function patient-json:patient($patient)
{
  map:entry("patient", map:new((
    patient-json:name($patient/hl7:name),
    map:entry("gender", $patient/hl7:administrativeGenderCode/@displayName/fn:string()),
    map:entry("race", $patient/hl7:raceCode/@displayName/fn:string()),
    map:entry("language", $patient/hl7:languageCommunication/hl7:languageCode/@code/fn:string()),
    map:entry("dob", patient-json:to-date($patient/hl7:birthTime/@value)),
    map:entry("maritalStatus", $patient/hl7:maritalStatusCode/@displayName/fn:string()),
    patient-json:address($patient/../hl7:addr[@use="HP"]),
    map:entry("phone", fn:replace($patient/../hl7:telecom[@use="HP"]/@value, "tel:\s*", ""))
  )))
};

declare function patient-json:author($author)
{
  map:entry("author", map:new((
    patient-json:name($author/hl7:assignedPerson/hl7:name),
    patient-json:address($author/hl7:addr),
    map:entry("phone", $author/hl7:telecom/@value/fn:string()),
    map:entry("organization", $author/hl7:representedOrganization/hl7:name/fn:string())
  )))
};

declare function patient-json:vitals($observations)
{
  let $grouped := map:map()
  let $_ :=
    for $obs in $observations
    let $time := patient-json:to-dateTime($obs/hl7:effectiveTime/@value)
    let $type :=
      switch ($obs/hl7:code/@code/fn:string())
        case "8302-2" return "height"
        case "3141-9" return "weight"
        case "9279-1" return "respiration"
        case "8867-4" return "heartRate"
        case "8480-6" return "systolicBp"
        case "8462-4" return "diastolicBp"
        case "8310-5" return "temperature"
        default return "other"
    let $existing := map:get($grouped, $type)
    return
      map:put($grouped, $type, ($existing,
        map:new((
          map:entry("date", $time),
          map:entry("code", $obs/hl7:code/@code/fn:string()),
          map:entry("type", $obs/hl7:code/@displayName/fn:string()),
          map:entry("units", $obs/hl7:value/@unit/fn:string()),
          map:entry("value", $obs/hl7:value/@value/fn:string())
        ))
      ))
  return
    $grouped
};

declare function patient-json:allergies()
{
  ()
};

declare function patient-json:medications($substances as element(hl7:substanceAdministration)*)
{
  let $medications := json:array()
  let $_ :=
    for $substance in $substances
    return
      json:array-push($medications,
        map:new((
          map:entry("name", $substance/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code[@codeSystemName="NDC"]/@displayName/fn:data(.)),
          map:entry("prescribed", patient-json:to-dateTime($substance/hl7:effectiveTime/hl7:low/@value)),
          map:entry("quantity", ($substance/hl7:entryRelationship/hl7:supply/hl7:quantity/@value)[1]/xs:decimal(.)),
          map:entry("prescriber", fn:normalize-space(fn:string-join($substance/hl7:entryRelationship/hl7:supply/hl7:author/hl7:assignedAuthor/hl7:assignedPerson/hl7:name/*, ' '))),
          let $ndc := $substance/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code[@codeSystemName="NDC"]/@code/fn:data(.)
          return
          (
            map:entry("ndc", $ndc),
            map:entry("spl", cts:element-values(xs:QName("Item_Code"), (), ("limit=1", "collation=http://marklogic.com/collation/codepoint"), cts:word-query($ndc)))
          ),
          map:entry("dose", map:new((
            map:entry("unit", $substance/hl7:doseQuantity/@unit/fn:data(.)),
            map:entry("value", $substance/hl7:doseQuantity/@value/xs:decimal(.))
          )))
        ))
      )
  return
    $medications
};

declare function patient-json:to-camel-case($str as xs:string) as xs:string
{
  if( fn:matches($str , "[-_]" ) ) then
    let $subs :=  fn:tokenize($str,"[-_]")
    return
     fn:string-join((
        $subs[1] ,
          for $s in $subs[ fn:position() gt 1 ]
          return (
               fn:upper-case( fn:substring($s , 1 , 1 )) , fn:lower-case(fn:substring($s,2)))),"")
   else fn:lower-case($str)
};

declare function patient-json:encounters($rows as element(hl7:tr)*)
{
  let $encounters := json:array()
  let $_ :=
    for $row in $rows
    return
      json:array-push($encounters,
        map:new((
          map:entry("date", $row/hl7:td[1]/xs:dateTime(.)),
          map:entry("encounter", $row/hl7:td[2]/fn:data(.)),
          map:entry("performer", $row/hl7:td[3]/fn:data(.)),
          map:entry("location", $row/hl7:td[4]/fn:data(.)),
          let $notes := json:array()
          let $_ :=
            let $p := $row/hl7:td[5]/(*:content2, hl7:content)[1]
            for $node in $p/element()
            let $child :=
              typeswitch ($node)
                case element(hl7:Term) |
                  element(Term) return
                    map:new((
                      for $attr in $node/@*[fn:not(fn:local-name(.) = ('Catalog', 'Code'))]
                      let $attr-name := fn:local-name($attr)
                      return
                      (
                        map:entry(patient-json:to-camel-case($attr-name), fn:string($attr)),
                        map:entry("type", $attr-name)
                      ),
                    map:entry("text", fn:string($node))
                  ))
                case element(hl7:SiftGroup) |
                  element(SiftGroup) return
                  map:new((
                    for $attr in $node/*:Term/@*[fn:not(fn:local-name(.) = ('Catalog', 'Code'))]
                    let $attr-name := fn:local-name($attr)
                    return
                      map:entry(patient-json:to-camel-case($attr-name), fn:string($attr)),
                    map:entry("type", $node/*:Term[1]/@*[fn:not(fn:local-name(.) = ('Catalog', 'Code'))]/fn:local-name(.)),
                    let $vital as xs:string? := $node/*:Term[@Catalog = "SYM_CA_VITALS"]/@VITAL_SIGN
                    return
                      if ($vital) then
                        map:entry("vitalSign", $vital)
                      else
                        map:entry("type", $node/*:Term[1]/@Catalog),
                    let $uom as xs:string? := $node/*:Term[@Catalog = "SYM_CA_UOM"]/@VITAL_SIGN_UOM
                    return
                      if ($uom) then
                        map:entry("unitOfMeasure", $uom)
                      else (),
                    map:entry("value", $node/*:Value[1]/@value),
                    map:entry("text", fn:string($node))
                  ))
                case element(Semaphore) |
                  element(hl7:Semaphore) return
                  map:new((
                    map:entry("type", $node/@class),
                    map:entry("value", $node/@value),
                    map:entry("score", $node/@score),
                    map:entry("text", fn:string($node))
                  ))
                default return
                  fn:string($node) || " "
            return
              json:array-push($notes, $child)
          return
            map:entry("notes", $notes)
        ))
      )
  return
    $encounters
};

declare function patient-json:components($components)
{
  map:new((
    for $component in $components
    let $type :=
      switch ($component/hl7:code/@code/fn:string())
        case '48764-5' return 'sumaryOfPurpose'
        case '11450-4' return 'problems'
        case '30954-2' return 'results'
        case '10160-0' return 'medications'
        case '8716-3' return 'vitals'
        case '10157-6' return 'familyHistory'
        case '46240-8' return 'encounters'
        case '18776-5' return 'planOfCare'
        case '42348-3' return 'advanceDirectives'
        default return
          ()
    return
      map:entry($type,
        map:new((
          map:entry("code", $component/hl7:code/@code/fn:string()),
          map:entry("title", $component/hl7:title/fn:string()),

          switch($type)
            case 'vitals' return
              patient-json:vitals($component/hl7:entry/hl7:organizer/hl7:component//hl7:observation)
            case 'medications' return
              map:entry("values", patient-json:medications($component/hl7:entry/hl7:substanceAdministration))
            case 'encounters' return
              map:entry("values", patient-json:encounters($component/hl7:text/hl7:table/hl7:tbody/hl7:tr))
            default return ()
(:          map:entry("text",
            if ($component/hl7:text/*)
            then xdmp:quote($component/hl7:text/*)
            else $component/hl7:text/fn:string()
          ):)
        ))
      )
  ))
};

declare function patient-json:claims($ssn as xs:string?)
{
  let $array := json:array()
  let $_ :=
    for $claim in /claim[patient-ssn = $ssn]
    return
      json:array-push($array, claim-json:transform($claim))
  return
    $array
};

declare function patient-json:to-date($str)
{
  fn:replace($str, "(\d\d\d\d)(\d\d)(\d\d)", "$1-$2-$3")
};

declare function patient-json:to-dateTime($str)
{
  fn:replace($str, "(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)", "$1-$2-$3T$4:$5:$6Z")
};

declare function patient-json:transform($doc as element(hl7:ClinicalDocument))
{
  map:new((
    let $patient := $doc/hl7:recordTarget/hl7:patientRole/hl7:patient
    return
    (
      patient-json:name($patient/hl7:name),
      map:entry("ssn", $patient/../hl7:id[@root="2.16.840.1.113883.4.1"]/@extension/fn:string()),
      map:entry("gender", $patient/hl7:administrativeGenderCode/@displayName/fn:string()),
      map:entry("race", $patient/hl7:raceCode/@displayName/fn:string()),
      map:entry("language", $patient/hl7:languageCommunication/hl7:languageCode/@code/fn:string()),
      map:entry("dob",  patient-json:to-date($patient/hl7:birthTime/@value)),
      map:entry("maritalStatus", $patient/hl7:maritalStatusCode/@displayName/fn:string()),
      patient-json:address($patient/../hl7:addr[@use="HP"]),
      map:entry("phone", fn:replace($patient/../hl7:telecom[@use="HP"]/@value, "tel:\s*", ""))
    ),

(:    patient-json:patient($doc/hl7:recordTarget/hl7:patientRole/hl7:patient),
    patient-json:author($doc/hl7:author/hl7:assignedAuthor),
    map:entry("custodian", $doc/hl7:custodian/hl7:assignedCustodian),
    map:entry("participant", $doc/hl7:participant),
    map:entry("serviceEvent", $doc/hl7:documentationOf/hl7:serviceEvent),:)
    map:entry("records",
      patient-json:components($doc/hl7:component/hl7:structuredBody/hl7:component/hl7:section)
    ),
    map:entry("claims",
      patient-json:claims($doc/hl7:recordTarget/hl7:patientRole/hl7:id[@root="2.16.840.1.113883.4.1"]/@extension)
    )
  )) ! xdmp:to-json(.)
};

declare function patient-json:transform-lite($doc as element(hl7:ClinicalDocument))
{
  map:new((
    let $patient := $doc/hl7:recordTarget/hl7:patientRole/hl7:patient
    return
    (
      patient-json:name($patient/hl7:name),
      map:entry("ssn", $patient/../hl7:id[@root="2.16.840.1.113883.4.1"]/@extension/fn:string()),
      map:entry("gender", $patient/hl7:administrativeGenderCode/@displayName/fn:string()),
      map:entry("race", $patient/hl7:raceCode/@displayName/fn:string()),
      map:entry("language", $patient/hl7:languageCommunication/hl7:languageCode/@code/fn:string()),
      map:entry("dob",  patient-json:to-date($patient/hl7:birthTime/@value)),
      map:entry("maritalStatus", $patient/hl7:maritalStatusCode/@displayName/fn:string()),
      patient-json:address($patient/../hl7:addr[@use="HP"]),
      map:entry("phone", fn:replace($patient/../hl7:telecom[@use="HP"]/@value, "tel:\s*", ""))
    )
  )) ! xdmp:to-json(.)
};

