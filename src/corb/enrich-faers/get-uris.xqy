let $uris := cts:uris((), (), cts:collection-query("faers"))
return
  (fn:count($uris), $uris)
