(function () {

  'use strict';

  angular
    .module('app')
    .directive('faersResult', FaersResult);

  function FaersResult() {
    function getTitle(faers) {
      var res = [];
      _.each(faers.content.drugs, function(drug) {
        res.push(drug);
      });
      return res.join(' | ');
    }

    return {
      restrict: 'E',
      replace: true,
      transcribe: true,
      templateUrl: '/views/search-results/faers-result.html',
      scope: {
        faers: '='
      },
      link: function(scope) {
        scope.getTitle = getTitle;
      }
    };
  }

})();
