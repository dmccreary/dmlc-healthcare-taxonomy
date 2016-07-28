xquery version "1.0-ml";

module namespace prescriber-json = "http://marklogic.com/dmlc-healthcare/prescriber/json";

declare function prescriber-json:to-camel-case($str as xs:string) as xs:string
{
  if( fn:matches($str , "[-_]" ) ) then
    let $subs :=  fn:tokenize($str,"[-_]")
    return
     fn:string-join((
        $subs[1] ,
          for $s in $subs[ fn:position() gt 1 ]
          return (
               fn:upper-case( fn:substring($s , 1 , 1 )) , fn:lower-case(fn:substring($s,2)))),"")
   else $str
};

declare function prescriber-json:transform($doc as element(prescriber-charge-data))
{
  xdmp:to-json(map:new(
    for $x in $doc/*
    let $data := fn:data($x)
    let $data :=
      if ($data castable as xs:decimal) then xs:decimal($data)
      else
        $data
    return
      map:entry(prescriber-json:to-camel-case(fn:local-name($x)), $data)
  ))
};
