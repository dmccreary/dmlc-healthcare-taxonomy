/*jshint node: true */

/*
 * @author Dave Cassel - https://github.com/dmcassel
 *
 * This file configures the publicly visible server-side endpoints of your application. Work in this file to allow
 * access to parts of the MarkLogic REST API or to configure your own application-specific endpoints.
 * This file also handles session authentication, with authentication checks done by attempting to access MarkLogic.
 */
'use strict';

var bodyParser = require('body-parser');
var cookieParser = require('cookie-parser');
var expressSession = require('express-session');
var http = require('http');
var path = require('path');
var multer = require('multer');

var upload = multer({dest: 'tmp/'});

var registry = require('./controllers/registry');

function auth(req, res, next) {
  if (req.session.user === undefined) {
    res.redirect('/login/');
  }
  else {
    next();
  }
}

exports.buildExpress = function(options) {

  options.appRoot = path.join(__dirname, options.appRoot);

  var express = require('express');
  var app = express();

  app.use(cookieParser());

  // Change this secret to something unique to your application
  app.use(expressSession({
    secret: ']9nHgbDMNse)KT/;zp7y2LiUk9W',
    saveUninitialized: true,
    resave: true
  }));
  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({
    extended: true
  }));

  // Generic proxy function used by multiple HTTP verbs
  function proxy(req, res) {
    var queryString = req.originalUrl.split('?')[1];
    console.log(req.method + ' ' + req.path + ' proxied to ' + options.mlHost + ':' + options.mlPort + req.path + (queryString ? '?' + queryString : ''));
    var mlReq = http.request({
      hostname: options.mlHost,
      port: options.mlPort,
      method: req.method,
      path: req.path + (queryString ? '?' + queryString : ''),
      headers: req.headers,
      auth: req.session.auth
    }, function(response) {
      // some requests (POST /v1/documents) return a location header. Make sure
      // that gets back to the client.
      res.status(response.statusCode);
      if (response.headers.location) {
        res.header('location', response.headers.location);
      }

      if (response.headers['content-type']) {
        res.header('content-type', response.headers['content-type']);
      }

      response.on('data', function(chunk) {
        res.write(chunk);
      });
      response.on('end', function() {
        res.end();
      });
    });

    if (req.body !== undefined) {
      mlReq.write(JSON.stringify(req.body));
      mlReq.end();
    }

    mlReq.on('error', function(e) {
      console.log('Problem with request: ' + e.message);
      res.status(500).send(e);
    });
  }

  app.get('/user/status', function(req, res) {
    if (req.session.user === undefined) {
      res.send('{"authenticated": false}');
    }
    else {
      res.send(req.session.user);
    }
  });

  app.post('/user/login', function(req, res) {
    // Attempt to read the user's profile, then check the response code.
    // 404 - valid credentials, but no profile yet
    // 401 - bad credentials

    var user = req.param('username');
    var password = req.param('password');
    var auth  = [user, password].join(':');
    var o = {
      hostname: options.mlHost,
      port: options.mlPort,
      path: '/v1/resources/auth?rs:user=' + user + '&rs:password=' + password,
      auth: auth
    };

    http.get(o, function(response) {
      if (response.statusCode === 401) {
        res.status(401).send();
      }
      else {
        if (response.statusCode === 200) {
          // authentication successful, remember the user
          response.on('data', function(chunk) {
            var user = JSON.parse(chunk);
            req.session.user = user.user;
            req.session.auth = auth;
            res.status(200).send(user.user);
          });
        }
      }
    }).on('error', function(e) {
      console.log('login failed: ' + e.message);
      res.status(500).send(e);
    });
  });

  app.get('/user/logout', function(req, res) {
    delete req.session.user;
    res.send();
  });

  app.get('/v1/resources/datasources', function(req, res) {
    proxy(req, res);
  });

  // ==================================
  // MarkLogic REST API endpoints
  // ==================================
  // For any other GET request, proxy it on to MarkLogic.
  app.get('/v1*', function(req, res) {
    // To require authentication before getting to see data, use this:
    if (req.session.user === undefined) {
      res.send(401, 'Unauthorized');
    }
    else {
      proxy(req, res);
    }
    // -- end of requiring authentication

  });

  app.put('/v1*', function(req, res) {
    // For PUT requests, require authentication
    if (req.session.user === undefined) {
      res.status(401).send('Unauthorized');
    }
    else if (req.path === '/v1/documents' &&
      req.query.uri.match('/users/') &&
      req.query.uri.match(new RegExp('/users/[^(' + req.session.user.name + ')]+.json'))) {
      // The user is try to PUT to a profile document other than his/her own. Not allowed.
      res.status(403).send('Forbidden');
    }
    else {
      if (req.path === '/v1/documents' && req.query.uri.match('/users/')) {
        // TODO: The user is updating the profile. Update the session info.
      }
      proxy(req, res);
    }
  });

  // Require authentication for POST requests
  app.post('/v1*', function(req, res) {
    if (req.session.user === undefined) {
      res.status(401).send('Unauthorized');
    }
    else {
      proxy(req, res);
    }
  });

  // Require authentication for POST requests
  app.delete('/v1*', function(req, res) {
    if (req.session.user === undefined) {
      res.status(401).send('Unauthorized');
    }
    else {
      proxy(req, res);
    }
  });


  app.use('/bower_components/', express.static(path.join(options.appRoot, '../bower_components')));
  app.use('/styles/', express.static(path.join(options.appRoot, 'styles')));
  app.use('/login/', express.static(options.appRoot));

  app.get('/physician*', auth, function(req, res, next) {
    if (req.session.user === undefined) {
      res.status(401).send('Unauthorized');
      return;
    }
    else if (req.session.user.role !== 'physician') {
      res.status(404).send('Not Found');
    }

    return next();
  });

  app.get('/researcher*', auth, function(req, res, next) {
    if (req.session.user === undefined) {
      res.status(401).send('Unauthorized');
      return;
    }
    else if (req.session.user.role !== 'researcher') {
      res.status(404).send('Not Found');
    }

    return next();
  });

  app.get('/patient*', auth, function(req, res, next) {
    if (req.session.user === undefined) {
      res.status(401).send('Unauthorized');
      return;
    }
    else if (req.session.user.role !== 'patient') {
      res.status(404).send('Not Found');
    }
    return next();
  });

  app.get('/payor*', auth, function(req, res, next) {
    if (req.session.user === undefined) {
      res.status(401).send('Unauthorized');
      return;
    }
    else if (req.session.user.role !== 'payor') {
      res.status(404).send('Not Found');
    }
    return next();
  });

  app.get('/provider/narrator', auth, function(req, res, next) {
    console.log('/provider/narrator: ' + req.query.q);

    if (req.session.user === undefined) {
      res.status(401).send('Unauthorized');
      return;
    }
    else if (req.session.user.role !== 'patient') {
      res.status(404).send('Not Found');
    }

    // (Neurology)
    var suggestions = [
      'Acute', 
      '"pain"', 
      '"syndrome"'
    ];

    res.json({
      success: true,
      message: 'success',
      suggestions: suggestions
    });
  });

  // Upload a rdf/xml or ttl file as a taxonomy
  app.post('/taxonomy/upload', upload.single('taxonomy_file'), function(req, res, next) {
    registry.uploadTaxonomy(req, res, __dirname);
  });

  app.get('/taxonomy/list', auth, function(req, res, next) {
    registry.listTaxonomies(req, res);
  });

  app.delete('/taxonomy/delete', auth, function(req, res, next) {
    registry.deleteTaxonomy(req, res);
  });

  app.get('/taxonomy/suggest', auth, function(req, res, next) {
    registry.getSuggests(req, res);
  });

  app.get('/taxonomy/synonyms', auth, function(req, res, next) {
    registry.getSynonyms(req, res);
  });

  app.get('/taxonomy/narrator', auth, function(req, res, next) {
    registry.narrator(req, res);
  });

  app.get('/taxonomy/root', auth, function(req, res, next) {
    registry.getRootNodeList(req, res);
  });

  app.use(express.static(options.appRoot));

  app.all('/*', function(req, res, next) {
      // Just send the index.html for other files to support HTML5Mode
      res.sendfile(path.join(options.appRoot, 'index.html'));
  });

  return app;
};
