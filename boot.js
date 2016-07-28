/*
 * Script to run from forever to start the server
 */
'use strict';

var argv = require('yargs').argv;

var env = argv['env'] || 'prod';

var options = require('./conf/' + env + '.js');

var server = require('./server.js').buildExpress(options);
server.listen(options.appPort);
