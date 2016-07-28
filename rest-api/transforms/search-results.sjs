var patientJson = require('/lib/patient-json.xqy');
var claimJson = require('/lib/claim-json.xqy');
var providerJson = require('/lib/provider-json.xqy');
var faersJson = require('/lib/faers-json.xqy');
var diabetesJson = require('/lib/diabetes-json.xqy');
var spl = require('/lib/spl-lib.xqy');
var tweetJson = require('/lib/tweet-json.xqy');
var prescriber = require('/lib/prescriber-json.xqy');

function transform(context, params, content)
{
  var response = content.toObject();

  for (var i = 0; i < response.results.length; i++) {
    var result = response.results[i];
    var doc = cts.doc(result.uri).root;
    var localName = fn.localName(doc);
    result.type = xdmp.documentGetCollections(result.uri)[0];
    if (localName === 'ClinicalDocument') {
      result.content = patientJson.transformLite(doc);
    }
    else if (localName === 'claim') {
      result.content = claimJson.transform(doc);
    }
    else if (localName === 'provider') {
      result.content = providerJson.transform(doc);
    }
    else if (localName === 'faers') {
      result.content = faersJson.transform(doc);
    }
    else if (localName === 'diabetes') {
      result.content = diabetesJson.transform(doc);
    }
    else if (localName === 'document') {
      result.content = spl.getJsonSummary(cts.doc(result.uri));
    }
    else if (localName === 'tweet-envelope') {
      result.content = tweetJson.transform(doc);
    }
    else if (localName === 'prescriber-charge-data') {
      result.content = prescriber.transform(doc);
    }
  }
  return response;
}

exports.transform = transform;
