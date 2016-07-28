xquery version "1.0-ml";
module namespace trns = "http://marklogic.com/transform/icd9-to-snomed";

import module namespace m = "http://marklogic.com/roxy/models/provider.xqy" at "/lib/provider-lib.xqy";

declare function trns:transform(
  $content as map:map,
  $context as map:map
) as map:map*
{
  let $doc := map:get($content, 'value')
  let $doc :=
    typeswitch($doc)
      case document-node() return
        $doc/*
      default return
        $doc
  let $doc :=
    element { fn:node-name($doc) }
    {
      $doc/namespace::*,
      $doc/@*,
      element ICD_CODE { $doc/*:ICD_CODE/fn:replace(., "\.", "") },
      $doc/*[fn:not(self::ICD_CODE)]
    }
  let $_ := map:put($content, 'value', document { $doc })
  where $doc
  return
    $content
};
