(function () {

  'use strict';

  angular
    .module('app')
    .directive('infoChart', InfoChart);


  function InfoChart() {
    return {
      restrict: 'E',
      replace: true,
      templateUrl: '/views/info-chart/info-chart.html',
      scope: {
        data: '=',
        data2: '='
      },
      controller: '@',
      controllerAs: 'ctrl',
      name: 'controllerName',
      link: function(scope, ele) {
        scope.createChart = function(options) {
          var o = angular.extend(options, {});
          if (!o.chart) {
            o.chart = {};
          }
          o.chart.renderTo = ele[0];
          scope.chart = new Highcharts.Chart(o);
        };

        scope.compareDates = function(a, b) {
          if (a.x && b.x) {
            if (a.x < b.x) {
              return -1;
            }
            else if (a.x > b.x) {
              return 1;
            }
          }
          else {
            if (a[0] < b[0]) {
              return -1;
            }
            else if (a[0] > b[0]) {
              return 1;
            }
          }
          return 0;
        };
      }
    };
  }

})();
