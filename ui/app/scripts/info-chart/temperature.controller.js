(function () {

  'use strict';

  angular
    .module('app')
    .controller('TemperatureChartCtrl', TemperatureChartCtrl);

  TemperatureChartCtrl.$inject = ['$scope'];
  function TemperatureChartCtrl($scope) {

    var ctrl = this;
    ctrl.title = 'Temperature';

    function createOptions(temps) {
      return {
        title: {
          text: 'Temperature'
        },

        xAxis: {
          type: 'datetime'
        },

        yAxis: [
          {
            title: {
              text: 'Temperature'
            },
            tickInterval: 10,
            tickLength: 6
          }
        ],

        tooltip: {
          crosshairs: true,
          shared: true,
          valueSuffix: '°F',
          xDateFormat: '%m-%d-%Y',
          pointFormat: '{series.name}: <b>{point.y}</b><span style="padding-left: 5px;">  Source: {point.source}<br/>'
        },

        series: [
          {
            name: 'Temperature',
            data: temps,
            zIndex: 1,
            yAxis: 0
          }
        ]
      };
    }

    $scope.$watch('data', function(newValue, oldValue) {
      var i, point, date, temps = [];
      if (newValue) {
        for (i = 0; i < newValue.length; i++) {
          point = newValue[i];
          date = new Date(point.date).getTime();
          temps.push({
            x: date,
            y: parseFloat(point.value),
            source: 'blah'//point.source
          });
        }

        temps.sort($scope.compareDates);

        if ($scope.chart) {
          $scope.chart.series[0].setData(temps, true);
        }
        else {
          $scope.createChart(createOptions(temps));
        }
      }
      else if ($scope.chart) {
        $scope.chart.series[0].setData([], true);
      }
    });
  }

})();
