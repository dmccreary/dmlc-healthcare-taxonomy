(function () {

  'use strict';

  angular
    .module('app')
    .factory('splService', SplService);

  SplService.$inject = ['$http'];
  function SplService($http) {

    var service = {
      getSplDoc: getSplDoc
    };

    return service;

    function getSplDoc(uri) {
      return $http.get('/v1/documents?uri=' + uri + '&transform=spl-html', {
        headers: { 'Accept': 'text/html' }
      }).then(function(data) {
        return data.data;
      });
    }
  }
})();
