(function () {

  'use strict';

  angular
    .module('app')
    .controller('HeightChartCtrl', HeightChartCtrl);

  HeightChartCtrl.$inject = ['$scope'];
  function HeightChartCtrl($scope) {

    var ctrl = this;
    ctrl.title = 'Height';

    function createOptions(heights) {
      return {
        title: {
          text: 'Height'
        },

        xAxis: {
          type: 'datetime'
        },

        yAxis: [
          {
            title: {
              text: 'Height'
            },
            tickInterval: 10,
            tickLength: 6
          }
        ],

        tooltip: {
          crosshairs: true,
          shared: true,
          valueSuffix: ' lbs',
          xDateFormat: '%m-%d-%Y',
          pointFormat: '{series.name}: <b>{point.y}</b><span style="padding-left: 5px;">  Source: {point.source}<br/>'
        },

        legend: {
        },

        series: [
          {
            name: 'Height',
            data: heights,
            zIndex: 1,
            yAxis: 0
          }
        ]
      };
    }

    $scope.$watch('data', function(newValue, oldValue) {
      var i, point, date, heights = [];
      if (newValue) {
        for (i = 0; i < newValue.length; i++) {
          point = newValue[i];
          date = new Date(point.date).getTime();
          heights.push({
            x: date,
            y: parseFloat(point.value),
            source: point.source
          });
        }

        heights.sort($scope.compareDates);

        if ($scope.chart) {
          $scope.chart.series[0].setData(heights, true);
        }
        else {
          $scope.createChart(createOptions(heights));
        }
      }
      else if ($scope.chart) {
        $scope.chart.series[0].setData([], true);
      }
    });
  }

})();
