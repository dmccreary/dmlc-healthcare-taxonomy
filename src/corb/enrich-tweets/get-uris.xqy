let $uris :=
  cts:uris((), (),
    cts:and-query((
      cts:collection-query("tweets"),
      cts:not-query(cts:element-query(xs:QName("enriched"), cts:and-query(()))))))
return
  (fn:count($uris), $uris)
