(function () {

  'use strict';

  angular
    .module('app')
    .directive('providerSearch', ProviderSearchDirective)
    .directive('radiusSearch', RadiusSearch);

  function ProviderSearchDirective() {
    return {
      restrict: 'EA',
      controller: 'ProviderSearchCtrl',
      controllerAs: 'providerSearchCtrl',
      templateUrl: '/views/provider/provider-search.html'
    };
  }

  var _defaultRadiusOptions = [
    { value: 5, label: '5 miles'},
    { value: 15, label: '10 miles'},
    { value: 30, label: '30 miles'},
    { value: 3000, label: 'anywhere' }
  ];


  RadiusSearch.$inject = [ '$timeout', '$modal' ];
  function RadiusSearch($timeout, $modal) {
    return {
      restrict: 'E',
      scope: {
        qtext: '=',
        zip: '=',
        radius: '=',
        semantic: '=',
        radiusOptions: '=',
        search: '&',
        suggest: '&',
        reset: '&'
      },
      templateUrl: '/views/provider/radius-search-form.html',
      link: function(scope, element, attrs) {
        scope.$watch('qtext', function(newVal) {
          if (newVal && newVal.synonym) {
            scope.qtext = newVal.synonym;
            scope.search({ qtext: scope.qtext });
          } else {
            if (newVal) {
              scope.qtext = newVal;
            } else {
              scope.qtext = '';
            }
          }
        });
        if (angular.isUndefined(scope.radiusOptions)) {
          scope.radiusOpts = _defaultRadiusOptions;
        } else {
          scope.$watch('radiusOptions', function(newVal, oldVal) {
            if (!newVal) {
              scope.radiusOpts = _defaultRadiusOptions;
            } else {
              scope.radiusOpts = newVal;
            }
          });
        }
        scope.$watch('radius', function(newVal, oldVal) {
          if (!newVal) {
            scope.radius = 15;
          }
        });
        scope.clear = function() {
          scope.zip = '';
          // need a timeout here to allow the ngModel value to update
          $timeout(function () { scope.search({ qtext: '' }); });
        };
      }
    };
  }

})();
