let $uris :=
  let $words := ('crestor', 'symbicort', 'brilinta', 'seroquel', 'farxiga', 'movantik', 'arimidex', 'lynparza', 'onglyza')
  for $uri in cts:uris((), (), cts:and-query((cts:collection-query("spl"), cts:word-query($words))))
  where fn:not(fn:doc($uri)//*:Semaphore)
  return
    $uri
return
  (fn:count($uris), $uris)
