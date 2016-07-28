/*
 * @(#)registry.js
 */

/*
 * Author: Jianmin Liu
 * Created: 2016/05/24
 * Description: The registry module
 */
var path = require('path');
var mlproxy = require('./mlproxy.js');

// There is one and only one the taxonomy.
var taxonomyId = 'dmlc'; //http://healthcare.demo.marklogic.com/taxonomy/dmlc';

var utils = {

  startsWith: function(str, prefix) {
    return str.slice(0, prefix.length) == prefix;
  },
 
  endsWith: function(str, suffix) {
    return str.slice(-suffix.length) == suffix;
  }
}

var registry = {
  // Imports the given rdf/xml or ttl file as a taxonomy.
  uploadTaxonomy: function(req, res, rdir) {
    // req.file is the data file
    //console.log(req.file);

    var filename = req.file.originalname;
    var filepath = path.join(rdir, req.file.path);

    if (utils.endsWith(filename, '.xml') || 
        utils.endsWith(filename, '.rdf') ||  
        utils.endsWith(filename, '.ttl')) {
      mlproxy.uploadTaxonomy(taxonomyId, filepath, filename, function(err, result) {
        res.json(result.result);
      });
    } else {
      res.json({
        success: false,
        message: 'file type not supported'
      });
    }
  },

  listTaxonomies: function(req, res) {
    mlproxy.listTaxonomies(function(err, result) {
      if (err) {
        res.json({
          success: false,
          message: err.message
        });
      } else {
        res.json(result);
      }
    });
  },

  // Deletes the given taxonomy and all of the concepts related to it.
  deleteTaxonomy: function(req, res) {
    mlproxy.deleteTaxonomy(taxonomyId, function(err, result) {
      if (err) {
        res.json({
          success: false,
          message: err.message
        });
      } else {
        res.json(result);
      }
    });
  },

  getSuggests: function(req, res) {
    var term = req.query['term'];

    mlproxy.getSuggests(term, taxonomyId, function(err, result) {
      if (err) {
        res.json({
          success: false,
          message: err.message
        });
      } else {
        res.json(result);
      }
    });
  },

  getSynonyms: function(req, res) {
    var term = req.query['term'];

    mlproxy.getSynonyms(term, taxonomyId, function(err, result) {
      if (err) {
        res.json({
          success: false,
          message: err.message
        });
      } else {
        res.json(result);
      }
    });
  },

  narrator: function(req, res) {
    var term = req.query['term'];

    mlproxy.narrator(term, taxonomyId, function(err, result) {
      if (err) {
        res.json({
          success: false,
          message: err.message
        });
      } else {
        res.json(result);
      }
    });
  },

  getRootNodeList: function(req, res) {
    mlproxy.listRootNodes(taxonomyId, function(err, result) {
      if (err) {
        res.json({
          success: false,
          message: err.message
        });
      } else {
        res.json(result);
      }
    });
  }
}

module.exports = registry;
