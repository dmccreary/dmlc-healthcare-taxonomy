(function () {

  'use strict';

  angular
    .module('app')
    .directive('splResult', SplResult);

  function SplResult() {
    return {
      restrict: 'E',
      replace: true,
      transcribe: true,
      templateUrl: '/views/search-results/spl-result.html',
      scope: {
        spl: '='
      }
    };
  }

})();
