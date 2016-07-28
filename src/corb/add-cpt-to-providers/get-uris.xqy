let $uris := cts:uris((), (), cts:collection-query("provider"))
return
  (fn:count($uris), $uris)
