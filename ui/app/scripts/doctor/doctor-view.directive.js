(function () {

  'use strict';

  angular
    .module('app')
    .directive('doctorView', DoctorViewDirective);


  function DoctorViewDirective() {
    return {
      restrict: 'E',
      // replace: true,
      // transcribe: true,
      controller: 'DoctorCtrl as ctrl',
      templateUrl: '/views/doctor/doctor.html'
    };
  }

})();
