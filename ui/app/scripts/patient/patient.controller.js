(function () {
  'use strict';

  angular.module('app')
    .controller('PatientCtrl', PatientCtrl);


    PatientCtrl.$inject = ['patientUri', 'patient', '$route', '$location', '$modal'];
    function PatientCtrl(patientUri, patient, $route, $location, $modal) {
      var ctrl = this;

      angular.extend(ctrl, {
        patientUri: patientUri,
        patient: patient,
        isFindProvider: isDocFind(),
        showDocFind: showDocFind,
        showRecords: showRecords
      });

      function isDocFind() {
        return $route.current.pathParams.docFind === 'docfind';
      }

      function showDocFind() {
        if (isDocFind()) {
          return;
        }
        $route.current.pathParams.docFind = 'docfind';
        $location.path('/patient/'+$route.current.pathParams.docFind);
        $location.search({
          qzip: patient.address.postalCode,
          qradius: 30
        });
        ctrl.isFindProvider = true;
      }

      function showRecords() {
        if (isDocFind()) {
          delete $route.current.pathParams.docFind;
          $location.path('/patient/');
          ctrl.isFindProvider = false;
        }
      }
    }
}());
