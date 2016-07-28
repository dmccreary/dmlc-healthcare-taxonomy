(function () {

  'use strict';

  angular.module('app')
    .directive('patientResults', PatientResults)
    .controller('patientResultsCtrl', PatientResultsCtrl);

  function PatientResults() {
    return {
      restrict: 'E',
      scope: {
        results: '=',
        link: '&'
      },
      templateUrl: '/views/search-results/search-results.html',
      controller: 'patientResultsCtrl',
      controllerAs: 'ctrl'
    };
  }

  function PatientResultsCtrl() {
    var ctrl = this;

    angular.extend(ctrl, {
      extractFieldName: extractFieldName
    });

    function extractFieldName(path) {
      return path.replace(/.*:([^:]+)$/, '$1');
    }
  }


}());
