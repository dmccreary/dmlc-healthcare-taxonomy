(:
: This extension expands a text query including drug names to brand or
: generic equivalents and/or to other drugs in the same drug class.
: It uses triple data from RXNORM for the first, and ATC triples for 2nd.
:)
xquery version "1.0-ml";

module namespace exp = "http://marklogic.com/rest-api/resource/expand-drug";

declare namespace roxy = "http://marklogic.com/roxy";

import module namespace sem = "http://marklogic.com/semantics" 
  at "/MarkLogic/semantics.xqy";

(: 
 : To add parameters to the functions, specify them in the params annotations. 
 : Example
 :   declare %roxy:params("uri=xs:string", "priority=xs:int") exp:get(...)
 : This means that the get function will take two parameters, a string and an int.
 :)

declare function exp:process-boolean-param($params, $param-name) as xs:boolean
{
  let $param := map:get($params, $param-name)
  return if (exists($param))
  then if ($param != "false")
       then true()
       else false()
  else false()
};

declare function exp:expand-drug-classes($qtexts, $discovered-terms)
{
  let $bindings := map:entry(
    "drugName", (
      for $query-word in $qtexts
      let $lcase-name := lower-case($query-word)
      return rdf:langString($lcase-name, "eng")))
  let $sparql := "
    PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
    PREFIX rxn:  <http://purl.bioontology.org/ontology/RXNORM/>
    PREFIX atc: <http://purl.bioontology.org/ontology/UATC/>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    SELECT ?additionalLabel 
    WHERE {
      ?startingDrug skos:prefLabel ?drugName.
      ?startingDrug rdfs:subClassOf ?superClass1.
      ?superClass1 rdfs:subClassOf ?superClass2.
      ?superClass2 rdfs:subClassOf ?superClass3.
      ?otherClass2 rdfs:subClassOf ?superClass3.
      ?otherClass1 rdfs:subClassOf ?otherClass2.
      ?otherDrug rdfs:subClassOf ?otherClass1.
      ?otherDrug skos:prefLabel ?additionalLabel.
      FILTER(?additionalLabel != ?drugName)
    }
  "
  let $sparql-results := sem:sparql( $sparql, $bindings )
  let $local-results :=
    for $addition in $sparql-results
    let $additional-label := lower-case(map:get($addition, "additionalLabel"))
    return $additional-label
  let $discovered-terms := insert-before($discovered-terms, 1, $local-results)
  return if (exists($local-results))
         then exp:expand-brands($local-results, $discovered-terms, false())
         else $discovered-terms
};

declare function exp:expand-brands($qtexts,
                                   $discovered-terms,
                                   $should-show-classes)
{
  let $bindings := map:entry(
    "drugName", (
      for $query-word in $qtexts
      let $downcase-name := lower-case($query-word)
      let $titleized-name := concat(upper-case(substring($query-word, 1, 1)),
                               lower-case(substring($query-word, 2)))
      return (
        rdf:langString($titleized-name, "eng"),
        rdf:langString($downcase-name, "eng")
      )))
  let $sparql := "
    PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
    PREFIX rxn:  <http://purl.bioontology.org/ontology/RXNORM/>
    PREFIX atc: <http://purl.bioontology.org/ontology/UATC/>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    SELECT ?additionalLabel 
    WHERE {
      ?s skos:prefLabel ?drugName.
      {?s rxn:tradename_of ?additional.}
      UNION
      {?s rxn:has_tradename ?additional.}
      UNION
      # finding equivalent brand names
      {
        ?s rxn:tradename_of ?generic.
        ?generic rxn:has_tradename ?additional.
      }
      ?additional skos:prefLabel ?additionalLabel.
    } LIMIT 50"
  let $sparql-results := sem:sparql( $sparql, $bindings )
  let $local-results :=
    for $addition in $sparql-results
    let $additional-label := lower-case(map:get($addition, "additionalLabel"))
    return $additional-label
  let $discovered-terms := insert-before($discovered-terms, 1, $local-results)
  return
    if ($should-show-classes and exists($local-results))
    then exp:expand-drug-classes(insert-before($local-results, 1, $qtexts), $discovered-terms)
    else $discovered-terms
};

declare 
%roxy:params("qtext=xs:string", "brands=xs:string", "drugClasses=xs:string")
function exp:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  map:put($context, "output-types", "application/json"),
  let $qtext := (map:get($params, "qtext"), "")[1]
  let $should-show-brands := exp:process-boolean-param($params, "brands")
  let $should-show-classes := exp:process-boolean-param($params, "drugClasses")
  let $additional-terms :=
    if ($qtext != "")
    then
      let $qtexts := tokenize($qtext, " ")
      let $discovered-terms :=
        if ($should-show-classes or $should-show-brands)
        then exp:expand-brands($qtexts, (), $should-show-classes)
        else ()
      return json:to-array(distinct-values($discovered-terms))

    else json:array()

  let $response := json:object()
  let $add-original-qtext := map:put($response, "originalQuery", $qtext)
  let $add-brand-boolean := map:put($response, "brands", $should-show-brands)
  let $add-class-boolean := map:put($response, "drugClasses",
                                               $should-show-classes)
  let $add-expansion := map:put($response, "additionalTerms",
                                           $additional-terms)
  return (
   xdmp:set-response-code(200, "OK"),
   document { xdmp:to-json($response) }
  )
};
