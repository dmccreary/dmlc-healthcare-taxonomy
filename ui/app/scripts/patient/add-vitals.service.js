(function () {

  'use strict';

  angular
    .module('app')
    .factory('VitalsService', VitalsService);

  VitalsService.$inject = ['$http'];
  function VitalsService($http) {
    var service = {
      addVitals: addVitals,
      deleteVitals: deleteVitals
    };
    return service;

    function addVitals(id, type, units, value) {
      return $http.post('/v1/resources/vitals', {
        patientID: id,
        type: type,
        units: units,
        value: value
      });
    }

    function deleteVitals() {
      return $http.delete('/v1/resources/vitals');
    }
  }
})();
