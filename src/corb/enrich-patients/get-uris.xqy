let $uris := cts:uris((), (), cts:collection-query("patient"))
return
  (fn:count($uris), $uris)
