(function () {
  'use strict';

  angular.module('app')
    .controller('SavedSearchCtrl', SavedSearchCtrl);

    SavedSearchCtrl.$inject = ['$modalInstance'];
    function SavedSearchCtrl($modalInstance) {
      var ctrl = this;
      angular.extend(ctrl, {
        searchName: null,
        ok: ok,
        cancel: cancel
      });

      function ok() {
        $modalInstance.close(ctrl.searchName);
      }

      function cancel() {
        $modalInstance.dismiss('cancel');
      }
    }
}());
