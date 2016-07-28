(function () {

  'use strict';

  angular.module('app', [
    'ngCookies',
    'ngRoute',
    'ui.bootstrap',
    'http-auth-interceptor',
    'ng.httpLoader',
    'ml.common',
    'ml.search',
    'ml.search.tpls',
    'google-maps',
    'compile',
    'ngJsonExplorer'
  ])
  .run(AppRun);

  function AppRun($rootScope, $route, $location) {
    $rootScope.$on('event:auth-loginRequired', function() {
      $location.path('/login/');
    });
  }

})();
