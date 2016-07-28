xquery version "1.0-ml";

module namespace smartlogic = "http://marklogic.com/ns/smartlogic";

declare option xdmp:mapping "false";

declare variable $keys := map:map();

declare function smartlogic:build-keys($doc)
{
  for $key in $doc//*:META[@key|@CandidateKey]
  return
    map:put($keys, ($key/@CandidateKey, $key/@key)[1], $key)
};

declare function smartlogic:walk($nodes as node()*)
{
  for $n in $nodes
  return
    typeswitch($n)
      case element(PARAGRAPH) return
        element txt {
          smartlogic:walk($n/node())
        }
      case element(KEY) return
        let $key := map:get($keys, $n/@ID)
        return
          if (fn:empty($n/text()) or $n/text() = "") then
            smartlogic:walk($n/node())
          else
            element Semaphore {
              attribute x { $n/@ID },
              attribute class { $key/@name },
              attribute value { $key/@value },
              attribute score { $key/@score },
              attribute ID { $key/@id },
              smartlogic:walk($n/node())
            }
      case element() return
        element { fn:local-name($n) } {
          smartlogic:walk(($n/@*, $n/node()))
        }
      default return
        $n
};

declare function smartlogic:enrich($txt as xs:string)
{
  let $request :=
    <request op="CLASSIFY">
      <document>
        <body type="TEXT">{$txt}</body>
        <path/>
        <multiarticle/>
        <language>Default</language>
        <threshold>48</threshold>
        <clustering type="RMS" threshold="20"/>
        <operation_mode>CSTI</operation_mode>
        <feedback/>
        <use_generated_keys/>
      </document>
    </request>
  let $payload := fn:encode-for-uri(xdmp:quote($request))
  let $resp := xdmp:http-post(
    "http://sandbox13.smartlogic.com:5058/cat/index.html",
    <options xmlns="xdmp:http">
      <timeout>100</timeout>
      <data>XML_INPUT={$payload}</data>
    </options>)
  let $result :=
    if ($resp[1]/*:code = 200) then
      $resp[2]/*:response/*:STRUCTUREDDOCUMENT
    else
      $resp
  let $_ := smartlogic:build-keys($result)
  return
    smartlogic:walk($result/ARTICLE/PARAGRAPH)
};
