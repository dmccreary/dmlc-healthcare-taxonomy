xquery version "1.0-ml";

import module namespace enrich-patient-record = "http://marklogic.com/ns/enrich-patient-record" at "/lib/enrich-patient-records.xqy";

declare namespace hl7 = "urn:hl7-org:v3";

declare option xdmp:mapping "false";

declare variable $URI external;

try
{
  let $patient := fn:doc($URI)/hl7:ClinicalDocument
  return
    xdmp:node-replace($patient, enrich-patient-record:enrich-patient-record($patient))
}
catch($ex) {
  xdmp:log($ex)
}
