(function () {

  'use strict';

  angular
    .module('app')
    .controller('SplCtrl', SplCtrl);

  SplCtrl.$inject = ['$modalInstance', 'details'];
  function SplCtrl($modalInstance, details) {
    var ctrl = this;
    angular.extend(ctrl, {
      doc: details.data,
      close: _close
    });

    function _close() {
      $modalInstance.dismiss('cancel');
    }
  }

})();
