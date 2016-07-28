(function () {

  'use strict';

  angular
    .module('app')
    .directive('payorSearch', PayorSearchDirective)
    .controller('PayorSearchCtrl', PayorSearchCtrl);

  function PayorSearchDirective() {
    return {
      restrict: 'EA',
      controller: 'PayorSearchCtrl',
      controllerAs: 'payorSearchCtrl',
      templateUrl: '/views/payor/claim-search.html'
    };
  }

  PayorSearchCtrl.$inject = ['$scope', '$location', 'MLSearchFactory', 'MLRest'];

  // inherit from MLSearchController
  var superCtrl = MLSearchController.prototype;
  PayorSearchCtrl.prototype = Object.create(superCtrl);

  function PayorSearchCtrl($scope, $location, searchFactory, mlRest) {
    var ctrl = this;
    var mlSearch = searchFactory.newContext({
      queryOptions: 'all'
    }).setTransform('search-results');

    superCtrl.constructor.call(ctrl, $scope, $location, mlSearch);

    angular.extend(ctrl, {
      // TODO: remove when ml-search-ng is updated
      mlRest: mlRest
    });

    ctrl.init();
  }

})();
