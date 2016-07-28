xquery version "1.0-ml";

module namespace co = "http://marklogic.com/conigure-odbc";

import module namespace view = "http://marklogic.com/xdmp/view"
  at "/MarkLogic/views.xqy";

declare namespace cms = "http://marklogic.com/cms";
declare namespace hl7 = "urn:hl7-org:v3";

declare option xdmp:mapping "false";

declare %private function co:create-patient-columns()
{
  view:column("uri", cts:uri-reference()),
  view:column("ssn", cts:path-reference('/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:id[@root="2.16.840.1.113883.4.1"]/@extension', ("type=string","collation=http://marklogic.com/collation/codepoint"))),
  view:column("provider_npi", cts:path-reference('/hl7:ClinicalDocument//hl7:assignedEntity/hl7:id[@root="2.16.840.1.113883.4.6"]/@extension', ("type=string","collation=http://marklogic.com/collation/codepoint"))),
  view:column("problems", cts:path-reference('/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:act/hl7:entryRelationship/hl7:observation/hl7:value/hl7:translation[@codeSystemName="ICD9"]/@displayName', ("type=string","collation=http://marklogic.com/collation/codepoint", "nullable"))),
  view:column("medications", cts:path-reference('/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code[@codeSystemName="NDC"]/@displayName', ("type=string","collation=http://marklogic.com/collation/codepoint", "nullable"))),
  view:column("height", cts:path-reference('/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:organizer/hl7:component/hl7:observation[hl7:code[@code = "8302-2"]]/hl7:value/@value', ("type=decimal", "nullable"))),
  view:column("weight", cts:path-reference('/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:organizer/hl7:component/hl7:observation[hl7:code[@code = "3141-9"]]/hl7:value/@value', ("type=decimal", "nullable"))),
  view:column("respiration", cts:path-reference('/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:organizer/hl7:component/hl7:observation[hl7:code[@code = "9279-1"]]/hl7:value/@value', ("type=decimal", "nullable"))),
  view:column("heart_rate", cts:path-reference('/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:organizer/hl7:component/hl7:observation[hl7:code[@code = "8867-4"]]/hl7:value/@value', ("type=decimal", "nullable"))),
  view:column("systolic_bp", cts:path-reference('/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:organizer/hl7:component/hl7:observation[hl7:code[@code = "8480-6"]]/hl7:value/@value', ("type=decimal", "nullable"))),
  view:column("diastolic_bp", cts:path-reference('/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:organizer/hl7:component/hl7:observation[hl7:code[@code = "8462-4"]]/hl7:value/@value', ("type=decimal", "nullable"))),
  view:column("body_temp", cts:path-reference('/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:organizer/hl7:component/hl7:observation[hl7:code[@code = "8310-5"]]/hl7:value/@value', ("type=decimal", "nullable"))),
  view:column("family_history", cts:path-reference('/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:organizer/hl7:component/hl7:observation/hl7:code[@codeSystem="2.16.840.1.113883.6.96"]/@displayName', ("type=string","collation=http://marklogic.com/collation/codepoint", "nullable"))),
  view:column("family_history_member_affected", cts:path-reference('/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:organizer/hl7:subject/hl7:relatedSubject/hl7:code[@codeSystem="2.16.840.1.113883.5.111"]/@displayName', ("type=string","collation=http://marklogic.com/collation/codepoint", "nullable"))),
  view:column("medical_procedures", cts:path-reference('/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:organizer/hl7:code[@codeSystem="2.16.840.1.113883.6.1"]/@displayName', ("type=string","collation=http://marklogic.com/collation/codepoint", "nullable"))),
  view:column("marital_status", cts:path-reference('/hl7:ClinicalDocument//hl7:maritalStatusCode[@codeSystem="2.16.840.1.113883.5.2"]/@displayName', ("type=string","collation=http://marklogic.com/collation/codepoint", "nullable"))),
  view:column("race", cts:path-reference('/hl7:ClinicalDocument//hl7:raceCode[@codeSystem="2.16.840.1.113883.6.238"]/@displayName', ("type=string","collation=http://marklogic.com/collation/codepoint"))),
  view:column("gender", cts:path-reference('/hl7:ClinicalDocument//hl7:administrativeGenderCode[@codeSystem="2.16.840.1.113883.5.1"]/@displayName', ("type=string","collation=http://marklogic.com/collation/codepoint"))),
  view:column("lat", cts:path-reference('/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/@lat', ("type=decimal", "nullable"))),
  view:column("lng", cts:path-reference('/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/@lng', ("type=decimal", "nullable")))

(:  view:column("medical_procedures", cts:path-reference('', ("type=string","collation=http://marklogic.com/collation/codepoint"))),
  view:column("weight", cts:path-reference('', ("type=decimal"))),:)
};

declare %private function co:create-claims-procedures-columns()
{
  view:column("uri", cts:uri-reference()),
  view:column("procedure_name", cts:path-reference('/claim/procedures/procedure/name', ("type=string","collation=http://marklogic.com/collation/codepoint", "nullable")))
};

declare %private function co:create-patient-data-columns()
{
  view:column("uri", cts:uri-reference()),
  view:column("ssn", cts:path-reference('/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:id[@root="2.16.840.1.113883.4.1"]/@extension', ("type=string","collation=http://marklogic.com/collation/codepoint"))),
  view:column("problems", cts:path-reference('/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:act/hl7:entryRelationship/hl7:observation/hl7:value/hl7:translation[@codeSystemName="ICD9"]/@displayName', ("type=string","collation=http://marklogic.com/collation/codepoint", "nullable"))),
  view:column("race", cts:path-reference('/hl7:ClinicalDocument//hl7:raceCode[@codeSystem="2.16.840.1.113883.6.238"]/@displayName', ("type=string","collation=http://marklogic.com/collation/codepoint"))),
  view:column("gender", cts:path-reference('/hl7:ClinicalDocument//hl7:administrativeGenderCode[@codeSystem="2.16.840.1.113883.5.1"]/@displayName', ("type=string","collation=http://marklogic.com/collation/codepoint"))),
  view:column("lat", cts:path-reference('/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/@lat', ("type=decimal", "nullable"))),
  view:column("lng", cts:path-reference('/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/@lng', ("type=decimal", "nullable")))
};

declare %private function co:create-patient-problems-columns()
{
  view:column("ssn", cts:path-reference('/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:id[@root="2.16.840.1.113883.4.1"]/@extension', ("type=string","collation=http://marklogic.com/collation/codepoint"))),
  view:column("problem", cts:path-reference('/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:act/hl7:entryRelationship/hl7:observation/hl7:value/hl7:translation[@codeSystemName="ICD9"]/@displayName', ("type=string","collation=http://marklogic.com/collation/codepoint", "nullable")))
};

declare %private function co:create-patient-latlng-columns()
{
  view:column("ssn", cts:path-reference('/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:id[@root="2.16.840.1.113883.4.1"]/@extension', ("type=string","collation=http://marklogic.com/collation/codepoint"))),
  view:column("lat", cts:path-reference('/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/@lat', ("type=decimal", "nullable"))),
  view:column("lng", cts:path-reference('/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/@lng', ("type=decimal", "nullable")))
};

declare %private function co:create-provider-columns()
{
  view:column("npi", cts:element-reference(xs:QName("cms:npi"), ("type=string", "collation=http://marklogic.com/collation/codepoint", "nullable"))),
  view:column("entity_type", cts:element-reference(xs:QName("cms:entity-type"), ("type=string", "collation=http://marklogic.com/collation/codepoint"))),
  view:column("gender", cts:element-reference(xs:QName("cms:gender"), ("type=string", "collation=http://marklogic.com/collation/codepoint", "nullable"))),
  view:column("credential", cts:element-reference(xs:QName("cms:credential"), ("type=string", "collation=http://marklogic.com/collation/codepoint", "nullable"))),
  view:column("specialization", cts:element-reference(xs:QName("cms:specialization"), ("type=string", "collation=http://marklogic.com/collation/codepoint", "nullable"))),
  view:column("lat", cts:element-attribute-reference(xs:QName("cms:address"), xs:QName("lat"), ("type=decimal", "nullable"))),
  view:column("lng", cts:element-attribute-reference(xs:QName("cms:address"), xs:QName("lng"), ("type=decimal", "nullable")))

(:  view:column("medical_procedures", cts:path-reference('', ("type=string","collation=http://marklogic.com/collation/codepoint"))),
  view:column("weight", cts:path-reference('', ("type=decimal"))),:)
};

declare %private function co:create-claim-columns()
{
  view:column("uri", cts:uri-reference()),
  view:column("patient_ssn", cts:element-reference(xs:QName("patient-ssn"), ("type=string", "collation=http://marklogic.com/collation/codepoint"))),
  view:column("claim_type", cts:element-reference(xs:QName("type"), ("type=string", "collation=http://marklogic.com/collation/codepoint"))),
  view:column("payment_amount", cts:element-reference(xs:QName("payment-amount"), ("type=decimal", "nullable"))),
  view:column("inpatient_deductible", cts:element-reference(xs:QName("inpatient-deductible"), ("type=decimal", "nullable"))),
  view:column("from", cts:element-reference(xs:QName("from"), ("type=date"))),
  view:column("procedure_name", cts:path-reference('/claim/procedures/procedure/name', ("type=string","collation=http://marklogic.com/collation/codepoint", "nullable"))),
  view:column("diagnosis_name", cts:path-reference('/claim/diagnoses/diagnosis/name', ("type=string","collation=http://marklogic.com/collation/codepoint", "nullable")))

(:  view:column("medical_procedures", cts:path-reference('', ("type=string","collation=http://marklogic.com/collation/codepoint"))),
  view:column("weight", cts:path-reference('', ("type=decimal"))),:)
};

declare %private function co:create-rx-claim-columns()
{
  view:column("uri", cts:uri-reference()),
  view:column("patient_ssn", cts:element-reference(xs:QName("patient-ssn"), ("type=string", "collation=http://marklogic.com/collation/codepoint"))),
  view:column("ndc", cts:element-reference(xs:QName("ndc"), ("type=string", "collation=http://marklogic.com/collation/codepoint"))),
  view:column("drug_name", cts:element-reference(xs:QName("drug-name"), ("type=string", "collation=http://marklogic.com/collation/codepoint"))),
  view:column("gross_drug_cost", cts:element-reference(xs:QName("gross-drug-cost"), ("type=decimal", "nullable"))),
  view:column("patient_pay_amount", cts:element-reference(xs:QName("patient-pay-amount"), ("type=decimal", "nullable"))),
  view:column("quantity", cts:element-reference(xs:QName("quantity"), ("type=decimal", "nullable"))),
  view:column("days_supply", cts:element-reference(xs:QName("days-supply"), ("type=decimal", "nullable"))),
  view:column("rx_service_date", cts:element-reference(xs:QName("rx-service-date"), ("type=date", "nullable")))
};

declare %private function co:create-patients-view()
{
  co:create-view((), "patients", view:element-view-scope(xs:QName("hl7:ClinicalDocument")), co:create-patient-columns(), (), ())
};

declare %private function co:create-claims-procedures-view()
{
  co:create-view((), "claims_procedures", view:element-view-scope(xs:QName("claim")), co:create-claims-procedures-columns(), (), ())
};

declare %private function co:create-patients-latlng-view()
{
  co:create-view((), "patients_latlng", view:element-view-scope(xs:QName("hl7:ClinicalDocument")), co:create-patient-latlng-columns() , (), ())
};

declare %private function co:create-patients-data-view()
{
  co:create-view((), "patient_data", view:element-view-scope(xs:QName("hl7:ClinicalDocument")), co:create-patient-data-columns() , (), ())
};

declare %private function co:create-patients-problems-view()
{
  co:create-view((), "patients_problems", view:element-view-scope(xs:QName("hl7:ClinicalDocument")), co:create-patient-problems-columns() , (), ())
};

declare %private function co:create-providers-view()
{
  co:create-view((), "providers", view:element-view-scope(xs:QName("cms:provider")), co:create-provider-columns(), (), ())
};

declare %private function co:create-claims-view()
{
  co:create-view((), "claims", view:element-view-scope(xs:QName("claim")), co:create-claim-columns(), (), ())
};

declare %private function co:create-rx-claims-view()
{
  co:create-view((), "drug_claims", view:element-view-scope(xs:QName("claim")), co:create-rx-claim-columns(), (), ())
};

declare %private function co:create-view(
  $schema-name as xs:string?,
  $view-name as xs:string,
  $view-scope as element(*,view:view-scope)?,
  $columns as element(view:column)*,
  $schema-permissions as element(sec:permission)*,
  $view-permissions as element(sec:permission)*)
{
  let $schema-name := ($schema-name, "main")[1]
  let $schema-name := fn:lower-case($schema-name)
  return
  (
    if (view:schemas()[view:schema-name = $schema-name]) then ()
    else
      view:schema-create($schema-name, $schema-permissions),

    if (view:views($schema-name)[view:view-name = $view-name]) then
    (
      view:set-view-scope($schema-name, $view-name, $view-scope),
      view:set-columns($schema-name, $view-name, $columns)
    )
    else
      view:create(
        $schema-name,
        $view-name,
        $view-scope,
        $columns,
        (),
        $view-permissions)
  )
};

declare function co:create-views()
{
  co:create-patients-view(),
  co:create-claims-procedures-view(),
  co:create-patients-latlng-view(),
  co:create-patients-data-view(),
  co:create-patients-problems-view(),
  co:create-providers-view(),
  co:create-claims-view(),
  co:create-rx-claims-view()
};

