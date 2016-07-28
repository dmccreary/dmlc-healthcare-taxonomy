xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/datasources";

import module namespace json = "http://marklogic.com/xdmp/json"
  at "/MarkLogic/json/json.xqy";

declare namespace user = "http://marklogic.com/ns/user";

declare namespace json-basic = "http://marklogic.com/xdmp/json/basic";

declare variable $RXNORM-COUNT :=
 let $c := xdmp:get-server-field('rxnorm-count')
 return
   if (fn:exists($c)) then $c
   else
     xdmp:set-server-field('rxnorm-count', fn:count(fn:collection('rxnorm')/sem:triples/sem:triple));

declare variable $NDDF-COUNT :=
 let $c := xdmp:get-server-field('nddf-count')
 return
   if (fn:exists($c)) then $c
   else
     xdmp:set-server-field('nddf-count', fn:count(fn:collection('nddf')/sem:triples/sem:triple));

declare variable $MEDDRA-COUNT :=
  let $c := xdmp:get-server-field('medda-count')
  return
    if (fn:exists($c)) then $c
    else
      xdmp:set-server-field('medda-count', fn:count(fn:collection('meddra')/sem:triples/sem:triple));

declare variable $ATC-COUNT :=
  let $c := xdmp:get-server-field('atc-count')
  return
    if (fn:exists($c)) then $c
    else
      xdmp:set-server-field('atc-count', fn:count(fn:collection('atc')/sem:triples/sem:triple));

declare
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  map:put($context, "output-types", "application/json"),
  let $a := json:array()
  let $_ :=
  (
    json:array-push($a, map:new((
      map:entry("name", "National Drug Data File"),
      map:entry("description", "FDB MedKnowledge encompasses medications approved by the U.S. Food and Drug Administration, and information on commonly-used over-the-counter and alternative therapy agents such as herbals, nutraceuticals and dietary supplements."),
      map:entry("format", "RDF triples"),
      map:entry("url", "http://www.nlm.nih.gov/research/umls/"),
      map:entry("count", $NDDF-COUNT)
    ))),
    json:array-push($a, map:new((
      map:entry("name", "RxNorm"),
      map:entry("description", "RxNorm provides normalized names for clinical drugs and links its names to many of the drug vocabularies commonly used in pharmacy management and drug interaction software, including those of First Databank, Micromedex, MediSpan, Gold Standard Drug Database, and Multum. By providing links between these vocabularies, RxNorm can mediate messages between systems not using the same software and vocabulary."),
      map:entry("format", "RDF triples"),
      map:entry("url", "http://www.nlm.nih.gov/research/umls/"),
      map:entry("count", $RXNORM-COUNT)
    ))),
    json:array-push($a, map:new((
      map:entry("name", "MedDRA"),
      map:entry("description", "Medical Dictionary for Regulatory Activities"),
      map:entry("format", "RDF triples"),
      map:entry("url", "http://meddra.org/"),
      map:entry("count", $MEDDRA-COUNT)
    ))),
    json:array-push($a, map:new((
      map:entry("name", "ATC"),
      map:entry("description", "The Anatomical Therapeutic Chemical (ATC) Classification System is used for the classification of active ingredients of drugs according to the organ or system on which they act and their therapeutic, pharmacological and chemical properties. It is controlled by the World Health Organization Collaborating Centre for Drug Statistics Methodology (WHOCC), and was first published in 1976."),
      map:entry("format", "RDF triples"),
      map:entry("url", "http://www.nlm.nih.gov/research/umls/"),
      map:entry("count", $ATC-COUNT)
    ))),
    json:array-push($a, map:new((
      map:entry("name", "ICD-9-CM Diagnostic Codes to SNOMED CT Map"),
      map:entry("description", "A mapping between ICD-9-CM Diagnostic codes and SNOMED CT codes"),
      map:entry("format", "XML documents. CSV File converted to 1 XML document per line"),
      map:entry("url", ""),
      map:entry("count", xdmp:estimate(fn:collection("icd9-to-snomed")))
    ))),
    json:array-push($a, map:new((
      map:entry("name", "Patient Records"),
      map:entry("description", "Patient records generated from CMS anonymized claims data"),
      map:entry("format", "C32 Patient Records XML"),
      map:entry("url", "http://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/SynPUFs/DE_Syn_PUF.html"),
      map:entry("count", xdmp:estimate(fn:collection("patient")))
    ))),
    json:array-push($a, map:new((
      map:entry("name", "Inpatient Claims Records"),
      map:entry("description", "Inpatient Claims data generated from CMS anonymized claims data"),
      map:entry("format", "XML"),
      map:entry("url", "http://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/SynPUFs/DE_Syn_PUF.html"),
      map:entry("count", xdmp:estimate(fn:collection("claim")/claim[type="Inpatient"]))
    ))),
    json:array-push($a, map:new((
      map:entry("name", "Outpatient Claims Records"),
      map:entry("description", "Outpatient Claims data generated from CMS anonymized claims data"),
      map:entry("format", "XML"),
      map:entry("url", "http://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/SynPUFs/DE_Syn_PUF.html"),
      map:entry("count", xdmp:estimate(fn:collection("claim")/claim[type="Outpatient"]))
    ))),
    json:array-push($a, map:new((
      map:entry("name", "Rx Claims Records"),
      map:entry("description", "Rx Claims data generated from CMS anonymized claims data"),
      map:entry("format", "XML"),
      map:entry("url", "http://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/SynPUFs/DE_Syn_PUF.html"),
      map:entry("count", xdmp:estimate(fn:collection("claim")/claim[type="Rx"]))
    ))),
    json:array-push($a, map:new((
      map:entry("name", "National Provider Identifier Standard (NPI)"),
      map:entry("description", "A full list of Healthcare providers in the US"),
      map:entry("format", "XML documents. CSV File converted to 1 XML document per line"),
      map:entry("url", "http://nppes.viva-it.com/NPI_Files.html "),
      map:entry("count", xdmp:estimate(fn:collection("provider")))
    ))),
    json:array-push($a, map:new((
      map:entry("name", "Structured Product Labels (SPL)"),
      map:entry("description", "The HL7 Version 3 Structured Product Labeling (SPL) specification is a document markup standard that specifies the structure and semantics of the content of authorized published information that accompanies any medicine licensed by a medicines licensing authority.  An SPL document is created by an organization that is required by law to submit product information document because it is responsible for the creation or marketing of a product, or any other person or organization compelled by other motives to submit information about products, whether originally created or not. This includes original manufacturers, repackagers, relabelers, and public agencies or private information publishers that submit product information documents. Recipients of product label documents are any person or organization, including the public at large, or an agent of the public (such as a regulatory authority)."),
      map:entry("format", "HL7 v3 XML documents"),
      map:entry("url", "http://dailymed.nlm.nih.gov/dailymed/spl-resources-all-drug-labels.cfm"),
      map:entry("count", xdmp:estimate(fn:collection("spl")))
    ))),
    json:array-push($a, map:new((
      map:entry("name", "FDA Adverse Events"),
      map:entry("description", "FDA Adverse Events."),
      map:entry("format", "XML"),
      map:entry("url", "http://www.fda.gov/Drugs/GuidanceComplianceRegulatoryInformation/Surveillance/AdverseDrugEffects/ucm082193.htm"),
      map:entry("count", xdmp:estimate(fn:collection("faers")))
    ))),
    json:array-push($a, map:new((
      map:entry("name", "Tweets"),
      map:entry("description", "Tweets about diabetes"),
      map:entry("format", "JSON converted to XML"),
      map:entry("url", "http://twitter.com"),
      map:entry("count", xdmp:estimate(fn:collection("tweets")))
    ))),
    json:array-push($a, map:new((
      map:entry("name", "Diabetes"),
      map:entry("description", "The dataset represents 10 years (1999-2008) of clinical care at 130 US hospitals and integrated delivery networks. It includes over 50 features representing patient and hospital outcomes."),
      map:entry("format", "XML"),
      map:entry("url", "https://archive.ics.uci.edu/ml/datasets/Diabetes+130-US+hospitals+for+years+1999-2008#"),
      map:entry("count", xdmp:estimate(fn:collection("diabetes")))
    )))
  )
  return
    document { $a ! xdmp:to-json(.) }
};
