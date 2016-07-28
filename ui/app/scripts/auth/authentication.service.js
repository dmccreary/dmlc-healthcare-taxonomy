(function () {

  'use strict';

  angular
    .module('app')
    .factory('AuthenticationService', AuthService);

  AuthService.$inject = ['$http', '$q', '$rootScope', 'authService'];
  function AuthService($http, $q, $rootScope, authService) {

    var user;

    var service = {
      getUser: getUser,
      userHasRole: userHasRole,
      login: login,
      logout: logout
    };

    return service;

    function setUser(u) {
      user = u;
      authService.loginConfirmed(user);
      return user;
    }

    function getUser() {
      if (user) {
        var d = $q.defer();
        d.resolve(user);
        return d.promise;
      }
      else {
        return $http.get('/user/status').then(function(data) {
          return setUser(data.data);
        });
      }
    }

    function userHasRole(role) {
      return (user && user.role === role);
    }

    function login(username, password) {
      return $http.post('/user/login', {
        username: username,
        password: password
      }).success(function(data) {
        return setUser(data);
      });
    }

    function logout() {
      return $http.get('/user/logout').then(function(data) {
        $rootScope.$broadcast('event:auth-loginRequired', null);
        return data;
      });
    }
  }
})();
