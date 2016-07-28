(function () {

  'use strict';

  angular
    .module('app')
    .directive('recordSection', RecordSection);

  function RecordSection() {
    return {
      restrict: 'E',
      transclude: true,
      templateUrl: '/views/record-section/record-section.html',
      scope: {
        title: '@',
        anchor: '@',
        controller: '='
      },
      /* @ngInject */
      controller: function($scope, $element, $attrs) {
        var c = $scope.controller;
        return c;
      },
      controllerAs: 'recordSectionCtrl',
      link: function(scope, ele) {
        scope.expanded = true;

        scope.links = [];
        var links = ele.find('record-section-links > record-section-link');
        angular.forEach(links, function(link) {
          var $link = angular.element(link);
          scope.links.push($link.html());
          $link.remove();
        });
        scope.toggle = function() {
          scope.expanded = !scope.expanded;
        };
      }
    };
  }

})();
