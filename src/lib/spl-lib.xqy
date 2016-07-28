xquery version "1.0-ml";

module namespace spl = "http://marklogic.com/dmlc-healthcare/spl/lib";

declare namespace hl7="urn:hl7-org:v3";

declare variable $spl:cache-dir := "/spl-cached-html/";
declare variable $spl:cache-collection := "spl-cached-html";
declare variable $spl:img-prefix := "/v1/documents?format=binary&amp;uri=";

declare function spl:find-by-drug-name($drug-name as xs:string) as document-node()?
{
  cts:search(
    fn:doc(),
    cts:and-query((
      cts:collection-query("spl"),
      cts:word-query(
        fn:tokenize(fn:lower-case($drug-name), " ")[1], "case-insensitive"))),
    "unfiltered")[1]
};

declare function spl:find-by-spl-code($spl-code as xs:string) as document-node()?
{
  cts:search(
    fn:doc(),
    cts:and-query((
      cts:collection-query("spl"),
      cts:path-range-query(
        '/hl7:document//hl7:code[@codeSystem="2.16.840.1.113883.6.69"]/@code',
        '=',
        $spl-code,
        ("collation=http://marklogic.com/collation/codepoint")))), "unfiltered")[1]
};

declare function spl:img-path($x, $directory) as xs:string?
{
  let $uri :=
    let $val := $directory || $x
    return
      if (fn:doc-available($val))
      then $val
      else (
        xdmp:log("uri match: " || $x),
        cts:uri-match("/spl/*" || $x, 'limit=1')
      )
  return
    if (fn:exists($uri))
    then "/v1/documents?format=binary&amp;uri=" || $uri
    else ()
};

declare function spl:entity($x as element(Semaphore))
{
  let $class :=
    fn:replace(
      fn:replace(
        fn:lower-case($x/@class), "[^\w]+", "-"),
        "medicine-([^-]+)-([^-]+)", "medicine-$2")
  return
    element span {
      attribute popover-html {
        xdmp:quote(
          element div {
            element span { $x/@class || ":" },
            element strong { $x/fn:string() }
          })
      },
      attribute popover-title { $x/@class },
      attribute class { $class },
      $x/fn:string()
    }
};

declare function spl:transform-html($x, $directory as xs:string)
{
  typeswitch($x)
  case element(img) return
    element { fn:node-name($x) } {
      $x/@* except $x/@src,
      attribute src { spl:img-path($x/@src, $directory) },
      $x/node() ! spl:transform-html(., $directory)
    }
  case element(Semaphore) return spl:entity($x)
  case element() return
    element { fn:node-name($x) } {
      $x/@*,
      $x/node() ! spl:transform-html(., $directory)
    }
  default return $x
};

declare function spl:directory($uri as xs:string) as xs:string
{
  fn:string-join(fn:reverse(fn:tail(fn:reverse(fn:tokenize($uri, "/")))), "/") || "/"
};

declare function spl:generate-html($doc as document-node()) as element(transformed-spl)
{
  let $directory := spl:directory($doc/fn:base-uri(.))
  return
    element transformed-spl {
      element original-uri { $doc/fn:base-uri() },
      element id { $doc/hl7:document/hl7:id/@root/fn:string() },
      element contents {
        (: xdmp:invoke("/transform/spl-html.xqy", (xs:QName("doc"), $doc)) :)
        element div {
          attribute class { "spl" },
          xdmp:xslt-invoke("/lib/external/spl-stylesheet-5.9/spl.xsl", $doc)
            /html/body/node() ! spl:transform-html(., $directory)
        }
      }
    }
};

declare function spl:save-cached(
  $uri as xs:string,
  $spl-html as element(transformed-spl),
  $permissions as element()*
)
{
  xdmp:spawn-function(function() {
    (: function-lookup syntax thwarts static analysis :)
    xdmp:document-insert#4($uri, $spl-html, $permissions, $spl:cache-collection),
    xdmp:commit()
  },
  <options xmlns="xdmp:eval">
    <transaction-mode>update</transaction-mode>
  </options>)
};

declare function spl:get-html($doc as document-node()) as element(div)
{
  let $cached-uri := $spl:cache-dir || $doc/hl7:document/hl7:id/@root/fn:string() || ".xml"
  return (
    if (fn:doc-available($cached-uri))
    then fn:doc($cached-uri)/transformed-spl
    else
      let $spl-html := spl:generate-html($doc)
      return (
        spl:save-cached($cached-uri,$spl-html,
          xdmp:document-get-permissions($doc/fn:base-uri())),
        $spl-html
      )
  )/contents/div
};

declare function spl:get-json-summary($doc as document-node())
{
  let $report := $doc/hl7:document
  return
    map:new((
      map:entry("docType", "spl"),
      map:entry("drug", ($report//hl7:title/hl7:content/fn:string())[1]),
      map:entry("address1", $report//hl7:representedOrganization/hl7:name/fn:string()),
      map:entry("address2", $report//hl7:assignedOrganization/hl7:name/fn:string()),
      map:entry("title", fn:string-join(spl:get-html($doc)//*:p[@class = "DocumentTitle"]//text(), ' ')),
      map:entry("partName", ($report//hl7:manufacturedProduct/hl7:name/fn:string())[1]),
      map:entry("genericName", ($report//hl7:asEntityWithGeneric/hl7:genericMedicine/hl7:name/fn:string())[1]),
      map:entry("ingredients",
        json:to-array(
          fn:distinct-values($report//hl7:ingredient/hl7:ingredientSubstance/hl7:name))),
      map:entry("activeIngredients",
        json:to-array(
          fn:distinct-values($report//hl7:activeIngredient/hl7:activeIngredientSubstance/hl7:name))),
      map:entry("inactiveIngredients",
        json:to-array(
          fn:distinct-values($report//hl7:inactiveIngredient/hl7:inactiveIngredientSubstance/hl7:name)))

      (:
      ,
      let $directory := spl:directory($report/fn:base-uri(.))
      return
        map:entry("productLabels",
          ($report//*:reference/@value/fn:string())[1 to 10] ! spl:img-path(., $directory))
      :)

    )) ! xdmp:to-json(.)
};
