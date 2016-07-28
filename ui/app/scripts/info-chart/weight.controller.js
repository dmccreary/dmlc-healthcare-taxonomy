(function () {

  'use strict';

  angular
    .module('app')
    .controller('WeightChartCtrl', WeightChartCtrl);

  WeightChartCtrl.$inject = ['$scope'];
  function WeightChartCtrl($scope) {

    var ctrl = this;
    ctrl.title = 'Weight';

    function createOptions(weights) {
      return {
        title: {
          text: 'Weight'
        },

        xAxis: {
          type: 'datetime'
        },

        yAxis: [
          {
            title: {
              text: 'Weight'
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
            name: 'Weight',
            data: weights,
            zIndex: 1,
            yAxis: 0
          }
        ]
      };
    }

    $scope.$watch('data', function(newValue, oldValue) {
      var i, point, date, weights = [];
      if (newValue) {
        for (i = 0; i < newValue.length; i++) {
          point = newValue[i];
          date = new Date(point.date).getTime();
          weights.push({
            x: date,
            y: parseFloat(point.value),
            source: point.source
          });
        }

        weights.sort($scope.compareDates);

        if ($scope.chart) {
          $scope.chart.series[0].setData(weights, true);
        }
        else {
          $scope.createChart(createOptions(weights));
        }
      }
      else if ($scope.chart) {
        $scope.chart.series[0].setData([], true);
      }
    });
  }

})();
