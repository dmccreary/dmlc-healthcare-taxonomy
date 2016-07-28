(function () {

  'use strict';

  angular
    .module('app')
    .controller('MedicationsTableCtrl', MedicationsTableCtrl);

  MedicationsTableCtrl.$inject = ['$modal', '$http'];

  function MedicationsTableCtrl($modal, $http) {

    var ctrl = this;

    ctrl.showLabel = showLabel;

    function showLabel(spl, name) {
      var params = {};
      if (spl) {
        params['rs:spl'] = spl;
      }
      else {
        params['rs:drugName'] = name;
      }
      $modal.open({
        templateUrl: '/views/spl/spl.html',
        controller: 'SplCtrl as ctrl',
        resolve: {
          details: function () {
            return $http({
              method: 'GET',
              url: '/v1/resources/spl?' + $.param(params),
              headers: {
                accept: 'application/json'
              }
              // responseType: 'text'
            });
          }
        }
      });
    }
  }

})();
