(function () {

  'use strict';

  angular
    .module('app')
    .directive('medicationsTable', MedicationsTable);


  function MedicationsTable() {
    return {
      restrict: 'E',
      replace: true,
      templateUrl: '/views/medications/medicationsTable.html',
      scope: {
        data: '='
      },
      controller: 'MedicationsTableCtrl',
      controllerAs: 'ctrl',
      link: function(scope, ele) {
      }
    };
  }

})();
