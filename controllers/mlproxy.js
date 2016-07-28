/*
 * @(#)mlproxy.js
 */

/*
 * Author: Jianmin Liu
 * Created: 2016/05/22
 * Description: The mlproxy module
 */
var fs = require('fs');
var path = require('path');
var uuid = require('uuid');
var FormData = require('form-data');

var config = {
  marklogic: {
    host: 'healthcare.demo.marklogic.com', // mlch4-datanode-2.demo.marklogic.com
    port: 8042, // 5042
    user: 'jliu',
    password: 'j456liu'
  }
};

function getContentType(fileName) {
  var ext = path.extname(fileName);
  var contentType = 'application/xml';

  if (ext === '.xml') {
    contentType = 'application/xml';
  } else if (ext === '.ttl') {
    contentType = 'application/x-turtle';
  } else {
    contentType = 'application/xml';
  }

  return contentType;
}

function getAuth() {
  return config.marklogic.user + ':' + config.marklogic.password;
}

function invokeTaxonomyExt(params, callback) {
  var form = new FormData();

  var keys = Object.keys(params);

  keys.forEach(function(key) {
    if (key === 'taxonomy_file') {
      var values = params[key];
      form.append(key, fs.createReadStream(values[0]), {
        filename: values[1],
        contentType: values[2]
      });
    } else {
      form.append(key, params[key]);
    }
  });

  // Submit the form with HTTP auth credentials
  form.submit({
    host: config.marklogic.host,
    port: config.marklogic.port,
    path: '/v1/resources/taxonomy',
    auth: getAuth()
  }, function(err, response) {
    //console.log(response.statusCode);
    //callback(new Error(JSON.stringify(err)));
    var body = '';

    response.on('data', function(chunk) {
      body += chunk;
    });

    response.on('end', function() {
      var obj = JSON.parse(body);
      //console.log(JSON.stringify(obj, null, 4));
      callback(null, obj);
    });
  });
}

var mlproxy = {
  uploadTaxonomy: function(taxonomyId, filepath, filename, callback) {
    var progressId = uuid.v4();
    var params = {
      'action': 'load',
      'user': config.marklogic.user,
      'taxonomyId': taxonomyId,
      'progressId': progressId,
      'filename': filename,
      'taxonomy_file': [ filepath, filename, getContentType(filename) ]
    };

    invokeTaxonomyExt(params, function(err, result) {
      if (result.result.success) {
        var params2 = {
          'action': 'createSynonyms',
          'taxonomyId': taxonomyId,
          'progressId': progressId
        };

        invokeTaxonomyExt(params2, callback);
      } else {
        callback(err, result);
      }
    });
  },

  listTaxonomies: function(callback) {
    var params = {
      'action': 'list',
      'user': config.marklogic.user
    };

    invokeTaxonomyExt(params, callback);
  },

  deleteTaxonomy: function(taxonomyId, callback) {
    var params = {
      'action': 'delete',
      'id': taxonomyId
    };

    invokeTaxonomyExt(params, callback);
  },

  getSuggests: function(term, taxonomyId, callback) {
    var params = {
      'action': 'getSuggests',
      'term': term,
      'taxonomyId': taxonomyId
    };

    invokeTaxonomyExt(params, callback);
  },

  getSynonyms: function(term, taxonomyId, callback) {
    var params = {
      'action': 'getSynonyms',
      'term': term,
      'taxonomyId': taxonomyId
    };

    invokeTaxonomyExt(params, callback);
  },

  narrator: function(term, taxonomyId, callback) {
    var params = {
      'action': 'narrator',
      'term': term,
      'taxonomyId': taxonomyId
    };

    invokeTaxonomyExt(params, callback);
  }
}

module.exports = mlproxy;
