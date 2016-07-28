// MarkLogic contains many built-in functions that offer 
// fast and convenient programmatic access to MarkLogic 
// functionality. The built-in functions are available 
// as JavaScript functions without the need to import 
// or require any libraries (that is why they are called 'built-in'). 
//
// The functions are available via the following global objects:
// cts. fn. math. rdf. sc. sem. spell. sql. xdmp.
//
// https://docs.marklogic.com/guide/rest-dev/extensions#id_52937
//
// In a JavaScript extension, you cannot control the transaction 
// mode in which your get, put, post, or delete function runs. 
// Transaction mode is controlled by the REST API App Server.
//
// GET - query for a single statement transaction, update for 
//       a multi-statement transaction; that is, if your request 
//       includes a transaction id, the function runs in update mode.
// PUT - update
// POST - query for a single statement transaction, update for a 
//        multi-statement transaction; that is, if your request 
//        includes a transaction id, the function runs in update mode.
// DELETE - update

var sem = require("/MarkLogic/semantics.xqy");
var functx = require("/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy");
var search = require("/MarkLogic/appservices/search/search.xqy");
var thsr = require("/MarkLogic/thesaurus.xqy");

// PUT http://localhost:5042/v1/config/resources/taxonomy
// Content-Type: application/vnd.marklogic-javascript
// Body

var PREFIX_IRI = "http://healthcare.demo.marklogic.com";

var RESERVED_PREDICATES = [
  "path", "broader", "taxonomy", "children", "description", 
  "rule", "prefLabel", "narrower", "type", 
  "subClassOf", "scopeNote", "adopted"
];

var FILE_EXT_TO_PARSE_FORMAT = {
  "rdf": "rdfxml",
  "xml": "rdfxml",
  "ttl": "turtle"
};

// namespace list
var NS_RDF = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
var NS_SKOS = "http://www.w3.org/2004/02/skos/core#";
var NS_EPI = "http://healthcare.demo.marklogic.com/predicates#";
var NS_RDFS = "http://www.w3.org/2000/01/rdf-schema#";
var NS_OWL = "http://www.w3.org/2002/07/owl#";
var NS_UMLS = "http://bioportal.bioontology.org/ontologies/umls/";

// context-specific predicates
var PREDICATE_HAS_STY = fn.concat(NS_UMLS, "hasSTY");

// predicate list
var PREDICATE_TAXONOMY_NAMESPACE = fn.concat(NS_EPI, "namespace");
var PREDICATE_HIDDEN = fn.concat(NS_EPI, "hidden");
var PREDICATE_ADOPTED = fn.concat(NS_EPI, "adopted");
var PREDICATE_PATH = fn.concat(NS_EPI, "path");
var PREDICATE_EXPANDAS = fn.concat(NS_EPI, "expandAs");
var PREDICATE_EXPANDINCLUDE = fn.concat(NS_EPI, "expandInclude");
var PREDICATE_MOVE_FROM = fn.concat(NS_EPI, "move_from");
var PREDICATE_TAGDOCUMENT = fn.concat(NS_EPI, "tagdocument");
var PREDICATE_COLLECTIONMATCH = fn.concat(NS_EPI, "collection-match");
var PREDICATE_TAXONOMY = fn.concat(NS_EPI, "taxonomy");
var PREDICATE_RULE = fn.concat(NS_EPI, "rule");
var PREDICATE_CHILDREN = fn.concat(NS_EPI, "children");
var PREDICATE_TYPE = fn.concat(NS_EPI, "type");
var PREDICATE_CREATED = fn.concat(NS_EPI, "created");
var PREDICATE_AUTHOR = fn.concat(NS_EPI, "author");
var PREDICATE_MODIFIED = fn.concat(NS_EPI, "modified");
var PREDICATE_SAMEAS = fn.concat(NS_EPI, "sameas");
var PREDICATE_NUMBER_TAGGED_DOCUMENTS = fn.concat(NS_EPI, "numberTaggedDocuments");
var PREDICATE_NUMBER_DESCENDANTS_TAGGED_DOCUMENTS = fn.concat(NS_EPI, "numberDescendantsTaggedDocuments");
var PREDICATE_COLLECTION_MATCH = fn.concat(NS_EPI, "collection-match");

var PREDICATE_BROADER = fn.concat(NS_SKOS, "broader");
var PREDICATE_NARROWER = fn.concat(NS_SKOS, "narrower");
var PREDICATE_PREFLABEL = fn.concat(NS_SKOS, "prefLabel");
var PREDICATE_ALTLABEL = fn.concat(NS_SKOS, "altLabel");
var PREDICATE_HIDDENLABEL = fn.concat(NS_SKOS, "hiddenLabel");
var PREDICATE_SCOPENOTE = fn.concat(NS_SKOS, "scopeNote");
var PREDICATE_RDFSLABEL = fn.concat(NS_RDFS, "label");

var PREDICATE_RDFTYPE = fn.concat(NS_RDF, "type");
var PREDICATE_SUBCLASS_OF = fn.concat(NS_RDFS, "subClassOf");

// reserved object list
var OBJECT_TYPE_CONCEPT = fn.concat(NS_SKOS, "Concept"); 
var OBJECT_TYPE_CLASS = fn.concat(NS_OWL, "Class"); 
var OBJECT_CLASS_THING = fn.concat(NS_OWL, "Thing");

// groups of predicates
var PARENT_PREDICATES_GROUP = [ PREDICATE_BROADER, PREDICATE_SUBCLASS_OF ];
var ADOPTER_PREDICATES_GROUP = [ PREDICATE_HAS_STY ];

var SELECT_PREDICATES = [
  sem.iri(PREDICATE_PREFLABEL), 
  sem.iri(PREDICATE_SCOPENOTE), 
  sem.iri(PREDICATE_RULE), 
  sem.iri(PREDICATE_SAMEAS), 
  sem.iri(PREDICATE_CHILDREN), 
  sem.iri(PREDICATE_TAXONOMY), 
  sem.iri(PREDICATE_COLLECTION_MATCH)
];

PARENT_PREDICATES_GROUP.forEach(function(p) {
  SELECT_PREDICATES.push(sem.iri(p));
});

// Escapes a string if it contains space(s).
function escapeTerm(s) {
  s = fn.string(s);

  if (s.indexOf(" ") == -1) {
    return s;
  } else {
    return "\"" + s + "\"";
  }
}

// Removes the first and last character if they are
// double quote only when the string is NOT a string 
// query for OR.
function parseSearchTerm(s) {
  s = fn.string(s);

  if (s.indexOf(" OR ") == -1) {
    var len = s.length;

    if (s.charAt(len-1) == '"')
      s = s.substr(0, len-1);

    if (s.charAt(0) == '"')
      s = s.substr(1);

    return s;
  } else {
    return s;
  }
}

// Generates a unique identifier, starting with a letter
function generateId() {
  var startingLetters = [
    'a','b','c','d','e','f','g','h','i','j','k','l','m',
    'n','o','p','q','r','s','t','u','v','w','x','y','z'
  ];

  // We want the id to start with a letter, because 
  // valid xml local names always start with a letter.
  var rnd = xdmp.random(25);

  return fn.concat(startingLetters[(1+rnd)], xdmp.md5(sem.uuidString()));
}

function generateTaxonomyId() {
  return fn.concat(PREFIX_IRI, "/taxonomy/", generateId());
}

// Retrieves the status of a running operation by its progress ID
// @param progressId - The identifier of the operation
// @return A JSON object containing the operation progress and description
function checkProgress(context, params, input) {
  var progressId = xdmp.getRequestField('progressId');
  var uri = fn.concat("/progress/", progressId, ".json");
  var doc = fn.doc(uri);

  return doc;
}

// Saves taxonomy to the triplestore.
// @param map - The taxonomy details map
// @return - taxonomy triple subject as xs:string
function doCreateTaxonomy(map) {
  var taxonomy_subject = map["id"];
  var triples = [];

  triples.push(sem.triple(
    sem.iri(taxonomy_subject),
    sem.iri(PREDICATE_PREFLABEL),
    map["name"]
  ));

  triples.push(sem.triple(
    sem.iri(taxonomy_subject),
    sem.iri(PREDICATE_SCOPENOTE),
    map["description"]
  ));

  triples.push(sem.triple(
    sem.iri(taxonomy_subject),
    sem.iri(PREDICATE_TYPE),
    "none"
  ));

  var created = map["created"];
  if (!created) {
    created = fn.currentDateTime();
  }
  triples.push(sem.triple(
    sem.iri(taxonomy_subject),
    sem.iri(PREDICATE_CREATED),
    created
  ));

  triples.push(sem.triple(
    sem.iri(taxonomy_subject),
    sem.iri(PREDICATE_AUTHOR),
    map["author"]
  ));

  triples.push(sem.triple(
    sem.iri(taxonomy_subject),
    sem.iri(PREDICATE_MODIFIED),
    fn.currentDateTime()
  ));

  var namespace = map["namespace"];
  if (namespace) {
    triples.push(sem.triple(
      sem.iri(taxonomy_subject),
      sem.iri(PREDICATE_TAXONOMY_NAMESPACE),
      namespace
    ));
  }

  var uris = sem.rdfInsert(triples, [], [], ["taxonomy", map["id"]]);

  // Parses a string as XML - doc is ValueIterator, doc.count returns
  // number of items. In our case, the count is 1.
  var doc = xdmp.unquote('<thesaurus xmlns="http://marklogic.com/xdmp/thesaurus"></thesaurus>');
  var ele = doc.next().value.root;

  // Load the entries in thsr into the thesaurus at $uri.
  // If there is no document at $uri a new one will be created. 
  // If there is a document at $uri it will be overwritten.
  var uri = fn.concat("/thesaurus/", map["id"], ".xml");

  thsr.insert(uri, ele);

  // TO DO - return the newly created taxonomy.
  return uris;
}

// Deletes taxonomy and all associated concepts.
// @param $taxonomy-id - The taxonomy id
// @return empty result
function doDeleteTaxonomy(map) {
  var id = map["id"];

  // Delete related documents
  xdmp.collectionDelete(id);

  var uri = fn.concat("/thesaurus/", id, ".xml");

  // Delete thesaurus
  if (fn.exists(fn.doc(uri))) {
    xdmp.documentDelete(uri);
  }

  // Delete document tags
  /*for $concept in fn:collection("document-content")/document/concepts/concept[taxonomy_id eq $taxonomy-id] 
    return xdmp:node-delete($concept)*/

  // Delete timeseries tags
  /*for $ts in fn:collection("timeseries")/concepts/concept[taxonomy_id eq $taxonomy-id]
    return xdmp:node-delete($ts) (: delete timeseries tags :)*/

  xdmp.commit();
}

// In normal situation, in order to perform an update 
// to a document, you must declare the transaction as 
// an update; if declareUpdate is not called at the 
// beginning of a statement, the statement is run as 
// a query. You can do this using declareUpdate();
//
// But in a JavaScript extension, you cannot control the 
// transaction mode in which your get, put, post, or 
// delete function runs. Transaction mode is controlled 
// by the REST API App Server.
//
// GET - query for a single statement transaction, 
//       update for a multi-statement transaction; 
//       that is, if your request includes a transaction 
//       id, the function runs in update mode.
// PUT - update
// POST - query for a single statement transaction, 
//        update for a multi-statement transaction; 
//        that is, if your request includes a transaction 
//        id, the function runs in update mode.
// DELETE - update
//
// If you need to execute code in a transaction context 
// different from the default, use one of the following options:
// Execute the transaction mode sensitive code in a different 
// transaction, using xdmp.invokeFunction, xdmp.eval, or xdmp.invoke. 
function TaxonomyOperations(map) {
  var uris = null;

  return {
    getResult: function getResult() { return uris; },
    createTaxonomy: function wrapperCreate() { uris = doCreateTaxonomy(map); },
    deleteTaxonomy: function wrapperDelete() { doDeleteTaxonomy(map); }
  };
}

// Retrieves a list of all the taxonomies in the database.
// @return A JSON object containing an array of taxonomies and various statistics
function listTaxonomies(user) {
  var params = {};
  var options = fn.concat("base=", PREFIX_IRI, "/predicates");
  var store = cts.collectionQuery("taxonomy");
  var sparqlQuery = fn.concat(
    'PREFIX epi: <', NS_EPI, '> ',
    'PREFIX skos: <', NS_SKOS, '> ',
    'SELECT ?id ?name ?description ?type ?created ?author ?modified ',
    'WHERE ',
    '{ ',
    '?id skos:prefLabel ?name . ',
    '?id skos:scopeNote ?description . ',
    '?id epi:type ?type . ',
    '?id epi:created ?created . ',
    '?id epi:author ?author . ',
    '?id epi:modified ?modified ',
    '} ',
    'ORDER BY ASC(?name)'
  );

  // Executes a SPARQL query against the database.
  var taxonomies = sem.sparql(sparqlQuery, params, options, store);

  return { success: true, message: 'OK', taxonomies: taxonomies };
}

// Gets a taxonomy using id.
// @param id - The taxonomy id
// @return taxonomy as Node
function getTaxonomyById(id) {
  var params = { "current_id" : sem.iri(id) };
  var options = fn.concat("base=", PREFIX_IRI, "/predicates");
  var store = cts.collectionQuery("taxonomy");

  var sparqlQuery = fn.concat(
    'PREFIX epi: <', NS_EPI, '> ',
    'PREFIX skos: <', NS_SKOS, '> ',
    'SELECT ?id ?name ?description ?type ?created ?author ?modified ',
    'WHERE ',
    '{ ',
    '?id skos:prefLabel ?name . ',
    '?id skos:scopeNote ?description . ',
    '?id epi:type ?type . ',
    '?id epi:created ?created . ',
    '?id epi:author ?author . ',
    '?id epi:modified ?modified ',
    'FILTER (?id = ?current_id) ',
    '}'
  );

  // Executes a SPARQL query against the database.
  var taxonomy = sem.sparql(sparqlQuery, params, options, store);

  return taxonomy;
}

// Gets a taxonomy using name.
// @param name - The taxonomy name
// @return taxonomy as Node
function getTaxonomyByName(name) {
  var params = { "current_name" : name};
  var options = fn.concat("base=", PREFIX_IRI, "/predicates");
  var store = cts.collectionQuery("taxonomy");

  var sparqlQuery = fn.concat(
    'PREFIX epi: <', NS_EPI, '> ',
    'PREFIX skos: <', NS_SKOS, '> ',
    'SELECT ?id ?name ?description ?created ?author ?modified ',
    'WHERE ',
    '{ ',
    '?id skos:prefLabel ?name . ',
    '?id skos:scopeNote ?description . ',
    '?id epi:created ?created . ',
    '?id epi:author ?author . ',
    '?id epi:modified ?modified ',
    'FILTER (?name = ?current_name) ',
    '}'
  );

  // Executes a SPARQL query against the database.
  var taxonomy = sem.sparql(sparqlQuery, params, options, store);

  return taxonomy;
}

// Gets a taxonomy using type.
// @param type - The taxonomy type
// @return taxonomy as Node
function getTaxonomyByType(type) {
  var params = { "current_type" : type};
  var options = fn.concat("base=", PREFIX_IRI, "/predicates");
  var store = cts.collectionQuery("taxonomy");

  var sparqlQuery = fn.concat(
    'PREFIX epi: <', NS_EPI, '> ',
    'PREFIX skos: <', NS_SKOS, '> ',
    'SELECT ?id ?name ?description ?created ?author ?modified ?type ',
    'WHERE ',
    '{ ',
    '?id skos:prefLabel ?name . ',
    '?id skos:scopeNote ?description . ',
    '?id epi:created ?created . ',
    '?id epi:author ?author . ',
    '?id epi:modified ?modified ',
    '?id epi:type ?type ',
    'FILTER (?type = ?current_type) ',
    '}'
  );

  // Executes a SPARQL query against the database.
  var taxonomy = sem.sparql(sparqlQuery, params, options, store);

  return taxonomy;
}

// Creates a new taxonomy.
// @param name - The name of the created taxonomy
// @param description - The description of the created taxonomy
// @return the created taxonomy
function createTaxonomy(context, params, input) {
  var user = xdmp.getRequestField('user');
  var name = xdmp.getRequestField('taxonomy.name');
  var description = xdmp.getRequestField('taxonomy.description');

  var result = {
    user: user,
    name: name,
    description: description,
    params: JSON.stringify(params),
    input: JSON.stringify(input),
    context: context
  };

  // The return value is ValueIterator - it's not null.
  var taxonomy = getTaxonomyByName(name);

  if (taxonomy.count === 0) {
    var map = {
      "id": generateTaxonomyId(),
      "name": name,
      "description": description,
      "author": user,
      "active": fn.true(),
      "licensed": fn.true(),
      "namespace": fn.concat(PREFIX_IRI, "/concept/")
    };

    var operations = TaxonomyOperations(map);

    // Execute the update operation in a separate transaction.
    xdmp.invokeFunction(operations.createTaxonomy, { transactionMode: "update-auto-commit" });

    result.taxonomy = operations.getResult();
    result.message = 'A taxonomy has been created';
  } else {
    result.message = 'A taxonomy with this name already exists';
    result.taxonomy = taxonomy;
  }

  return { result: result };
}

// Deletes the given taxonomy and all of the concepts related to it.
// @param id - The taxonomy id
// @return Empty result
function deleteTaxonomy(context, params, input) {
  var id = xdmp.getRequestField('id');
  var result = {};
  var map = {
    "id": id
  };

  var operations = TaxonomyOperations(map);

  // Execute the delete operation in a separate transaction.
  xdmp.invokeFunction(operations.deleteTaxonomy, { transactionMode: "update" });

  result.success = true;
  result.message = 'The taxonomy has been deleted';

  return result;
}

// Imports the given rdf/xml or ttl file as a taxonomy.
// @param taxonomy_file - The uploaded file
// @param progressId - An identifier to use for the progress check service
// @return Empty result. Follow the operation progress by using the progress check service.
function loadTaxonomy(context, params, input) {
  var full_filename = xdmp.getRequestFieldFilename('taxonomy_file');
  var filename = functx.substringBeforeLast(full_filename, '.');
  var extension = functx.substringAfterLast(full_filename, '.');

  if (extension !== 'xml' && extension !== 'rdf' && extension !== 'ttl') {
    var result = {
      success: false,
      message: fn.contact('The taxonomy file is not supported - ', full_filename)
    };

    return { result: result };
  } else {
    var user        = xdmp.getRequestField('user');
    var taxonomyId  = xdmp.getRequestField('taxonomyId');
    var progressId  = xdmp.getRequestField('progressId');
    var content     = xdmp.getRequestField('taxonomy_file');
    var contentType = xdmp.getRequestFieldContentType('taxonomy_file');

    if (!fn.exists(taxonomyId)) {
      taxonomyId = generateTaxonomyId();
    }

    /*var comment = typeof user + ' ' + typeof content;
    if (content instanceof Node)
      comment += ' Node';
    if (content instanceof Document)
      comment += ' Document';*/

    var triples = null;
    var baseURI = fn.concat("base=", PREFIX_IRI);
    if (extension === 'xml' || extension === 'rdf') {
      triples = sem.rdfParse(xdmp.unquote(content).next().value.root, [baseURI, 'rdfxml']);
    } else {
      triples = sem.rdfParse(content, [baseURI, 'turtle']);
    }

    var map = {};

    map["user"] = user;
    map["taxonomyId"] = taxonomyId;
    map["progressId"] = progressId;
    map["filename"] = filename;
    map["extension"] = extension;
    map["content"] = content;

    // Once a module is spawned, its evaluation is completely 
    // asynchronous of the statement in which xdmp.spawn was called. 
    // Explicitly set the transaction mode for this context.
    // For simple updates to be implicitly committed, specify 
    // a transaction mode of "update-auto-commit". A transaction 
    // mode of "update" creates a new multi-statement update 
    // transaction and requires an explicit commit in the code.
    //
    // Note: xdmp.spawn returns a ValueIterator, 
    // use next().value to get the returned value x.next().value

    /*var x = xdmp.spawn("/app/loader.sjs", map, {
      result: true,
      transactionMode: 'update'
    });*/

    var message = doLoadTaxonomy(user, progressId, taxonomyId, filename, extension, content);

    var result = {
      success: true,
      message: message,
      taxonomyId: taxonomyId
    };

    return { result: result };
  }
}

var SELECT_PREDICATES_LIGHT = [
  sem.iri(PREDICATE_PREFLABEL), 
  sem.iri(PREDICATE_SAMEAS), 
  sem.iri(PREDICATE_CHILDREN), 
  sem.iri(PREDICATE_NUMBER_TAGGED_DOCUMENTS), 
  sem.iri(PREDICATE_NUMBER_DESCENDANTS_TAGGED_DOCUMENTS)
];

// Returns the localname from an IRI
function getLocalname(uri)
{
  if (fn.contains(uri, "#")) 
    return functx.substringAfterLast(uri, "#");
  else 
    return functx.substringAfterLast(uri, "/");
}

function filterByGraph(quads, graph) {
  var arry = [];

  for (var q of quads) {
    // Cannot use === for comparison
    if (graph == sem.tripleGraph(q))
      arry.push(q);
  }

  return arry;
}

function getTriples(s, p, o, graph) {
  // cts.triples returns a ValueIterator
  return filterByGraph(cts.triples(s, p, o, "=", "quads"), graph);
}

// Gets a concept with the given predicate list, without using a sparql query.
function getNosparql(id, predicates, taxonomyId) {
  var quads = cts.triples(sem.iri(id), predicates, null, "=", "quads");
  var concept = {};

  concept['id'] = id;

  for (var trpl of quads) {
    // Cannot use === for comparison
    if (sem.tripleGraph(trpl) == taxonomyId) {
      var elname = getLocalname(sem.triplePredicate(trpl));
      var name = null;

      if (elname === "collection-match") 
        name = "collection_match";
      else if (elname === "prefLabel") 
        name = "name";
      else if (elname === "scopeNote") 
        name = "description";
      else if (elname === "broader" || elname === "subClassOf") 
        name = "parent";
      else
        name = elname;

      concept[name] = sem.tripleObject(trpl);
    }
  }

  concept['has-children'] = concept['children'];
  concept['documents_number'] = 0;
  concept['documents_number_all'] = 0;
  concept['isExternal'] = false;

  return concept;
}

function getChildrenNosparql(id, predicates, taxonomyId) {
  var ppredicates = [];
  PARENT_PREDICATES_GROUP.forEach(function(p) {
    ppredicates.push(sem.iri(p));
  });

  // s, p, and o can be null.
  var triples = cts.triples(null, ppredicates, sem.iri(id), "=", "quads");
  var childrenIds = [];

  for (var t of triples) {
    if (sem.tripleGraph(t) == taxonomyId)
      childrenIds.push(sem.tripleSubject(t));
  }

  // Retrieve root Class nodes if needed
  if (id == taxonomyId) {
    getTriples(null, sem.iri(PREDICATE_SUBCLASS_OF), sem.iri(OBJECT_CLASS_THING), taxonomyId).forEach(function(t) {
      childrenIds.push(sem.tripleSubject(t));
    });
  }

  var concepts = [];
  childrenIds.forEach(function(childId) {
    var concept = getNosparql(childId, predicates, taxonomyId);
    concepts.push(concept);
  });

  return concepts;
}

// Retrieves the root concepts of a given taxonomy.
//
// @param taxonomyId - The taxonomy to retrieve top level nodes for
// @return An array of top level concept nodes
function listRootNodes(context, params, input) {
  var taxonomyId = xdmp.getRequestField('taxonomyId');
  var result = {
    success: true,
    message: "root concepts",
    taxonomyId: taxonomyId
  };

/*
  result.concepts.push({
    "id": "http://purl.bioontology.org/ontology/MEDDRA/10005329",
    "name": "Blood and lymphatic system disorders",
    "documents_number": 7,
    "documents_number_all": 0,
    "has-children": "true",
    "isExternal": false
  });

  result.concepts.push({
    "id": "http://purl.bioontology.org/ontology/MEDDRA/10007541",
    "name": "Cardiac disorders",
    "documents_number": 0,
    "documents_number_all": 0,
    "has-children": "true",
    "isExternal": false
  });

  result.concepts.push({
    "id": "http://purl.bioontology.org/ontology/MEDDRA/10010331",
    "name": "Congenital, familial and genetic disorders",
    "documents_number": 0,
    "documents_number_all": 0,
    "has-children": "true",
    "isExternal": false
  });
*/
  var concepts = getChildrenNosparql(taxonomyId, SELECT_PREDICATES_LIGHT, taxonomyId);

  result.concepts = concepts;

  return result;
}

// Retrieves the children of the given parent node, which 
// resides in the specified taxonomy.
// 
// @param conceptId
// @param taxonomyId
// @return An array of concept nodes
function listChildNodes(context, params, input) {
  var conceptId = xdmp.getRequestField('conceptId');
  var taxonomyId = xdmp.getRequestField('taxonomyId');
  var result = {
    success: true,
    message: "child concepts",
    conceptId: conceptId,
    taxonomyId: taxonomyId
  };

  var concepts = getChildrenNosparql(conceptId, SELECT_PREDICATES_LIGHT, taxonomyId);

  result.concepts = concepts;

  return result;
}

// Returns the active rule of a concept. The result depends 
// on whether the concept has an automatic or a manual rule. 
// Manual rules are set by the users, automatic ones are 
// constructed from the concept prefLabel and the synonyms 
// defined in the thesaurus.
//
// @param conceptId - the concept iri 
// @param taxonomyId - the taxonomy to use
// @returns the currently active search rule for the given concept
function getActiveRule(conceptId, taxonomyId) {
  var rule = sem.tripleObject(getTriples(sem.iri(conceptId), sem.iri(PREDICATE_RULE), null, taxonomyId)[0]);
  var name = sem.tripleObject(getTriples(sem.iri(conceptId), sem.iri(PREDICATE_PREFLABEL), null, taxonomyId)[0]);
  var isManualRule = fn.not(rule == fn.concat('"', name, '"'));
    
  // Checks if this is an automatic or a manual rule. 
  // Automatic rules are constructed from the thesaurus.
  var activeRule = null;
  if (isManualRule) {
    activeRule = rule;
  } else {
    var terms = [];

    terms.push(fn.concat('"', name, '"'));

    var uri = fn.concat("/thesaurus/", taxonomyId, ".xml");
    for (var entry of thsr.lookup(uri, name)) {
      var termNodes = entry.xpath("synonym/term");
      for (var termNode of termNodes) {
        var term = fn.concat('"', termNode.firstChild.nodeValue, '"');
        terms.push(term);
      }
    }
    activeRule = fn.stringJoin(terms, " OR ");
  }
    
  return {
    "is-manual-rule": isManualRule, 
    "query": activeRule
  };
}

// Retrieves a concept by its identifier.
//
// @param conceptId - The id of the concept to retrieve
// @param taxonomyId - The taxonomy which the concept resides in
// @return A JSON representation of the concept found
function getConcept(context, params, input) {
  var conceptId = xdmp.getRequestField('conceptId');
  var taxonomyId = xdmp.getRequestField('taxonomyId');
  var result = {
    success: true,
    message: "concept",
    conceptId: conceptId,
    taxonomyId: taxonomyId
  };

  var concept = getNosparql(conceptId, SELECT_PREDICATES, taxonomyId);
  var rule = getActiveRule(conceptId, taxonomyId);
  concept.rule = rule["query"];
  concept.is_manual_rule = rule["is-manual-rule"];

  result.concept = concept;

  return result;
}

// Retrieves a list of synonyms for the given name.
//
// @param name - the name of concept altLabel or prefLabel
// @param taxonomyId - taxonomy of the thesaurus to be used
// @return A list of synonyms
function listSynonyms(name, taxonomyId) {
  var termToQuery = name;
  var lookupObject = rdf.langString(name, "en");
  var altLabelTriples = getTriples(null, sem.iri(PREDICATE_ALTLABEL), lookupObject, taxonomyId);

  // sem.triple(
  //   sem.iri("http://www.marklogic.com/DMLC/heart"), 
  //   sem.iri("http://www.w3.org/2004/02/skos/core#altLabel"), 
  //   rdf.langString("abc", "en"), 
  //   sem.iri("http://healthcare.demo.marklogic.com/taxonomy/dmlc")
  // )
  //altLabelTriples.forEach(function(t) {
  //  xdmp.log(t);
  //});

  if (altLabelTriples.length > 0) {
    var concept = sem.tripleSubject(altLabelTriples[0]);
    var prefLabelTriples = getTriples(concept, sem.iri(PREDICATE_PREFLABEL), null, taxonomyId);

    if (prefLabelTriples.length > 0) {
      termToQuery = sem.tripleObject(prefLabelTriples[0]);
    }
  }

  //return thsr.lookup(fn.concat("/thesaurus/", taxonomyId, ".xml"), termToQuery);

  return thsr.queryLookup(
    fn.concat("/thesaurus/", taxonomyId, ".xml"), 
    cts.wordQuery(termToQuery, "case-insensitive"));
}

function getSynonyms(context, params, input) {
  var term = xdmp.getRequestField('term');
  var taxonomyId = xdmp.getRequestField('taxonomyId');
  var result = {};

  if (fn.exists(term) && fn.exists(taxonomyId)) {
    var synonyms = [];
    var entries = listSynonyms(term, taxonomyId);

    for (var entry of entries) {
      var synonymNodes = entry.xpath("synonym");
      for (var synonymNode of synonymNodes) {
        var synonymTerm = synonymNode.xpath("term").toArray()[0].firstChild.nodeValue;
        synonyms.push({ "synonym": escapeTerm(synonymTerm) });
      }
    }

    result.success = true;
    result.message = "synonyms returned";
    result.synonyms = synonyms;
  } else {
    result.success = false;
    result.message = "Some mandatory parameters are missing";
    result.synonyms = [];
  }

  return result;
}

function getEntryTerm(entry) {
  // Node.xpath returns ValueIterator
  var termNodes = entry.xpath("term");

  // for...of loop is the recommended way of iterating 
  // through a ValueIterator.
  for (node of termNodes) {
    // Returns the first element immediately.
    return node.firstChild.nodeValue;
  }

  return null;
}

// Gets all synonyms that matches the given name. The concept 
// is not included.
function listSuggestsWithoutConcept(name, taxonomyId) {
  var suggests = [];
  var doc = fn.doc(fn.concat("/thesaurus/", taxonomyId, ".xml"));
  var patt = new RegExp(name, "i");

  for (var x of doc) {
    var termNodes = x.root.xpath("entry/synonym/term");
    for (node of termNodes) {
      var value = node.firstChild.nodeValue;
      if (patt.test(value)) {
        suggests.push({
          "concept": getEntryTerm(node.parentNode.parentNode),
          "suggest": escapeTerm(value)
        });
      }
    }
  }

  return suggests;
}

// Gets all synonyms (including concepts) that matches the given name.
function listSuggests(name, taxonomyId) {
  var suggests = [];
  var doc = fn.doc(fn.concat("/thesaurus/", taxonomyId, ".xml"));
  var patt = new RegExp(name, "i");

  for (var x of doc) {
    var conceptNodes = x.root.xpath("entry/term");
    for (conceptNode of conceptNodes) {
      var concept = conceptNode.firstChild.nodeValue;

      if (patt.test(concept)) {
        suggests.push({
          "concept": concept,
          "suggest": escapeTerm(concept)
        });
      }

      var termNodes = conceptNode.parentNode.xpath("synonym/term");
      for (termNode of termNodes) {
        var value = termNode.firstChild.nodeValue;
        if (patt.test(value)) {
          suggests.push({
            "concept": concept,
            "suggest": escapeTerm(value)
          });
        }
      }
    }
  }

  return suggests;
}

function getSuggests(context, params, input) {
  var term = xdmp.getRequestField('term');
  var taxonomyId = xdmp.getRequestField('taxonomyId');
  var result = {};

  if (fn.exists(term) && fn.exists(taxonomyId)) {
    result.success = true;
    result.message = "suggests returned";
    result.suggests = listSuggests(term, taxonomyId);
  } else {
    result.success = false;
    result.message = "Some mandatory parameters are missing";
    result.suggests = [];
  }

  return result;
}

// Retruns only the concept's prefLabel associated with 
// an altLabel for the term.
function narrator(context, params, input) {
  var term = xdmp.getRequestField('term');
  var taxonomyId = xdmp.getRequestField('taxonomyId');
  var result = {};

  if (fn.exists(term) && fn.exists(taxonomyId)) {
    var pterm = parseSearchTerm(term);
    var synonyms = [];
    var lookupObject = rdf.langString(pterm, "en");
    var altLabelTriples = getTriples(null, sem.iri(PREDICATE_ALTLABEL), lookupObject, taxonomyId);

    if (altLabelTriples.length > 0) {
      var concept = sem.tripleSubject(altLabelTriples[0]);
      var prefLabelTriples = getTriples(concept, sem.iri(PREDICATE_PREFLABEL), null, taxonomyId);

      if (prefLabelTriples.length > 0) {
        var conceptName = sem.tripleObject(prefLabelTriples[0]);
        synonyms.push({ "synonym": escapeTerm(conceptName) });
      }
    }

    synonyms.push({ "synonym": term });

    result.success = true;
    result.message = "synonyms returned";
    result.synonyms = synonyms;
  } else {
    result.success = false;
    result.message = "Some mandatory parameters are missing";
    result.synonyms = [];
  }

  return result;
}

// POST
//
function post(context, params, input) {
  context.outputTypes = ['application/json'];

  var action = xdmp.getRequestField('action');

  if (fn.exists(action)) {
    if (action === 'list') {
      return listTaxonomies(context, params, input);
    } else if (action === 'create') {
      return createTaxonomy(context, params, input);
    } else if (action === 'delete') {
      return deleteTaxonomy(context, params, input);
    } else if (action === 'load') {
      return loadTaxonomy(context, params, input);
    } else if (action === "createSynonyms") {
      var taxonomyId = xdmp.getRequestField('taxonomyId');
      var progressId = xdmp.getRequestField('progressId');
      return createSynonyms(taxonomyId, progressId);
    } else if (action === 'progress') {
      return checkProgress(context, params, input);
    } else if (action === 'listRootNodes') {
      return listRootNodes(context, params, input);
    } else if (action === 'listChildNodes') {
      return listChildNodes(context, params, input);
    } else if (action === 'getConcept') {
      return getConcept(context, params, input);
    } else if (action === 'getSuggests') {
      return getSuggests(context, params, input);
    } else if (action === 'getSynonyms') {
      return getSynonyms(context, params, input);
    } else if (action === 'narrator') {
      return narrator(context, params, input);
    } else {
      returnErrToClient(400, 'Bad Request', 'Invalid action code');
      // unreachable - control does not return from fn.error
    }
  } else {
    returnErrToClient(400, 'Bad Request', 'Required parameter action is missing');
    // unreachable - control does not return from fn.error
  }
}

// DELETE
//
function deleteFunction(context, params) {
  xdmp.log('DELETE invoked');
  return null;
}

// GET
//
// This function returns a document node corresponding to each
// user-defined parameter in order to demonstrate the following
// aspects of implementing REST extensions:
// - Returning multiple documents
// - Overriding the default response code
// - Setting additional response headers
//
function get(context, params) {
  var results = [];
  context.outputTypes = [];
  for (var pname in params) {
    if (params.hasOwnProperty(pname)) {
      results.push({name: pname, value: params[pname]});
      context.outputTypes.push('application/json');
    }
  }

  // Return a successful response status other than the default
  // using an array of the form [statusCode, statusMessage].
  // Do NOT use this to return an error response.
  context.outputStatus = [201, 'Yay'];

  // Set additional response headers using an object
  context.outputHeaders = 
    {'X-My-Header1' : 42, 'X-My-Header2': 'h2val' };

  // Return a ValueIterator to return multiple documents
  return xdmp.arrayValues(results);
}

// PUT
//
// The client should pass in one or more documents, and for each
// document supplied, a value for the 'basename' request parameter.
// The function inserts the input documents into the database only 
// if the input type is JSON or XML. Input JSON documents have a
// property added to them prior to insertion.
//
// Take note of the following aspects of this function:
// - The 'input' param might be a document node or a ValueIterator
//   over document nodes. You can normalize the values so your
//   code can always assume a ValueIterator.
// - The value of a caller-supplied parameter (basename, in this case)
//   might be a single value or an array.
// - context.inputTypes is always an array
// - How to return an error report to the client
//
function put(context, params, input) {
  // normalize the inputs so we don't care whether we have 1 or many
  var docs = normalizeInput(input);
  var basenames = params.basename instanceof Array 
                  ? params.basename: [ params.basename ];

  // Validate inputs.
  if (docs.count > basenames.length) {
    returnErrToClient(400, 'Bad Request',
       'Insufficient number of uri basenames. Expected ' +
       docs.count + ' got ' + basenames.length + '.');
    // unreachable - control does not return from fn.error
  }

  // Do something with the input documents
  var i = 0;
  var uris = [];
  for (var doc of docs) {
    uris.push( doSomething(
        doc, context.inputTypes[i], basenames[i++]
    ));
  }

  // Set the response body MIME type and return the response data.
  context.outputTypes = ['application/json'];
  return { written: uris };
}

// PUT helper func that demonstrates working with input documents.
//
// It inserts a (nonsense) property into the incoming document if
// it is a JSON document and simply inserts the document unchanged
// if it is an XML document. Other doc types are skipped.
//
// Input documents are imutable, so you must call toObject()
// to create a mutable copy if you want to make a change.
//
// The property added to the JSON input is set to the current time
// just so that you can easily observe it changing on each invocation.
//
function doSomething(doc, docType, basename) {
  var uri = '/extensions/' + basename;
  if (docType == 'application/json') {
    // create a mutable version of the doc so we can modify it
    var mutableDoc = doc.toObject();
    uri += '.json';

    // add a JSON property to the input content
    mutableDoc.written = fn.currentTime();
    xdmp.documentInsert(uri, mutableDoc);
    return uri;
  } else if (docType == 'application/xml') {
    // pass thru an XML doc unchanged
    uri += '.xml';
    xdmp.documentInsert(uri, doc);
    return uri;
  } else {
    return '(skipped)';
  }
}

// Helper function that demonstrates how to normalize inputs
// that may or may not be multi-valued, such as the 'input'
// param to your methods.
//
// In cases where you might receive either a single value
// or a ValueIterator, depending on the request context,
// you can normalize the data type by creating a ValueIterator
// from the single value.
function normalizeInput(item) {
  return (item instanceof ValueIterator)
         ? item                        // many
         : xdmp.arrayValues([item]);   // one
}

// Helper function that demonstrates how to return an error response
// to the client.

// You MUST use fn.error in exactly this way to return an error to the
// client. Raising exceptions or calling fn.error in another manner
// returns a 500 (Internal Server Error) response to the client.
function returnErrToClient(statusCode, statusMsg, body) {
  fn.error(null, 'RESTAPI-SRVEXERR', 
           xdmp.arrayValues([statusCode, statusMsg, body]));
  // unreachable - control does not return from fn.error.
}


///////////////////////////////////////////////////////////////

// Returns the namespace part from a full IRI
function getNamespace(uri) {
  if (fn.contains(uri, "#")) 
    return fn.concat(functx.substringBeforeLast(uri, "#"), "#");
  else
    return fn.concat(functx.substringBeforeLast(uri, "/"), "/");
}

function doSaveProgress(map) {
  var uri = fn.concat("/progress/", map["id"], ".json");
  xdmp.documentInsert(uri, {
    "id": map["id"],
    "value": map["value"],
    "description": map["description"],
    "time": fn.currentDateTime()
  });

  xdmp.commit();
}

// Deletes a taxonomy and all associated concepts.
// @param map - The taxonomy id in map
// @return empty result
function doDeleteMyTaxonomy(map) {
  var id = map["id"];

  // Delete related documents
  xdmp.collectionDelete(id);

  var uri = fn.concat("/thesaurus/", id, ".xml");

  // Delete thesaurus document
  if (fn.exists(fn.doc(uri))) {
    xdmp.documentDelete(uri);
  }

  // Delete document tags
  /*for $concept in fn:collection("document-content")/document/concepts/concept[taxonomy_id eq $taxonomy-id] 
    return xdmp:node-delete($concept)*/

  // Delete timeseries tags
  /*for $ts in fn:collection("timeseries")/concepts/concept[taxonomy_id eq $taxonomy-id]
    return xdmp:node-delete($ts) (: delete timeseries tags :)*/

  xdmp.commit();
}


// Saves a taxonomy to the triplestore.
function doSaveTaxonomy(map) {
  var taxonomy_subject = map["id"];
  var triples = [];

  triples.push(sem.triple(
    sem.iri(taxonomy_subject),
    sem.iri(PREDICATE_PREFLABEL),
    map["name"]
  ));

  triples.push(sem.triple(
    sem.iri(taxonomy_subject),
    sem.iri(PREDICATE_SCOPENOTE),
    map["description"]
  ));

  triples.push(sem.triple(
    sem.iri(taxonomy_subject),
    sem.iri(PREDICATE_TYPE),
    "none"
  ));

  var created = map["created"];
  if (!created) {
    created = fn.currentDateTime();
  }
  triples.push(sem.triple(
    sem.iri(taxonomy_subject),
    sem.iri(PREDICATE_CREATED),
    created
  ));

  triples.push(sem.triple(
    sem.iri(taxonomy_subject),
    sem.iri(PREDICATE_AUTHOR),
    map["author"]
  ));

  triples.push(sem.triple(
    sem.iri(taxonomy_subject),
    sem.iri(PREDICATE_MODIFIED),
    fn.currentDateTime()
  ));

  var namespace = map["namespace"];
  if (namespace) {
    triples.push(sem.triple(
      sem.iri(taxonomy_subject),
      sem.iri(PREDICATE_TAXONOMY_NAMESPACE),
      namespace
    ));
  }

  var uris = sem.rdfInsert(triples, [], [], ["taxonomy", map["id"]]);

  xdmp.commit();

  // Returns taxonomy triple subject as string
  return uris;
}

// Saves triples to the triplestore.
function doSaveTriples(map) {
  var taxonomyId = map["id"];
  var triples = map["triples"];

  sem.rdfInsert(triples, ["override-graph="], [], ["concept", taxonomyId]);

  xdmp.commit();
}

// Inserts a reverse query for the given concept/taxonomy. 
// The input query string (rule) will be parsed, transformed 
// and enriched with constraints before inserting.
// @param conceptId
// @param taxonomyId
// @param rule
function insertReverseQuery(conceptId, taxonomyId, rule) {
}

// Saves concepts to the triplestore.
function doSaveConcepts(map) {
  var taxonomyId = map["id"];
  var concepts = map["concepts"];
  var namespaceDistribution = map["namespaceDistribution"];
  var numberConcepts = map["numberConcepts"];
  var triples = [];
  var subjectNamespace = null;
  var i = 0;

  concepts.forEach(function(concept) {
    subjectNamespace = getNamespace(concept);

    var count = namespaceDistribution[subjectNamespace];
    if (count) {
      namespaceDistribution[subjectNamespace] = count + 1;
    } else {
      namespaceDistribution[subjectNamespace] = 1;
    }

    count = getTriples(concept, sem.iri(PREDICATE_RDFTYPE), sem.iri(OBJECT_TYPE_CLASS), taxonomyId).length;

    var isClass = (count > 0) ? true : false;
    var siri = (isClass) ? sem.iri(PREDICATE_SUBCLASS_OF) : sem.iri(PREDICATE_BROADER);

    count = getTriples(concept, siri, null, taxonomyId).length;

    var isMissingParent = (count === 0) ? true : false;

    count = getTriples(concept, sem.iri(PREDICATE_RULE), null, taxonomyId).length;
    var isRuleAvailable = (count > 0) ? true : false;

    /*var prefLabel = [];
    getTriples(concept, sem.iri(PREDICATE_PREFLABEL), null, taxonomyId).forEach(function(t) {
      prefLabel.push(sem.tripleObject(t));
    });*/
    // TO DO
    var prefLabel = sem.tripleObject(getTriples(concept, sem.iri(PREDICATE_PREFLABEL), null, taxonomyId)[0]);

    var labelTriples = getTriples(concept, 
      [sem.iri(PREDICATE_PREFLABEL), sem.iri(PREDICATE_ALTLABEL), sem.iri(PREDICATE_HIDDENLABEL)], 
      null, taxonomyId);

    var rule = null;
    if (isRuleAvailable) {
      rule = [];
      getTriples(concept, sem.iri(PREDICATE_RULE), null, taxonomyId).forEach(function(t) {
        rule.push(sem.tripleObject(t));
      });
    } else {
      var labels = [];
      labelTriples.forEach(function(label) {
        labels.push(fn.concat('"', fn.normalizeSpace(sem.tripleObject(label)), '"'));
      });
      rule = fn.stringJoin(labels, " OR ");
    }

    count = getTriples(concept, sem.iri(PREDICATE_SCOPENOTE), null, taxonomyId).length;
    var hasScopeNote = (count > 0) ? true : false;

    // Try to find adopters (hasSTY for now) if this is an orphan node.
    var adopters = [];
    if (isMissingParent) {
      var predicates = [];
      ADOPTER_PREDICATES_GROUP.forEach(function(a) {
        predicates.push(sem.iri(a));
      });
      getTriples(concept, predicates, null, taxonomyId).forEach(function(a) {
        adopters.push(sem.tripleObject(a));
      });
    }

    var predicates = [];
    PARENT_PREDICATES_GROUP.forEach(function(p) {
      predicates.push(sem.iri(p));
    });
    var count1 = getTriples(null, predicates, concept, taxonomyId).length;

    predicates = [];
    ADOPTER_PREDICATES_GROUP.forEach(function(p) {
      predicates.push(sem.iri(p));
    });
    var count2 = getTriples(null, predicates, concept, taxonomyId).length;

    var hasChildren = false;
    if (count1 > 0 || (isMissingParent && count2 > 0)) {
      hasChildren = true;
    }

    // Add taxonomy triple to concepts
    triples.push(sem.triple(
      concept,
      sem.iri(PREDICATE_TAXONOMY),
      sem.iri(taxonomyId)
    ));

    // Add a subClassOf/broader triple for top-level nodes
    if (isMissingParent) {
      // If no adopters are found, make it a top level node
      if (adopters.length === 0) {
        if (isClass) {
          triples.push(sem.triple(
            concept, 
            sem.iri(PREDICATE_SUBCLASS_OF), 
            sem.iri(OBJECT_CLASS_THING)
          ));
          triples.push(sem.triple(
            concept, 
            sem.iri(PREDICATE_HIDDEN), 
            fn.true()
          ));
        } else {
          triples.push(sem.triple(
            concept, 
            sem.iri(PREDICATE_BROADER), 
            sem.iri(taxonomyId)
          ));
        }
      } else {
        triples.push(sem.triple(
          concept, 
          sem.iri(isClass ? PREDICATE_SUBCLASS_OF : PREDICATE_BROADER),
          sem.iri(adopters[1])
        ));
        triples.push(sem.triple(
          concept, 
          sem.iri(PREDICATE_ADOPTED), 
          fn.true()
        ));
      }
    }

    // Add a rule if none exists
    if (!isRuleAvailable) {
      triples.push(sem.triple(
        concept, 
        sem.iri(PREDICATE_RULE), 
        fn.concat('"', prefLabel, '"')
      ));
    }

    // children
    triples.push(sem.triple(concept, sem.iri(PREDICATE_CHILDREN), hasChildren));

    // Add a scopeNote if none exists
    if (!hasScopeNote) {
      triples.push(sem.triple(concept, sem.iri(PREDICATE_SCOPENOTE), ""));
    }

    // Insert a reverse query
    insertReverseQuery(concept, taxonomyId, rule);

    // Add a path cache document

    i++;
  });

  sem.rdfInsert(triples, ["override-graph="], [], ["concept", taxonomyId]);

  xdmp.commit();
}

// Saves a namespace to the triplestore.
function doSaveNamespace(map) {
  var taxonomyId = map["id"];
  var namespace = map["namespace"];

  sem.rdfInsert(
    sem.triple(sem.iri(taxonomyId), sem.iri(PREDICATE_TAXONOMY_NAMESPACE), namespace),
    [], [], ["taxonomy", taxonomyId]
  );

  xdmp.commit();
}

// Saves a thesaurus document to the database.
function doSaveThesaurusDoc(map) {
  var uri = map["uri"];
  var doc = map["doc"];

  thsr.insert(uri, doc);

  xdmp.commit();
}

function UpdateOperations(map) {
  return {
    saveProgress: function wrapperSaveProgress() { doSaveProgress(map); },
    deleteMyTaxonomy: function wrapperDeleteTaxonomy() { doDeleteMyTaxonomy(map); },
    saveTaxonomy: function wrapperSaveTaxonomy() { doSaveTaxonomy(map); },
    saveTriples: function wrapperSaveTriples() { doSaveTriples(map); },
    saveConcepts: function wrapperSaveConcepts() { doSaveConcepts(map); },
    saveNamespace: function wrapperSaveNamespace() { doSaveNamespace(map); },
    saveThesaurusDoc: function wrapperSaveThesaurusDoc() { doSaveThesaurusDoc(map); }
  };
}

function saveProgress(id, value, description) {
  var map = {
    "id": id,
    "value": value,
    "description": description
  };

  var operations = UpdateOperations(map);

  // Execute the update operation in a separate transaction.
  xdmp.invokeFunction(operations.saveProgress, { transactionMode: "update" });
}

function deleteMyTaxonomy(taxonomyId) {
  var map = {
    "id": taxonomyId
  };
  var operations = UpdateOperations(map);

  xdmp.invokeFunction(operations.deleteMyTaxonomy, { transactionMode: "update" });
}

function saveTaxonomy(map) {
  var operations = UpdateOperations(map);

  xdmp.invokeFunction(operations.saveTaxonomy, { transactionMode: "update" });
}

function saveTriples(taxonomyId, triples) {
  var map = {
    "id": taxonomyId,
    "triples": triples
  };
  var operations = UpdateOperations(map);

  xdmp.invokeFunction(operations.saveTriples, { transactionMode: "update" });
}

function saveConcepts(taxonomyId, concepts, namespaceDistribution, numberConcepts) {
  var map = {
    "id": taxonomyId,
    "concepts": concepts,
    "namespaceDistribution": namespaceDistribution,
    "numberConcepts": numberConcepts
  };
  var operations = UpdateOperations(map);

  xdmp.invokeFunction(operations.saveConcepts, { transactionMode: "update" });
}

function saveNamespace(taxonomyId, namespace) {
  var map = {
    "id": taxonomyId,
    "namespace": namespace
  };
  var operations = UpdateOperations(map);

  xdmp.invokeFunction(operations.saveNamespace, { transactionMode: "update" });
}

function saveThesaurusDoc(uri, doc) {
  var map = {
    "uri": uri,
    "doc": doc
  };
  var operations = UpdateOperations(map);

  xdmp.invokeFunction(operations.saveThesaurusDoc, { transactionMode: "update" });
}

// Walks over a list of concept subject iris and enrich them. 
function enrichTriples(conceptIris, namespaceDistribution, taxonomyId, progressId) {
  xdmp.log("conceptIris.length: " + conceptIris.length);
  xdmp.log(conceptIris);

  var batchSize = 100;
  var totalItems = conceptIris.length;
  var batchSize = fn.min([totalItems, batchSize]);
  var pages = fn.ceiling(totalItems / batchSize);

  xdmp.log("totalItems: " + totalItems);
  xdmp.log("batchSize: " + batchSize);
  xdmp.log("pages: " + pages);

  saveProgress(progressId, "0", fn.concat("[0", " of ", totalItems, "]"));

  for (var page = 1; page <= pages; page++) {
    var from = (page - 1) * batchSize + 1;
    var to = fn.min([totalItems, (page * batchSize)]);
    var segments = [];
    var i;

    for (i = from; i <= to; i++) {
      segments.push(conceptIris[i-1]);
    }

    saveConcepts(taxonomyId, segments, namespaceDistribution, totalItems);

    // on progress update callback
    var progressValue = (60 + math.ceil(page * 0.2)) + "";
    var progressDesc = fn.concat("Building concept tree <", (i-1), "/", totalItems, ">");
    saveProgress(progressId, progressValue, progressDesc);
    xdmp.log(progressDesc);
  }
}

function processTriples(file, extension, taxonomyId, progressId) {
  var triples = null;
  var baseURI = fn.concat("base=", PREFIX_IRI);

  // rdfParse returns a ValueIterator
  if (extension === "xml" || extension === "rdf") {
    // This is an XML or RDF file, so the parse format is rdfxml.
    triples = sem.rdfParse(xdmp.unquote(file).next().value.root, [baseURI, "rdfxml"]);
  } else {
    // This is turtle file, so the parse format is turtle.
    triples = sem.rdfParse(file, [baseURI, "turtle"]);
  }

  saveProgress(progressId, "30", "Saving triples to database");
  xdmp.log("30%, Saving triples to database");

  // Converts the triples to an array.
  triples = triples.toArray();

  var batchSize = 500;
  var totalItems = triples.length;
  var batchSize = fn.min([totalItems, batchSize]);
  var pages = fn.ceiling(totalItems / batchSize);

  xdmp.log("totalItems: " + totalItems);
  xdmp.log("batchSize: " + batchSize);
  xdmp.log("pages: " + pages);

  saveProgress(progressId, "0", fn.concat("[0", " of ", totalItems, "]"));

  // Breaks triples up into smaller jobs and starts processing them.
  for (var page = 1; page <= pages; page++) {
    var from = (page - 1) * batchSize + 1;
    var to = fn.min([totalItems, (page * batchSize)]);
    var segments = [];
    var i;

    for (i = from; i <= to; i++) {
      segments.push(triples[i-1]);
    }

    saveTriples(taxonomyId, segments);

    // on progress update callback
    var progressValue = (30 + math.ceil(page * 0.3)) + "";
    var progressDesc = fn.concat("Saving triples <", (i-1), "/", totalItems, ">");
    saveProgress(progressId, progressValue, progressDesc);
    xdmp.log(progressValue + " " + progressDesc);
  }

  return triples;
}

function createSynonyms(taxonomyId, progressId) {
  // This is the second step, build the concept tree.
  saveProgress(progressId, "60", "Building concept tree");
  xdmp.log("60%, Building concept tree");

  // Select all subjects with the skos concept rdf data type
  var selectedTriples = cts.triples(
    [], 
    sem.iri(PREDICATE_RDFTYPE), 
    [sem.iri(OBJECT_TYPE_CONCEPT), sem.iri(OBJECT_TYPE_CLASS)], 
    [], [], cts.collectionQuery(taxonomyId));

  var conceptIris = []; // This is a string array.
  for (var triple of selectedTriples) {
    conceptIris.push(sem.tripleSubject(triple));
  }

  // This map will keep counts of the namespaces of the concepts
  // For example : {"http://www.jnj.com/IDMP/": 4}
  var namespaceDistribution = {};

  // Breaks concepts up into smaller jobs and starts processing them.
  enrichTriples(conceptIris, namespaceDistribution, taxonomyId, progressId);

  // Determine the taxonomy namespace
  // Object.keys() returns an array whose elements 
  // are strings corresponding to the enumerable 
  // properties found directly upon object. 
  var namespaces = Object.keys(namespaceDistribution);
  var txNamespace = null;
  var count = 0;

  namespaces.forEach(function(namespace) {
    if (namespaceDistribution[namespace] > count) {
      txNamespace = namespace;
    }
  });

  saveProgress(progressId, "80", "Saving concept tree");
  xdmp.log("80%, saving concept tree");

  // Commented by Jianmin on 2016-06-02
  xdmp.log("txNamespace: " + txNamespace);
  //txNamespace = "http://www.marklogic.com/DMLC/";
  saveNamespace(taxonomyId, txNamespace);

  saveProgress(progressId, "90", "Building thesaurus");
  xdmp.log("90%, building thesaurus");

  // Build a thesaurus
  var thesaurusUri = fn.concat("/thesaurus/", taxonomyId, ".xml");
  var entries = [];

  entries.push('<thesaurus xmlns="http://marklogic.com/xdmp/thesaurus">');
  conceptIris.forEach(function(conceptId) {
    var conceptTriples = getTriples(sem.iri(conceptId), sem.iri(PREDICATE_PREFLABEL), null, taxonomyId);

    if (conceptTriples.length > 0) {
      // term is a string.
      var term = sem.tripleObject(conceptTriples[0]);
      var arry = [];

      getTriples(sem.iri(conceptId), 
        [sem.iri(PREDICATE_ALTLABEL), sem.iri(PREDICATE_HIDDENLABEL)], null, 
        taxonomyId).forEach(function(t) {
        arry.push(sem.tripleObject(t));
      });

      var synonyms = fn.distinctValues(xdmp.arrayValues(arry));
      if (fn.count(synonyms)) {
        entries.push('<entry xmlns="http://marklogic.com/xdmp/thesaurus">');
        entries.push("<term>");
        entries.push(term);
        entries.push("</term>");
        for (var syn of synonyms) {
          entries.push("<synonym>");
          entries.push("<term>");
          entries.push(fn.normalizeSpace(syn));
          entries.push("</term>");
          entries.push("<part-of-speech>noun</part-of-speech>");
          entries.push("</synonym>");
        }
        entries.push("</entry>");
      }
    }
  });
  entries.push("</thesaurus>");

  var thesaurusDoc = xdmp.unquote(entries.join(""));
  saveThesaurusDoc(thesaurusUri, thesaurusDoc.next().value.root);

  saveProgress(progressId, "100", "Finalizing");
  xdmp.log("100%, finalizing");

  var result = {
    success: true,
    message: "total concepts - " + conceptIris.length
  };

  return { result: result };
}

// Takes the contents of a taxonomy file, parses it 
// and inserts the triples in the database. Reverse 
// queries and thesaurus entries are also created in 
// the process.
// @param file - the contents of a taxonomy file
// @param taxonomyId - specifies which taxonomy the triples will be inserted in
// @param $is-new-taxonomy - specifies whether this is a newly created taxonomy, 
//        in which case a new thesaurus will be generated. 
//        otherwise, the input taxonomy will be merged with 
//        the existing taxonomy triples, reverse queries and thesaurus
// @param progressId 
function processFile(file, extension, taxonomyId, progressId) {
  var triples = processTriples(file, extension, taxonomyId, progressId);
  return triples;
}

// user, taxonomyId, progressId, filename, extension, and 
// content are imported by xdmp.spawn.
function doLoadTaxonomy(user, progressId, taxonomyId, filename, extension, content) {
  try {
    saveProgress(progressId, "0", "Extracting namespaces");

    var map = {
      "id": taxonomyId,
      "name": filename + '.' + extension,
      "description": fn.concat("Imported taxonomy: ", filename),
      "author": user,
      "active": fn.true(),
      "licensed": fn.true()
    };

    saveTaxonomy(map);

    // TO DO - record namespaces with their prefixes in the database

    var triples = processFile(content, extension, taxonomyId, progressId);
    xdmp.log(triples);

    return "total triples - " + triples.length;
  } catch (err) {
    xdmp.log(err);
    if (taxonomyId) {
      deleteMyTaxonomy(taxonomyId);
    }
    saveProgress(progressId, "-1", "Internal server error! Please check the server logs.");
    return "An error has occured while loading the taxonomy";
  }
}

///////////////////////////////////////////////////////////////

// Include an export for each method supported by your extension.
exports.GET = get;
exports.POST = post;
exports.PUT = put;
exports.DELETE = deleteFunction;
