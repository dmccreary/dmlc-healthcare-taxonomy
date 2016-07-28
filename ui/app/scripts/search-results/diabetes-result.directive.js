(function () {

  'use strict';

  angular
    .module('app')
    .directive('diabetesResult', DiabetesResult);

  function DiabetesResult() {
    function getTitle(diabetes) {
      return [diabetes.content.diabetes.race, diabetes.content.diabetes.gender, diabetes.content.diabetes.age].join(' ');
    }
    return {
      restrict: 'E',
      replace: true,
      transcribe: true,
      templateUrl: '/views/search-results/diabetes-result.html',
      scope: {
        diabetes: '='
      },
      link: function(scope) {
        scope.getTitle = getTitle;
      }
    };
  }

})();
