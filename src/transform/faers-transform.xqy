
xquery version "1.0-ml";
module namespace trns = "http://marklogic.com/transform/faers";

(:import module namespace ct = "http://marklogic.com/ps/lib-ctakes" at "/app/models/lib-ctakes.xqy";:)
import module namespace codes = "http://marklogic.com/ns/codes" at "/lib/codes.xqy";

declare namespace roxy = "http://marklogic.com/roxy";
declare namespace v3 = "urn:hl7-org:v3";
declare namespace hl7="urn:hl7-org:v3";
declare namespace faers = "http://fda.gov/ns/faers";
declare namespace zip-geo = "geonames.org/zip-geo";

declare option xdmp:mapping "false";

declare %private function trns:status()
{
  if (sem:random() > .5) then "PENDING"
  else "APPROVED"
};

declare function trns:geocode(
  $zip as xs:string
) as element(faers:geo)?
{
  let $zip-info := /zip-geo:zip_geo[zip-geo:postal = $zip]
  return
    element faers:geo {
      if ($zip-info) then
      (
        element faers:lat { $zip-info/zip-geo:latitude/fn:data(.) },
        element faers:lng { $zip-info/zip-geo:longitude/fn:data(.) }
      )
      else ()
    }
};

declare %private function trns:gender(
  $gender-code,
  $text) as element(faers:gender)?
{
  let $gender :=
    switch($gender-code)
      case 1
      case "male" return "male"
      case 2
      case "female" return "female"
      default return
        if (cts:contains($text, "female")) then
          "female"
        else if (cts:contains($text, "male")) then
          "male"
        else "unknown"
  where $gender
  return
    element faers:gender { $gender }
};

declare %private function trns:get-country(
  $code as xs:string?) as xs:string?
{
  <codes>
    <o v="AF">Afghanistan</o>
    <o v="AX">Åland Islands</o>
    <o v="AL">Albania</o>
    <o v="DZ">Algeria</o>
    <o v="AS">American Samoa</o>
    <o v="AD">Andorra</o>
    <o v="AO">Angola</o>
    <o v="AI">Anguilla</o>
    <o v="AQ">Antarctica</o>
    <o v="AG">Antigua and Barbuda</o>
    <o v="AR">Argentina</o>
    <o v="AM">Armenia</o>
    <o v="AW">Aruba</o>
    <o v="AU">Australia</o>
    <o v="AT">Austria</o>
    <o v="AZ">Azerbaijan</o>
    <o v="BS">Bahamas</o>
    <o v="BH">Bahrain</o>
    <o v="BD">Bangladesh</o>
    <o v="BB">Barbados</o>
    <o v="BY">Belarus</o>
    <o v="BE">Belgium</o>
    <o v="BZ">Belize</o>
    <o v="BJ">Benin</o>
    <o v="BM">Bermuda</o>
    <o v="BT">Bhutan</o>
    <o v="BO">Bolivia, Plurinational State of</o>
    <o v="BQ">Bonaire, Sint Eustatius and Saba</o>
    <o v="BA">Bosnia and Herzegovina</o>
    <o v="BW">Botswana</o>
    <o v="BV">Bouvet Island</o>
    <o v="BR">Brazil</o>
    <o v="IO">British Indian Ocean Territory</o>
    <o v="BN">Brunei Darussalam</o>
    <o v="BG">Bulgaria</o>
    <o v="BF">Burkina Faso</o>
    <o v="BI">Burundi</o>
    <o v="KH">Cambodia</o>
    <o v="CM">Cameroon</o>
    <o v="CA">Canada</o>
    <o v="CV">Cape Verde</o>
    <o v="KY">Cayman Islands</o>
    <o v="CF">Central African Republic</o>
    <o v="TD">Chad</o>
    <o v="CL">Chile</o>
    <o v="CN">China</o>
    <o v="CX">Christmas Island</o>
    <o v="CC">Cocos (Keeling) Islands</o>
    <o v="CO">Colombia</o>
    <o v="KM">Comoros</o>
    <o v="CG">Congo</o>
    <o v="CD">Congo, the Democratic Republic of the</o>
    <o v="CK">Cook Islands</o>
    <o v="CR">Costa Rica</o>
    <o v="CI">Côte d&#39;Ivoire</o>
    <o v="HR">Croatia</o>
    <o v="CU">Cuba</o>
    <o v="CW">Curaçao</o>
    <o v="CY">Cyprus</o>
    <o v="CZ">Czech Republic</o>
    <o v="DK">Denmark</o>
    <o v="DJ">Djibouti</o>
    <o v="DM">Dominica</o>
    <o v="DO">Dominican Republic</o>
    <o v="EC">Ecuador</o>
    <o v="EG">Egypt</o>
    <o v="SV">El Salvador</o>
    <o v="GQ">Equatorial Guinea</o>
    <o v="ER">Eritrea</o>
    <o v="EE">Estonia</o>
    <o v="ET">Ethiopia</o>
    <o v="FK">Falkland Islands (Malvinas)</o>
    <o v="FO">Faroe Islands</o>
    <o v="FJ">Fiji</o>
    <o v="FI">Finland</o>
    <o v="FR">France</o>
    <o v="GF">French Guiana</o>
    <o v="PF">French Polynesia</o>
    <o v="TF">French Southern Territories</o>
    <o v="GA">Gabon</o>
    <o v="GM">Gambia</o>
    <o v="GE">Georgia</o>
    <o v="DE">Germany</o>
    <o v="GH">Ghana</o>
    <o v="GI">Gibraltar</o>
    <o v="GR">Greece</o>
    <o v="GL">Greenland</o>
    <o v="GD">Grenada</o>
    <o v="GP">Guadeloupe</o>
    <o v="GU">Guam</o>
    <o v="GT">Guatemala</o>
    <o v="GG">Guernsey</o>
    <o v="GN">Guinea</o>
    <o v="GW">Guinea-Bissau</o>
    <o v="GY">Guyana</o>
    <o v="HT">Haiti</o>
    <o v="HM">Heard Island and McDonald Islands</o>
    <o v="VA">Holy See (Vatican City State)</o>
    <o v="HN">Honduras</o>
    <o v="HK">Hong Kong</o>
    <o v="HU">Hungary</o>
    <o v="IS">Iceland</o>
    <o v="IN">India</o>
    <o v="ID">Indonesia</o>
    <o v="IR">Iran, Islamic Republic of</o>
    <o v="IQ">Iraq</o>
    <o v="IE">Ireland</o>
    <o v="IM">Isle of Man</o>
    <o v="IL">Israel</o>
    <o v="IT">Italy</o>
    <o v="JM">Jamaica</o>
    <o v="JP">Japan</o>
    <o v="JE">Jersey</o>
    <o v="JO">Jordan</o>
    <o v="KZ">Kazakhstan</o>
    <o v="KE">Kenya</o>
    <o v="KI">Kiribati</o>
    <o v="KP">Korea, Democratic People&#39;s Republic of</o>
    <o v="KR">Korea, Republic of</o>
    <o v="KW">Kuwait</o>
    <o v="KG">Kyrgyzstan</o>
    <o v="LA">Lao People&#39;s Democratic Republic</o>
    <o v="LV">Latvia</o>
    <o v="LB">Lebanon</o>
    <o v="LS">Lesotho</o>
    <o v="LR">Liberia</o>
    <o v="LY">Libya</o>
    <o v="LI">Liechtenstein</o>
    <o v="LT">Lithuania</o>
    <o v="LU">Luxembourg</o>
    <o v="MO">Macao</o>
    <o v="MK">Macedonia, the former Yugoslav Republic of</o>
    <o v="MG">Madagascar</o>
    <o v="MW">Malawi</o>
    <o v="MY">Malaysia</o>
    <o v="MV">Maldives</o>
    <o v="ML">Mali</o>
    <o v="MT">Malta</o>
    <o v="MH">Marshall Islands</o>
    <o v="MQ">Martinique</o>
    <o v="MR">Mauritania</o>
    <o v="MU">Mauritius</o>
    <o v="YT">Mayotte</o>
    <o v="MX">Mexico</o>
    <o v="FM">Micronesia, Federated States of</o>
    <o v="MD">Moldova, Republic of</o>
    <o v="MC">Monaco</o>
    <o v="MN">Mongolia</o>
    <o v="ME">Montenegro</o>
    <o v="MS">Montserrat</o>
    <o v="MA">Morocco</o>
    <o v="MZ">Mozambique</o>
    <o v="MM">Myanmar</o>
    <o v="NA">Namibia</o>
    <o v="NR">Nauru</o>
    <o v="NP">Nepal</o>
    <o v="NL">Netherlands</o>
    <o v="NC">New Caledonia</o>
    <o v="NZ">New Zealand</o>
    <o v="NI">Nicaragua</o>
    <o v="NE">Niger</o>
    <o v="NG">Nigeria</o>
    <o v="NU">Niue</o>
    <o v="NF">Norfolk Island</o>
    <o v="MP">Northern Mariana Islands</o>
    <o v="NO">Norway</o>
    <o v="OM">Oman</o>
    <o v="PK">Pakistan</o>
    <o v="PW">Palau</o>
    <o v="PS">Palestinian Territory, Occupied</o>
    <o v="PA">Panama</o>
    <o v="PG">Papua New Guinea</o>
    <o v="PY">Paraguay</o>
    <o v="PE">Peru</o>
    <o v="PH">Philippines</o>
    <o v="PN">Pitcairn</o>
    <o v="PL">Poland</o>
    <o v="PT">Portugal</o>
    <o v="PR">Puerto Rico</o>
    <o v="QA">Qatar</o>
    <o v="RE">Réunion</o>
    <o v="RO">Romania</o>
    <o v="RU">Russian Federation</o>
    <o v="RW">Rwanda</o>
    <o v="BL">Saint Barthélemy</o>
    <o v="SH">Saint Helena, Ascension and Tristan da Cunha</o>
    <o v="KN">Saint Kitts and Nevis</o>
    <o v="LC">Saint Lucia</o>
    <o v="MF">Saint Martin (French part)</o>
    <o v="PM">Saint Pierre and Miquelon</o>
    <o v="VC">Saint Vincent and the Grenadines</o>
    <o v="WS">Samoa</o>
    <o v="SM">San Marino</o>
    <o v="ST">Sao Tome and Principe</o>
    <o v="SA">Saudi Arabia</o>
    <o v="SN">Senegal</o>
    <o v="RS">Serbia</o>
    <o v="SC">Seychelles</o>
    <o v="SL">Sierra Leone</o>
    <o v="SG">Singapore</o>
    <o v="SX">Sint Maarten (Dutch part)</o>
    <o v="SK">Slovakia</o>
    <o v="SI">Slovenia</o>
    <o v="SB">Solomon Islands</o>
    <o v="SO">Somalia</o>
    <o v="ZA">South Africa</o>
    <o v="GS">South Georgia and the South Sandwich Islands</o>
    <o v="SS">South Sudan</o>
    <o v="ES">Spain</o>
    <o v="LK">Sri Lanka</o>
    <o v="SD">Sudan</o>
    <o v="SR">Suriname</o>
    <o v="SJ">Svalbard and Jan Mayen</o>
    <o v="SZ">Swaziland</o>
    <o v="SE">Sweden</o>
    <o v="CH">Switzerland</o>
    <o v="SY">Syrian Arab Republic</o>
    <o v="TW">Taiwan, Province of China</o>
    <o v="TJ">Tajikistan</o>
    <o v="TZ">Tanzania, United Republic of</o>
    <o v="TH">Thailand</o>
    <o v="TL">Timor-Leste</o>
    <o v="TG">Togo</o>
    <o v="TK">Tokelau</o>
    <o v="TO">Tonga</o>
    <o v="TT">Trinidad and Tobago</o>
    <o v="TN">Tunisia</o>
    <o v="TR">Turkey</o>
    <o v="TM">Turkmenistan</o>
    <o v="TC">Turks and Caicos Islands</o>
    <o v="TV">Tuvalu</o>
    <o v="UG">Uganda</o>
    <o v="UA">Ukraine</o>
    <o v="AE">United Arab Emirates</o>
    <o v="GB">United Kingdom</o>
    <o v="US">United States</o>
    <o v="UM">United States Minor Outlying Islands</o>
    <o v="UY">Uruguay</o>
    <o v="UZ">Uzbekistan</o>
    <o v="VU">Vanuatu</o>
    <o v="VE">Venezuela, Bolivarian Republic of</o>
    <o v="VN">Viet Nam</o>
    <o v="VG">Virgin Islands, British</o>
    <o v="VI">Virgin Islands, U.S.</o>
    <o v="WF">Wallis and Futuna</o>
    <o v="EH">Western Sahara</o>
    <o v="YE">Yemen</o>
    <o v="ZM">Zambia</o>
    <o v="ZW">Zimbabwe</o>
  </codes>/o[@v = $code]
};

declare %private function trns:fix-date($date)
{
  xs:date(fn:replace($date, "(\d\d\d\d)(\d\d)(\d\d)", "$1-$2-$3"))
};

declare %private function trns:walk($nodes as node()*)
{
  for $n in $nodes
  return
    typeswitch($n)
      case element(drugdosageform) return
        element drugdosageform {
          attribute normalized { cts:stem(fn:lower-case($n)) },
          $n/data(.)
        }
      case element(drugstartdate) |
              element(transmissiondate) |
              element(receivedate) |
              element(receiptdate) |
              element(drugstartdate) |
              element(drugenddate) return
        element { fn:node-name($n) } {
          let $format-name := fn:local-name($n) || "format"
          let $format := $n/../*[fn:local-name(.) = $format-name]/fn:string(.)
          return
            if ($format = "102") then
              trns:fix-date($n)
            else if ($format = "610") then
              trns:fix-date($n/fn:data(.) || "01")
            else $n/fn:data(.)
        }
      case element(qualification) return
        element qualification {
          attribute code { fn:data($n) },
          switch (fn:string($n))
            case "1" return "Physician"
            case "2" return "Pharmacist"
            case "3" return "Other Health Professional"
            case "4" return "Lawyer"
            case "5" return "Consumer or non-health professional"
            default return ()
        }
      case element(patientsex) return
        element patientsex {
          attribute code { fn:data($n) },
          switch (fn:string($n))
            case "0" return "Unknown"
            case "1" return "Male"
            case "2" return "Female"
            case "9" return "Unspecified"
            default return ()
        }
      case element(reactionoutcome) return
        element reactionoutcome {
          attribute code { fn:data($n) },
          switch (fn:string($n))
            case "1" return "recovered/resolved"
            case "2" return "recovering/resolved"
            case "3" return "not recovered/not resolved"
            case "4" return "recovered/resolved with sequelae"
            case "5" return "fatal"
            case "6" return "unknown"
            default return ()
        }
      case element(drugcharacterization) return
        element drugcharacterization {
          attribute code { fn:data($n) },
          switch (fn:string($n))
            case "1" return "suspsect"
            case "2" return "concomitant"
            case "3" return "interacting"
            default return ()
        }
      case element(drugstructuredosageunit) |
        element(drugcumulativedosageunit) return
        element { fn:node-name($n) } {
          attribute code { fn:data($n) },
          switch ($n)
            case "001" return "kilograms"
            case "002" return "grams"
            case "003" return "milligrams"
            case "004" return "micrograms"
            default return ()
        }
      case element(drugintervaldosagedefinition) |
        element(drugtreatmentdurationunit) return
        element { fn:node-name($n) } {
          attribute code { fn:data($n) },
          switch ($n)
            case "801" return "Year"
            case "802" return "Month"
            case "803" return "Week"
            case "804" return "Day"
            case "805" return "Hour"
            case "806" return "Minute"
            case "807" return "Second"
            case "810" return "Cyclical"
            case "811" return "Trimester"
            case "812" return "As Necessary"
            case "813" return "Total"
            default return ()
        }
      case element(actiondrug) return
        element actiondrug {
          attribute code { fn:data($n) },
          switch ($n)
            case "1" return "Drug Withdrawn"
            case "2" return "Dose Reduced"
            case "3" return "Dose Increased"
            case "4" return "Dose not changed"
            case "5" return "Unknown"
            case "6" return "Not Applicable"
            default return ()
        }
      case element(drugrecurreadministration) | element(serious) return
        element { fn:node-name($n) } {
          attribute code { fn:data($n) },
          switch ($n)
            case "1" return "Yes"
            case "2" return "No"
            case "3" return "Unknown"
            default return ()
        }
      case element(drugadditional) return
        element drugadditional {
          attribute code { fn:data($n) },
          switch ($n)
            case "1" return "Yes"
            case "2" return "No"
            case "3" return "Doesn't Apply"
            default return ()
        }
      case element(drugadministrationroute) return
        element drugadministrationroute {
          attribute code { fn:data($n) },
          switch ($n)
            case "001" return "Auricular (otic)"
            case "002" return "Buccal"
            case "003" return "Cutaneous"
            case "004" return "Dental"
            case "005" return "Endocervical"
            case "006" return "Endosinusial"
            case "007" return "Endotracheal"
            case "008" return "Epidural"
            case "009" return "Extra-amniotic"
            case "010" return "Hemodialysis"
            case "011" return "Intra corpus cavernosum"
            case "012" return "Intra-amniotic"
            case "013" return "Intra-arterial"
            case "014" return "Intra-articular "
            case "015" return "Intra-uterine"
            case "016" return "Intracardiac"
            case "017" return "Intracavernous"
            case "018" return "Intracerebral"
            case "019" return "Intracervical"
            case "020" return "Intracisternal"
            case "021" return "Intracorneal"
            case "022" return "Intracoronary"
            case "023" return "Intradermal"
            case "024" return "Intradiscal (intraspinal)"
            case "025" return "Intrahepatic"
            case "026" return "Intralesional"
            case "027" return "Intralymphatic"
            case "028" return "Intramedullar (bone marrow)"
            case "029" return "Intrameningeal"
            case "030" return "Intramuscular"
            case "031" return "Intraocular"
            case "032" return "Intrapericardial"
            case "033" return "Intraperitoneal"
            case "034" return "Intrapleural"
            case "035" return "Intrasynovial"
            case "036" return "Intratumor"
            case "037" return "Intrathecal"
            case "038" return "Intrathoracic"
            case "039" return "Intratracheal"
            case "040" return "Intravenous bolus"
            case "041" return "Intravenous drip"
            case "042" return "Intravenous (not otherwise specified)"
            case "043" return "Intravesical"
            case "044" return "Iontophoresis"
            case "045" return "Nasal"
            case "046" return "Occlusive dressing technique"
            case "047" return "Ophthalmic"
            case "048" return "Oral"
            case "049" return "Oropharingeal"
            case "050" return "Other"
            case "051" return "Parenteral"
            case "052" return "Periarticular"
            case "053" return "Perineural"
            case "054" return "Rectal"
            case "055" return "Respiratory (inhalation)"
            case "056" return "Retrobulbar"
            case "057" return "Sunconjunctival"
            case "058" return "Subcutaneous"
            case "059" return "Subdermal"
            case "060" return "Sublingual"
            case "061" return "Topical"
            case "062" return "Transdermal"
            case "063" return "Transmammary"
            case "064" return "Transplacental"
            case "065" return "Unknown"
            case "066" return "Urethral"
            case "067" return "Vaginal"
            default return ()
        }
      case element() return
        element { fn:node-name($n) } {
          trns:walk(($n/@*, $n/node()))
        }
      default return $n
};

declare %private function trns:get-ndc($medicine)
{
  let $medicine := fn:lower-case($medicine)
  let $ndcs :=
    let $keys as xs:string? := cts:search(fn:collection("new-ndc-codes")/code, cts:word-query($medicine))[1]/@key
    let $keys as xs:string? :=
      if ($keys) then $keys
      else
        cts:search(fn:collection("old-ndc-codes")/code, cts:word-query($medicine))[1]/@key
    return
      $keys
  return
    ($ndcs)[1]
(:  for $ndc in $ndcs
  return
   $ndc || " => " || map:get($codes:NEW-NDC-CODES, $ndc):)
};

declare function trns:normalize-ndc($ndc)
{
  if (fn:matches($ndc, "^\d+$")) then
    fn:replace($ndc, "(\d\d\d\d\d)(\d+)", "$1-$2")
  else
    $ndc
};

declare function trns:get-spl($ndc) as element(hl7:document)?
{
  (/hl7:document[hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:subject/hl7:manufacturedProduct/hl7:manufacturedProduct/hl7:code/@code=$ndc])[1]
};


declare %private function trns:meta-v2(
  $v2 as element(ichicsr)) as element(faers:meta)
{
  <meta xmlns="http://fda.gov/ns/faers">
  {
    <status>{trns:status()}</status>,

    <version>v2</version>,

    <patient-age>
    {
      let $date-received := xs:date(fn:replace($v2/*:safetyreport/*:receivedate, '(\d\d\d\d)(\d\d)(\d\d)', '$1-$2-$3'))
      return
        if ($v2/*:safetyreport/*:patient/*:patientbirthdate) then
          let $birth-date := xs:date(fn:replace($v2/*:safetyreport/*:patient/*:patientbirthdate, '(\d\d\d\d)(\d\d)(\d\d)', '$1-$2-$3'))
          let $days := fn:days-from-duration($date-received - $birth-date)
          let $estimate := $days idiv 365
          return
            $estimate
        else if ($v2/*:safetyreport/*:patient/*:patientonsetage) then
          $v2/*:safetyreport/*:patient/*:patientonsetage/fn:data(.)
        else ()
    }
    </patient-age>,

    (: report-id :)
    $v2/*:safetyreport/*:safetyreportid/<report-id>{fn:data(.)}</report-id>,

    (: gender :)
    trns:gender(
      $v2/*:safetyreport/*:patient/*:patientsex,
      $v2/*:safetyreport/*:patient/*:summary/*:narrativeincludeclinical),

    (: reactions :)
    let $reactions as xs:string* :=
      $v2/*:safetyreport/*:patient/*:reaction/*:primarysourcereaction
    where $reactions
    return
      <reactions>
      {
        fn:distinct-values($reactions) ! <reaction>{.}</reaction>
      }
      </reactions>,

    (: medicines :)
    let $drugs as xs:string* :=
      $v2/*:safetyreport/*:patient/*:drug/*:medicinalproduct
    where $drugs
    return
      <drugs>
      {
        for $drug in fn:distinct-values($drugs)
        let $ndc := trns:get-ndc($drug)
        let $normalized-ndc := trns:normalize-ndc($ndc)
        let $spl := trns:get-spl($normalized-ndc)
        return
          <drug>
            {
              if ($ndc[. ne ""]) then
                <ndc>{$ndc}</ndc>
              else ()
            }
            <drug-name>{$drug}</drug-name>
            {
              let $name := fn:normalize-space($spl/hl7:author/hl7:assignedEntity/hl7:representedOrganization/hl7:name)[. ne ""]
              where $name
              return
                <manufacturer>{$name}</manufacturer>
            }
            <ingredients>
            {
              for $ingredient as xs:string in $spl//hl7:ingredient/hl7:ingredientSubstance/hl7:name
              return
                <ingredient>{$ingredient}</ingredient>
            }
            </ingredients>
          </drug>
      }
      </drugs>,

    (: drug-indications :)
    let $indications as xs:string* :=
      $v2/*:safetyreport/*:patient/*:drug/*:drugindication
    where $indications
    return
      <indications>
      {
        fn:distinct-values($indications) ! <indication>{.}</indication>
      }
      </indications>,

    (: patient age :)
    $v2/*:safetyreport/*:patient/*:patientonsetage/<patient-age>{fn:data(.)}</patient-age>,

    (: outcomes :)
    <outcomes>
    {
      $v2/*:safetyreport/*:seriousnessdeath[. = 1]/<outcome>Death</outcome>,
      $v2/*:safetyreport/*:seriousnesslifethreatening[. = 1]/<outcome>Life Threatening</outcome>,
      $v2/*:safetyreport/*:seriousnesshospitalization[. = 1]/<outcome>Required Inpatient Hospitalization</outcome>,
      $v2/*:safetyreport/*:seriousnessdisabling[. = 1]/<outcome>Persistent Or Significant Disability</outcome>,
      $v2/*:safetyreport/*:seriousnesscongenitalanomali[. = 1]/<outcome>Congenital Anomaly BirthDefect</outcome>
    }
    </outcomes>,

    ($v2/*:safetyreport/*:primarysource/*:reportercountry)[1]/<country>{trns:get-country(.)}</country>,

    (: geo :)
    let $address :=
      $v2/*:safetyreport/*:sender/*:senderstreetaddress || " " ||
      $v2/*:safetyreport/*:sender/*:sendercity || ", " ||
      $v2/*:safetyreport/*:sender/*:senderstate || " " ||
      $v2/*:safetyreport/*:sender/*:senderpostcode || " " ||
      $v2/*:safetyreport/*:sender/*:sendercountrycode
    return
      trns:geocode($v2/*:safetyreport/*:sender/*:senderpostcode)
  }
  </meta>
};

declare
function trns:transform(
  $content as map:map,
  $context as map:map
) as map:map*
{
  let $doc := map:get($content, 'value')
  let $meta := trns:meta-v2($doc/*)
  let $new-doc :=
    if ($meta) then
      document
      {
        <faers xmlns="http://fda.gov/ns/faers">
          {$meta}
          <original>
          {
            trns:walk($doc/*)
          }
          </original>
        </faers>
      }
    else
      document { $doc }
  let $_ := map:put($content, 'uri', fn:replace($doc//*:safetyreportid, "[^0-9a-zA-Z]", ""))
  let $_ := map:put($content, 'value', $new-doc)
  return
    $content
};
