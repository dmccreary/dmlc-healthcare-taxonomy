xquery version "1.0-ml";

module namespace codes = "http://marklogic.com/ns/codes";

declare option xdmp:mapping "false";

declare variable $ICD9-DIAGNOSIS-CODES :=
  let $codes := xdmp:get-server-field("icd9-diag-codes")
  return
    if (fn:exists($codes)) then $codes
    else
      xdmp:set-server-field("icd9-diag-codes", xdmp:from-json-string(fn:doc('/codes/icd9-diagnosis-codes.txt')));

declare variable $ICD9-PROCEDURE-CODES :=
  let $codes := xdmp:get-server-field("icd9-prod-codes")
  return
    if (fn:exists($codes)) then $codes
    else
      xdmp:set-server-field("icd9-prod-codes", xdmp:from-json-string(fn:doc('/codes/icd9-procedure-codes.txt')));


declare variable $OLD-NDC-CODES :=
  let $codes := xdmp:get-server-field("old-ndc-codes")
  return
    if (fn:exists($codes)) then $codes
    else
      xdmp:set-server-field("old-ndc-codes", xdmp:from-json-string(fn:doc('/codes/old-ndc-codes.txt')));

declare variable $OLD-NDC-INVERSE-CODES :=
  let $codes := xdmp:get-server-field("old-ndc-inverse-codes")
  return
    if (fn:exists($codes)) then $codes
    else
      xdmp:set-server-field("old-ndc-inverse-codes", -$OLD-NDC-CODES);

declare variable $NEW-NDC-CODES :=
  let $codes := xdmp:get-server-field("new-ndc-codes")
  return
    if (fn:exists($codes)) then $codes
    else
      xdmp:set-server-field("new-ndc-codes", xdmp:from-json-string(fn:doc('/codes/new-ndc-codes.txt')));

declare variable $NEW-NDC-INVERSE-CODES :=
  let $codes := xdmp:get-server-field("new-ndc-inverse-codes")
  return
    if (fn:exists($codes)) then $codes
    else
      xdmp:set-server-field("new-ndc-inverse-codes", -$NEW-NDC-CODES);

declare variable $CPT-CODES :=
  let $codes := xdmp:get-server-field("cpt-codes")
  return
    if (fn:exists($codes)) then $codes
    else
      xdmp:set-server-field("cpt-codes", xdmp:from-json-string(fn:doc('/codes/cpt-hcpcs.txt')));
