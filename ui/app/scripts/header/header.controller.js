(function () {

  'use strict';

  angular
    .module('app')
    .controller('HeaderCtrl', HeaderCtrl);

  HeaderCtrl.$inject = ['$scope', '$location', '$anchorScroll', 'AuthenticationService'];

  function HeaderCtrl($scope, $location, $anchorScroll, auth) {
    var ctrl = this;
    ctrl.logout = logout;
    ctrl.isActive = isActive;

    function logout() {
      auth.logout().then(function() {
        $location.path('/login/').search('');
      });
    }

    function isActive(viewLocation) {
      return viewLocation === $location.path();
    }

    (function init() {
      $scope.$on('event:auth-loginConfirmed', function(evt, user) {
        ctrl.user = user;
      });

      $scope.$on('event:auth-loginRequired', function(evt) {
        ctrl.user = null;
      });

      // auth.getUser().then(function(data) {
      //   ctrl.user = data;
      // });
    })();
  }

})();
