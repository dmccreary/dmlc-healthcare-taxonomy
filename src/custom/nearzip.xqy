xquery version "1.0-ml";

module namespace near-zip = "http://marklogic.com/facet/near-zip";

import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

declare namespace zip-geo = "geonames.org/zip-geo";

declare function near-zip:parse-structured (
  $query-elem as element(),
  $options as element(search:options)
) as schema-element(cts:query)
{
  let $zip-el := $query-elem/search:zip
  let $radius-el := $query-elem/search:radius

  let $query :=
    if ($zip-el/xs:string(.) and $radius-el/fn:string(.) castable as xs:double)
    then
      let $zip := $zip-el/fn:string(.)
      let $radius := $radius-el/xs:double(.)

      let $constraint-name := $query-elem/search:constraint-name/fn:string()
      let $constraint-text := $query-elem/search:value/fn:string()
      let $constraint := $options/search:constraint[@name = $constraint-name]
      let $config := $constraint/search:custom/search:annotation/search:geo-attr-pair

      let $query :=
        cts:element-attribute-pair-geospatial-query(
          fn:QName($config/search:parent/@ns, $config/search:parent/@name),
          fn:QName($config/search:lat/@ns, $config/search:lat/@name),
          fn:QName($config/search:lon/@ns, $config/search:lon/@name),
          cts:circle($radius,
            cts:search(/zip-geo:zip_geo, cts:element-value-query(xs:QName("zip-geo:postal"), $zip, "exact"))/cts:point(zip-geo:latitude/xs:double(.), zip-geo:longitude/xs:double(.))
          )
        )
      return
        $query
    else
        cts:and-query(())
  return
    document { $query }/*
};


declare function near-zip:start(
  $constraint as element(search:constraint),
  $query as cts:query?,
  $facet-options as xs:string*,
  $quality-weight as xs:double?,
  $forests as xs:unsignedLong*)
as item()*
{
  ()
};

declare function near-zip:finish(
  $start as item()*,
  $constraint as element(search:constraint),
  $query as cts:query?,
  $facet-options as xs:string*,
  $quality-weight as xs:double?,
  $forests as xs:unsignedLong*)
as element(search:facet)
{
  element search:facet {
    attribute name {$constraint/@name},
    for $range in $start
    return element search:facet-value{
      attribute name { fn:string($range/@name) },
      attribute count { fn:string($range/@count) },
      fn:string($range/@name)
    }
  }
};
