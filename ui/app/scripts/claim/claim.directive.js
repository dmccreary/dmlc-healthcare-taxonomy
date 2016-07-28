(function () {

  'use strict';

  angular
    .module('app')
    .directive('claimView', ClaimDirective);

  function ClaimDirective() {
    return {
      restrict: 'E',
      scope: {
        doc: '='
      },
      templateUrl: '/views/claim/claim.html',
      link: function(scope) {
        scope.ctrl = {
          doc: scope.doc
        };
      }
    };
  }

})();
