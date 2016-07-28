xquery version "1.0-ml";

module namespace faers-json = "http://marklogic.com/dmlc-healthcare/faers/json";

import module namespace json="http://marklogic.com/xdmp/json"
     at "/MarkLogic/json/json.xqy";

declare namespace faers = "http://fda.gov/ns/faers";

declare function faers-json:walk-summary($nodes as node()*)
{
  for $n in $nodes
  return
    typeswitch($n)
      case element(Semaphore) return
        map:new((
          map:entry("type", $n/@class),
          map:entry("value", $n/@value),
          map:entry("score", $n/@score),
(:          if ($n/*:Semaphore) then
            let $_ := xdmp:log($n)
            let $children := json:array()
            let $_ :=
              for $c in $n/element()
              return
                json:array-push($children, faers-json:walk-summary($c))
            return
            (
              map:entry("text", fn:string-join($n/text(), " ")),
              map:entry("children", $children)
            )
          else:)
            map:entry("text", fn:string($n))
        ))
      default return
        $n
};

declare function faers-json:transform($report as element(faers:faers))
{
  let $date-received := xs:date(fn:replace($report/faers:original/*:ichicsr/*:safetyreport/*:receivedate, '(\d\d\d\d)(\d\d)(\d\d)', '$1-$2-$3'))
  return
    map:new((
      map:entry("docType", "faers"),
      map:entry("status", $report/faers:meta/faers:status/fn:data(.)),
      map:entry("reportId", $report/faers:original/*:ichicsr/*:safetyreport/*:safetyreportid/fn:data(.)),
      map:entry("dateReceived", xs:date(fn:replace($report/faers:original/*:ichicsr/*:safetyreport/*:receivedate, '(\d\d\d\d)(\d\d)(\d\d)', '$1-$2-$3'))),
      map:entry("reporter",
        map:new((
          map:entry("firstName", $report/faers:original/*:ichicsr/*:safetyreport/*:sender/*:sendergivename/fn:data(.)),
          map:entry("lastName", $report/faers:original/*:ichicsr/*:safetyreport/*:sender/*:senderfamilyname/fn:data(.)),
          map:entry("address",
            map:new((
              map:entry("street", $report/faers:original/*:ichicsr/*:safetyreport/*:sender/*:senderstreetaddress/fn:data(.)),
              map:entry("city", $report/faers:original/*:ichicsr/*:safetyreport/*:sender/*:sendercity/fn:data(.)),
              map:entry("state", $report/faers:original/*:ichicsr/*:safetyreport/*:sender/*:senderstate/fn:data(.)),
              map:entry("zip", $report/faers:original/*:ichicsr/*:safetyreport/*:sender/*:senderpostcode/fn:data(.)),
              map:entry("country", $report/faers:original/*:ichicsr/*:safetyreport/*:sender/*:sendercountrycode/fn:data(.))
            ))
          ),
          map:entry("telephone", fn:string-join((
            $report/faers:original/*:ichicsr/*:safetyreport/*:sender/*:sendertelcountrycode,
            fn:replace($report/faers:original/*:ichicsr/*:safetyreport/*:sender/*:sendertel, '(\d\d\d)(\d\d\d)(\d\d\d\d)', '($1) $2-$3')), " ")),
          map:entry("fax", fn:string-join((
            $report/faers:original/*:ichicsr/*:safetyreport/*:sender/*:senderfaxcountrycode,
            fn:replace($report/faers:original/*:ichicsr/*:safetyreport/*:sender/*:senderfax, '(\d\d\d)(\d\d\d)(\d\d\d\d)', '($1) $2-$3')), " ")),
          map:entry("email", $report/faers:original/*:ichicsr/*:safetyreport/*:sender/*:senderemailaddress/fn:data(.))
        ))
      ),
      map:entry("patient",
        map:new((
          map:entry("initials", $report/faers:original/*:ichicsr/*:safetyreport/*:patient/*:patientinitial/fn:data(.)),
          map:entry("gender", $report/faers:meta/faers:gender/fn:data(.)),
          if ($report/faers:original/*:ichicsr/*:safetyreport/*:patient/*:patientbirthdate) then
            let $birth-date := xs:date(fn:replace($report/faers:original/*:ichicsr/*:safetyreport/*:patient/*:patientbirthdate, '(\d\d\d\d)(\d\d)(\d\d)', '$1-$2-$3'))
            let $days := fn:days-from-duration($date-received - $birth-date)
            let $estimate := $days idiv 365
            return
              map:entry("age", $estimate)
          else (),
          if ($report/faers:original/*:ichicsr/*:safetyreport/*:patient/*:patientonsetage) then
            map:entry("age", $report/faers:original/*:ichicsr/*:safetyreport/*:patient/*:patientonsetage/fn:data(.))
          else (),
          if ($report/faers:original/*:ichicsr/*:safetyreport/*:patient/*:patientweight) then
            map:entry("weight", $report/faers:original/*:ichicsr/*:safetyreport/*:patient/*:patientweight/fn:data(.))
          else ()
        ))
      ),
      map:entry("outcomes",
        map:new((
          map:entry("death", $report/faers:original/*:ichicsr/*:safetyreport/*:seriousnessdeath = 1),
          map:entry("lifeThreatening", $report/faers:original/*:ichicsr/*:safetyreport/*:seriousnesslifethreatening = 1),
          map:entry("hospitalization", $report/faers:original/*:ichicsr/*:safetyreport/*:seriousnesshospitalization = 1),
          map:entry("disabling", $report/faers:original/*:ichicsr/*:safetyreport/*:seriousnessdisabling = 1),
          map:entry("birthDefect", $report/faers:original/*:ichicsr/*:safetyreport/*:seriousnesscongenitalanomali = 1)
        ))
      ),
      map:entry("whatHappened", faers-json:walk-summary($report/faers:original/*:ichicsr/*:safetyreport/*:patient/*:summary/*:narrativeincludeclinical/node())),
      let $drugs := json:array()
      let $_ :=
        for $drug in fn:distinct-values($report/faers:original/*:ichicsr/*:safetyreport/*:patient/*:drug/*:medicinalproduct)
        return
          json:array-push($drugs, $drug)
      return
        map:entry("drugs", $drugs),
      let $reactions := json:array()
      let $_ :=
        for $reaction as xs:string in fn:distinct-values($report/faers:meta/faers:reactions/faers:reaction)
        return
          json:array-push($reactions, $reaction)
      return
        map:entry("reactions", $reactions)

    )) ! xdmp:to-json(.)
};
