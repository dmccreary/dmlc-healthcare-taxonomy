(function () {

  'use strict';

  angular
    .module('app')
    .controller('HeartRateChartCtrl', HeartRateChartCtrl);

  HeartRateChartCtrl.$inject = ['$scope'];
  function HeartRateChartCtrl($scope) {

    var ctrl = this;
    ctrl.title = 'Heart Rate';

    function createOptions(pulses) {
      return {
        title: {
          text: 'Heart Rate'
        },

        xAxis: {
          type: 'datetime'
        },

        yAxis: [
          {
            title: {
              text: 'Pulse'
            },
            tickInterval: 10,
            tickLength: 6
          }
        ],

        tooltip: {
          crosshairs: true,
          shared: true,
          valueSuffix: '/min',
          xDateFormat: '%m-%d-%Y',
          pointFormat: '{series.name}: <b>{point.y}</b><span>  Source: {point.source}<br/>'
        },

        series: [
          {
            name: 'Pulse',
            data: pulses,
            zIndex: 1,
            yAxis: 0
          }
        ]
      };
    }

    $scope.$watch('data', function(newValue, oldValue) {
      var i, point, date, pulses = [];
      if (newValue) {
        for (i = 0; i < newValue.length; i++) {
          point = newValue[i];
          date = new Date(point.date).getTime();
          pulses.push({
            x: date,
            y: parseInt(point.value, 10),
            source: point.source
          });
        }

        pulses.sort($scope.compareDates);

        if ($scope.chart) {
          $scope.chart.series[0].setData(pulses, true);
        }
        else {
          $scope.createChart(createOptions(pulses));
        }
      }
      else if ($scope.chart) {
        $scope.chart.series[0].setData([], true);
      }
    });
  }

})();
