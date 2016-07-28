(function () {

  'use strict';

  angular
    .module('app')
    .directive('chart', Chart);


  function Chart() {
    return {
      restrict: 'E',
      replace: true,
      template: '<div class="chart"></div>',
      scope: {
        data: '=',
        labels: '='
      },
      controller: '@',
      controllerAs: 'ctrl',
      name: 'controllerName',
      link: function(scope, ele, attr) {
        var defaultHeight = Math.max(window.innerHeight - 225, 400); // magic number: account for header and footer height (no less than 400)
        scope.createChart = function(options) {
          ele.css('height', attr.height || defaultHeight);

          var o = angular.extend(options, {});
          if (!o.chart) {
            o.chart = {};
          }
          o.chart.renderTo = ele[0];
          ele.css('height', attr.height || '400px');
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
