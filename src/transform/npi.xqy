xquery version "1.0-ml";
module namespace trns = "http://marklogic.com/transform/npi";

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
  let $profile := m:build-profile($doc)
  let $_ := map:put($content, 'value', document { $profile })
  where $profile
  return
    $content
};
