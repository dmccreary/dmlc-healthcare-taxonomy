(function () {

  'use strict';

  angular
    .module('app')
    .directive('patientResult', PatientResult);

  function PatientResult() {
    return {
      restrict: 'E',
      replace: true,
      transcribe: true,
      templateUrl: '/views/search-results/patient-result.html',
      scope: {
        patient: '='
      }
    };
  }

})();
