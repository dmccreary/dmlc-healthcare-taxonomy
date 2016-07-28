xquery version "1.0-ml";

module namespace trns = "http://marklogic.com/rest-api/transform/literature";

declare namespace roxy = "http://marklogic.com/roxy";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

declare function trns:walk($nodes as node()*)
{
  for $n in $nodes
  return
    typeswitch($n)
      case element(xhtml:link) return
        element link {
          attribute rel {
            "stylesheet"
          },
          attribute type {
            "text/css"
          },
          attribute href {
            "/v1/documents?uri=" || fn:encode-for-uri("/literature/" || $n/@href)
          }
        }
      case element(xhtml:img) return
        element img {
          $n/@*[fn:local-name(.) ne 'src'],
          attribute src {
            if (fn:starts-with($n/@src, 'http')) then
              fn:data($n/@src)
            else
              "/v1/documents?uri=" || fn:encode-for-uri("/literature/" || $n/@src)
          }
        }
      case element() return
        element { fn:local-name($n) } {
          trns:walk(($n/@*, $n/node()))
        }
      default return
        $n
};


declare function trns:transform(
  $context as map:map,
  $params as map:map,
  $content as document-node()
) as document-node()
{
  document {
    xdmp:to-json( map:new((map:entry("content", <div>{trns:walk($content//*:body/*|$content//*:link[@rel="stylesheet"])}</div>))))
  }
};
