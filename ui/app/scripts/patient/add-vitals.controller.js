(function () {

  'use strict';

  angular
    .module('app')
    .controller('AddVitalsCtrl', AddVitalsCtrl);

  AddVitalsCtrl.$inject = ['$scope', '$modalInstance', 'VitalsService', 'patientId'];

  function AddVitalsCtrl($scope, $modalInstance, vitals, patientId) {
    var ctrl = this;
    ctrl.patientId = patientId;
    ctrl.close = closeFunc;
    ctrl.save = save;
    ctrl.vitalType = 'bp';
    ctrl.vitalValue = null;
    updateUnits(ctrl.vitalType);

    $scope.$watch('addVitalsCtrl.vitalType', function(value) {
      updateUnits(value);
    });

    function closeFunc() {
      $modalInstance.dismiss('cancel');
    }

    function save() {
      var value;
      if (ctrl.vitalType === 'bp') {
        value = ctrl.systolic + '/' + ctrl.diastolic;
      }
      else {
        value = ctrl.vitalValue.toString();
      }
      vitals.addVitals(ctrl.patientId, ctrl.vitalType, ctrl.units, value).success(function(){
        $modalInstance.close();
      });
    }

    function updateUnits(type) {
      if (type === 'bp') {
        ctrl.units = 'mm[Hg]';
      }
      else if (type === 'pulse') {
        ctrl.units = '/min';
      }
      else if (type === 'temp') {
        ctrl.units = 'Cel';
      }
      else if (type === 'weight') {
        ctrl.units = 'kg';
      }
    }
  }

})();
