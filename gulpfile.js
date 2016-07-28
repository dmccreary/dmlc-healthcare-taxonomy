/*jshint node: true */

'use strict';

/*
 * @author Dave Cassel - https://github.com/dmcassel
 *
 * This file contains the Gulp tasks you can run. As written, you'll typically run two processes :
 * $ gulp
 * - this will watch the file system for changes, running JSHint, compiling lesscss.js files, and minifying JS
 * $ gulp server
 * - run a node server, hosting the AngularJS application
 */

var gulp = require('gulp');
var argv = require('yargs').argv;
// var concat = require('gulp-concat');
var jshint = require('gulp-jshint');
var less = require('gulp-less');
var sourcemaps = require('gulp-sourcemaps');
var ngAnnotate = require('gulp-ng-annotate');
var templateCache = require('gulp-angular-templatecache');
var karma = require('karma').server;
var path = require('path');
// var rename = require('gulp-rename');
var uglify = require('gulp-uglify');
var usemin = require('gulp-usemin');
var minifyHtml = require('gulp-minify-html');
var minifyCss = require('gulp-minify-css');
var rev = require('gulp-rev');
var clean = require('gulp-clean');
var replace = require('gulp-replace');

var options = {
  appPort: argv['app-port'] || 9042,
  mlHost: argv['ml-host'] || 'healthcare.demo.marklogic.com',
  mlPort: argv['ml-port'] || '8042',
  defaultUser: 'dmlc-healthcare-user',
  defaultPass: '8K$,x9J.O|3At"((0f</',
  appRoot: 'ui/app',
  dist: 'dist'
};

gulp.task('jshint', function() {
  gulp.src(['ui/app/scripts/**/*.js'])
    .pipe(jshint())
    .pipe(jshint.reporter('default'));
});

// Compile Our Less
gulp.task('less', function() {
  return gulp.src('ui/app/styles/main.less')
    .pipe(sourcemaps.init())
    .pipe(less())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('ui/app/styles/'));
});

// Concatenate & Minify JS
// gulp.task('scripts', function() {
//   return gulp.src(['ui/app/app.js', 'ui/app/**/*.js', '!ui/app/js/*.js', '!ui/app/bower_components/**/*.js'])
//     .pipe(sourcemaps.init())
//       .pipe(concat('all.js'))
//       .pipe(gulp.dest('ui/app/js'))
//       .pipe(rename('all.min.js'))
//       .pipe(ngAnnotate())
//       .pipe(uglify())
//     .pipe(sourcemaps.write())
//     .pipe(gulp.dest('ui/app/js'));
// });

gulp.task('templates', function() {
  gulp.src('ui/app/views/**/*.html')
    .pipe(templateCache({
      module: 'app',
      root: '/views/'
    }))
    .pipe(gulp.dest(options.dist + '/scripts'));
});

gulp.task('usemin', ['less', 'templates'], function() {
  gulp.src('ui/app/index.html')
    .pipe(usemin({
      css: [minifyCss(), 'concat'],
      html: [minifyHtml({empty: true})],
      js: ['concat', ngAnnotate(), uglify(), rev()]
    }))
    .pipe(gulp.dest(options.dist));
});

// gulp.task('fonts', function() {
//   bower_components/bootstrap/fonts
// })

// Watch Files For Changes
gulp.task('watch', function() {
  gulp.watch(['ui/app/scripts/**/*.js'], ['jshint']);
  gulp.watch('ui/app/styles/*.less', ['less']);
});

gulp.task('test', function() {
  karma.start({
    configFile: path.join(__dirname, './karma.conf.js'),
    singleRun: true,
    autoWatch: false
  }, function (exitCode) {
    console.log('Karma has exited with ' + exitCode);
    process.exit(exitCode);
  });
});

gulp.task('autotest', function() {
  karma.start({
    configFile: path.join(__dirname, './karma.conf.js'),
    autoWatch: true
  }, function (exitCode) {
    console.log('Karma has exited with ' + exitCode);
    process.exit(exitCode);
  });
});

gulp.task('server', function() {
  var server = require('./server.js').buildExpress(options);
  server.listen(options.appPort);
  console.log('LISTENING ON PORT: ' + options.appPort);
});

gulp.task('clean', function() {
  return gulp.src([options.dist + '*', '!' + options.dist + '.git*'])
    .pipe(clean());
});

gulp.task('build', ['jshint', 'less', 'usemin'], function() {
  // gulp.src('ui/app/js/all.min.js')
  //   .pipe(gulp.dest(options.dist + '/js'));

  // copy fonts
  gulp.src([
    'ui/bower_components/bootstrap/fonts/*',
    'ui/bower_components/font-awesome/fonts/*',
    'ui/app/fonts/fontello.*'
  ]).pipe(gulp.dest(options.dist + '/fonts'));

  // copy images
  gulp.src(['ui/app/images/*'])
    .pipe(gulp.dest(options.dist + '/images'));

  gulp.src(['ui/app/robots.txt'])
    .pipe(gulp.dest(options.dist));

  // fix font paths
  gulp.src(options.dist + '/styles/main.css')
    .pipe(replace('/bower_components/bootstrap/fonts', '/fonts'))
    .pipe(replace('/bower_components/font-awesome/fonts', '/fonts'))
    .pipe(gulp.dest(options.dist + '/styles'));
});

// Default Task
gulp.task('default', ['jshint', 'less', 'watch', 'server']);
