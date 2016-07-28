(function () {

  'use strict';

  angular
    .module('app')
    .directive('medicareTypedResult', MedicareTypedResult);

  function MedicareTypedResult() {
    return {
      restrict: 'E',
      replace: true,
      transcribe: true,
      templateUrl: '/views/search-results/medicare-typed-result.html',
      scope: {
        result: '='
      }
    };
  }

})();
