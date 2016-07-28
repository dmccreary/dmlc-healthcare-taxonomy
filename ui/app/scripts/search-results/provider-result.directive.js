(function () {

  'use strict';

  angular
    .module('app')
    .directive('providerResult', ProviderResult);

  function ProviderResult() {
    return {
      restrict: 'E',
      replace: true,
      transcribe: true,
      templateUrl: '/views/search-results/provider-result.html',
      scope: {
        provider: '='
      }
    };
  }

})();
