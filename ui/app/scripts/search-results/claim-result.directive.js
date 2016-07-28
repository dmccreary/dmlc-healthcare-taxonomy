(function () {

  'use strict';

  angular
    .module('app')
    .directive('claimResult', ClaimResult);

  function ClaimResult() {
    return {
      restrict: 'E',
      replace: true,
      transcribe: true,
      templateUrl: '/views/search-results/claim-result.html',
      scope: {
        claim: '='
      }
    };
  }

})();
