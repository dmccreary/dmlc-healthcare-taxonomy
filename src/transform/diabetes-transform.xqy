xquery version "1.0-ml";

module namespace trns = "http://marklogic.com/transform/diabetes";

declare variable $ICD9-TO-SNOMED :=
  let $lookup := xdmp:get-server-field("icd9-to-snomed")
  return
    if (fn:exists($lookup)) then $lookup
    else
      let $lookup-map := map:map()
      let $_ :=
        for $n in /icd9-to-snomed
        let $snomed := $n/SNOMED_FSN/string()
        let $icd9-code := $n/ICD_CODE/string()
        return
          if (fn:not($snomed = "NULL")) then
            (map:put($lookup-map, fn:substring($icd9-code, 1, 3), $snomed),
            map:put($lookup-map, $icd9-code, $snomed))
          else ()
      return
        xdmp:set-server-field("icd9-to-snomed", $lookup-map);

declare function trns:fix-date($date)
{
  xs:date(fn:replace($date, "(\d\d\d\d)(\d\d)(\d\d)", "$1-$2-$3"))
};

declare function trns:icd9-to-element($icd9 as xs:string?)
{
  attribute code {$icd9},
  if ($icd9) then
    let $icd9-munged := fn:replace($icd9, "\.", "")
    let $snomed := map:get($ICD9-TO-SNOMED, $icd9-munged)
    return
      if ($snomed) then
        $snomed
      else ($icd9)
  else ()
};

declare function trns:walk($nodes as node()*)
{
  for $n in $nodes
  return
    typeswitch($n)
      case element(age) return
        element age {
          fn:replace($n, "[\[\)]", "")
        }
      case element(race) return
        element race {
          if ($n = "?") then ("Unknown")
          else $n/fn:data(.)
        }
      case element(diag_1) return
        element diag_1 {
          trns:icd9-to-element($n)
        }
      case element(diag_2) return
        element diag_2 {
          trns:icd9-to-element($n)
        }
      case element(diag_3) return
        element diag_3 {
          trns:icd9-to-element($n)
        }
      case element() return
        element { fn:node-name($n) } {
          trns:walk(($n/@*, $n/node()))
        }
      case document-node() return
        trns:walk($n/*)
      default return
        if ($n = "?") then ()
        else $n
};

declare function trns:transform(
  $content as map:map,
  $context as map:map
) as map:map*
{
  let $doc := map:get($content, 'value')
  let $output := trns:walk($doc)
  let $_ := map:put($content, 'value', document { $output })
  where $output
  return
    $content
};
