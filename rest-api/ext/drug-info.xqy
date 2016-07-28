(:
 : This extension will render an html view of drug information. This was created for a joint demo with Tableau for
 : the HIMSS conference 2015. Tableau will call this endpoint to display an iframe window inside the Tableau dashboard.
:)
xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/medication-info";

declare namespace roxy = "http://marklogic.com/roxy";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare namespace hl7 = "urn:hl7-org:v3";

declare
%roxy:params("ndc=xs:string", "drugName=xs:string")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  map:put($context, "output-types", "text/html"),
  let $drug-name := map:get($params, 'drugName') ! fn:lower-case(.)
  let $ndc := map:get($params, "ndc")
  let $query :=
    if ($ndc) then
      cts:path-range-query(
        '/hl7:document//hl7:code[@codeSystem="2.16.840.1.113883.6.69"]/@code',
        '=',
        $ndc,
        ("collation=http://marklogic.com/collation/codepoint"))
    else
      cts:word-query(fn:tokenize($drug-name, " ")[1], "case-insensitive")
  let $content := cts:search(fn:doc(), cts:and-query((cts:collection-query("spl"), $query)), "unfiltered")[1]
  let $name := ($content//hl7:manufacturedProduct/hl7:name/fn:string())[1]
  return
  (
    xdmp:set-response-code(200, "OK"),
    document {
      <html>
        <head>
          <title>{$name}</title>
          <style>{
          '.spl-popup {
            height: 400px;
            overflow: scroll;

            ul.product-labels {
              list-style: none;
              margin-left: 0px;
              padding-left: 0px;

              img {
                max-width: 500px;
              }
            }
          }'}
          </style>
        </head>
        <body>
          <div>
            <ul class="product-labels">
            {
              for $image-ref in ($content//*:reference/@value/fn:string())[1 to 10]
              let $image-uri := cts:uri-match("/spl/*" || $image-ref, 'limit=1')
              where $image-uri
              return
                <li>
                  <img src="/v1/documents?format=binary&amp;uri={fn:encode-for-uri($image-uri)}"/>
                </li>
            }
            </ul>
          </div>
          <div class="span12">
            <div class="drug">{($content//hl7:title/hl7:content/fn:string())[1]}</div>
            <div class="author">
              <address>{$content//hl7:representedOrganization/hl7:name/fn:string()}</address>
              <address>{$content//hl7:assignedOrganization/hl7:name/fn:string()}</address>
            </div>
            <div>
              <div>
                <div>
                  <span class="text-info">Medicine Ingredients</span>
                </div>
                <div>
                  <div>
                    <div class="medicine">
                      <h4>{$name}</h4>
                      <div class="names">
                        Generic: <span class="generic">{($content//hl7:asEntityWithGeneric/hl7:genericMedicine/hl7:name/fn:string())[1]}</span>
                        <br/>
                        Ingredients:
                      </div>
                      {
                        for $ingredient in fn:distinct-values($content//hl7:ingredient/hl7:ingredientSubstance/hl7:name)
                        return
                          <div class="ingredient">
                            <span>{$ingredient}</span>
                          </div>
                      }
                    </div>
                  </div>
                </div>
              </div>
              <div>
                <div>
                  <span class="text-danger">Warnings &amp; Precautions</span>
                </div>
                <div>
                  {
                    for $warning in $content//hl7:component/hl7:section/hl7:text
                    return
                      <div class="textWarnings">
                        <p>
                          {$warning}
                        </p>
                      </div>
                  }
                </div>
              </div>
            </div>
          </div>
        </body>
      </html>
    }
  )
};
