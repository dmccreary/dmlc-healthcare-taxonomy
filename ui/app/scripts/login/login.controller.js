(function () {

  'use strict';

  angular
    .module('app')
    .controller('LoginCtrl', LoginCtrl);

  LoginCtrl.$inject = ['$location', '$rootScope', 'AuthenticationService', 'authService', '$scope'];

  function LoginCtrl($location, $rootScope, loginService, authService, $scope) {
    var ctrl = this;

    ctrl.login = login;

    ctrl.users = {
      'doctor': { label: 'Doctor', password: 'GNqxGUKgwiVprHCag2hKj7pyz', desc: 'The doctor can manage patients' },
      'patient': { label: 'Patient', password: 'kjCcTKdRChyHPbFE3NKTDnqa7', desc: 'Search for providers and manage profile' },
      'payor': { label: 'Payor', password: 'Zkh4gpCWBswrVixoTnM9xEMqd', desc: 'Search for claims' },
      'researcher': { label: 'Researcher', password: 'oSDcp27QKTTL5d2Fc', desc: 'Search for data insights' }
    };

    $scope.$watch(function() { return ctrl.username; }, function(newVal, oldVal) {
      var usr = ctrl.users[newVal];
      if (usr) {
        ctrl.userlabel = usr.label;
        ctrl.password = usr.password;
        ctrl.userdesc = usr.desc;
      } else {
        delete ctrl.userlabel;
        delete ctrl.password;
        delete ctrl.userdesc;
      }
    });

    function login(user, password) {
      ctrl.loginError = false;
      loginService.login(ctrl.username, ctrl.password).success(function(data) {
        $location.path('/' + data.role + '/');
      });
    }

    $rootScope.$on('event:auth-loginRequired', function(rejection){
      ctrl.loginError = true;
    });
  }

})();
