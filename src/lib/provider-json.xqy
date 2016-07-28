xquery version "1.0-ml";

module namespace provider-json = "http://marklogic.com/dmlc-healthcare/provider/json";

declare namespace cms = "http://marklogic.com/cms";

(:declare function provider-json:json($x)
{
  map:new((
    for $y in $x/*
    return map:entry(fn:local-name($y), fn:string($y))))
};

declare function provider-json:name($name)
{
  map:entry("name", $name/fn:string-join(*, " "))
};

declare function provider-json:address($address)
{
  map:entry("address", provider-json:json($address))
};

declare function provider-json:patient($patient)
{
  map:entry("patient", map:new((
    provider-json:name($patient/hl7:name),
    map:entry("gender", $patient/hl7:administrativeGenderCode/@displayName/fn:string()),
    map:entry("race", $patient/hl7:raceCode/@displayName/fn:string()),
    map:entry("language", $patient/hl7:languageCommunication/hl7:languageCode/@code/fn:string()),
    map:entry("dob", provider-json:to-date($patient/hl7:birthTime/@value)),
    map:entry("maritalStatus", $patient/hl7:maritalStatusCode/@displayName/fn:string()),
    provider-json:address($patient/../hl7:addr[@use="HP"]),
    map:entry("phone", fn:replace($patient/../hl7:telecom[@use="HP"]/@value, "tel:\s*", ""))
  )))
};

declare function provider-json:author($author)
{
  map:entry("author", map:new((
    provider-json:name($author/hl7:assignedPerson/hl7:name),
    provider-json:address($author/hl7:addr),
    map:entry("phone", $author/hl7:telecom/@value/fn:string()),
    map:entry("organization", $author/hl7:representedOrganization/hl7:name/fn:string())
  )))
};

declare function provider-json:vitals($observations)
{
  let $grouped := map:map()
  let $_ :=
    for $obs in $observations
    let $time := provider-json:to-dateTime($obs/hl7:effectiveTime/@value)
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

declare function provider-json:allergies()
{
  ()
};

declare function provider-json:medications($substances as element(hl7:substanceAdministration)*)
{
  let $medications := json:array()
  let $_ :=
    for $substance in $substances
    return
      json:array-push($medications,
        map:new((
          map:entry("name", $substance/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code[@codeSystemName="NDC"]/@displayName/fn:data(.)),
          map:entry("prescribed", provider-json:to-dateTime($substance/hl7:effectiveTime/hl7:low/@value)),
          map:entry("quantity", ($substance/hl7:entryRelationship/hl7:supply/hl7:quantity/@value)[1]/xs:decimal(.)),
          map:entry("prescriber", fn:normalize-space(fn:string-join($substance/hl7:entryRelationship/hl7:supply/hl7:author/hl7:assignedAuthor/hl7:assignedPerson/hl7:name/*, ' '))),
          let $ndc := $substance/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code[@codeSystemName="NDC"]/@code/fn:data(.)
          return
          (
            map:entry("ndc", $ndc),
            map:entry("spl", cts:element-values(xs:QName("Item_Code"), (), ("limit=1", "collation=http://marklogic.com/collation/codepoint"), cts:element-range-query(xs:QName("NDC11"), "=", $ndc, "collation=http://marklogic.com/collation/codepoint")))
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



declare function provider-json:components($components)
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
              provider-json:vitals($component/hl7:entry/hl7:organizer/hl7:component//hl7:observation)
            case 'medications' return
              map:entry("values", provider-json:medications($component/hl7:entry/hl7:substanceAdministration))
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

declare function provider-json:to-date($str)
{
  fn:replace($str, "(\d\d\d\d)(\d\d)(\d\d)", "$1-$2-$3")
};

declare function provider-json:to-dateTime($str)
{
  fn:replace($str, "(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)", "$1-$2-$3T$4:$5:$6Z")
};
:)
declare function provider-json:json($x)
{
  map:new((
    for $y in $x/*
    return map:entry(fn:local-name($y), fn:string($y))))
};

declare function provider-json:specialities($specialties) {
  let $areas := json:array()
  let $_ :=
    for $specialty in $specialties
    return
      json:array-push($areas,
        map:new((
          map:entry("code", $specialty/@taxonomy-code/fn:data(.)),
          map:entry("license", $specialty/@license-number/fn:data(.)),
          map:entry("state", $specialty/@state-code/fn:data(.)),
          map:entry("primary", $specialty/@is-primary/fn:data(.)),
          map:entry("type", $specialty/cms:type/fn:string()),
          map:entry("classification", $specialty/cms:classification/fn:string()),
          map:entry("definition", $specialty/cms:definition/fn:string())
        ))
      )
  return $areas
};

declare function provider-json:transform($provider as element(cms:provider))
{

  map:new((
    map:entry("name", fn:string-join(($provider/cms:first-name[. ne ''], $provider/cms:middle-name[. ne ''], $provider/cms:last-name[. ne '']), " ")[. ne '']),
    map:entry("org", $provider/cms:org-name/fn:string()),
    map:entry("gender", $provider/cms:gender/fn:string()),
    map:entry("providerType", $provider/cms:entity-type/fn:string()),
    map:entry("address", provider-json:json($provider/cms:addresses/cms:address[@type="location address"])),
    map:entry("lat", $provider/cms:addresses/cms:address[@type="location address"]/@lat/fn:data(.)),
    map:entry("lng", $provider/cms:addresses/cms:address[@type="location address"]/@lng/fn:data(.)),
    map:entry("specialities", provider-json:specialities($provider/cms:specialties/*))
  )) ! xdmp:to-json(.)
};
