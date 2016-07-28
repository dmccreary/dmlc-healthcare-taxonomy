(function () {
  'use strict';

  angular.module('app')
    .controller('PayorCtrl', PayorCtrl);

    function PayorCtrl($route, $location, constraints) {
      var ctrl = this;

      angular.extend(ctrl, {
        isClaimSearch: isClaimSearch(),
        showClaimSearch: showClaimSearch,
        showDashboard: showDashboard,
        constraints: constraints
      });

      function isClaimSearch() {
        return $route.current.pathParams.search === 'claims';
      }

      function showClaimSearch() {
        if (isClaimSearch()) {
          return;
        }
        $route.current.pathParams.search = 'claims';
        $location.path('/payor/'+$route.current.pathParams.search);
        ctrl.isFindProvider = true;
      }

      function showDashboard() {
        if (isClaimSearch()) {
          delete $route.current.pathParams.search;
          $location.path('/payor/');
          ctrl.isFindProvider = false;
        }
      }
    }

}());
