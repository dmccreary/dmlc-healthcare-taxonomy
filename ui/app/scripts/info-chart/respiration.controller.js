(function () {

  'use strict';

  angular
    .module('app')
    .controller('RespirationChartCtrl', RespirationChartCtrl);

  RespirationChartCtrl.$inject = ['$scope'];
  function RespirationChartCtrl($scope) {

    var ctrl = this;
    ctrl.title = 'Respiration';

    function createOptions(respirations) {
      return {
        title: {
          text: 'Respiration'
        },

        xAxis: {
          type: 'datetime'
        },

        yAxis: [
          {
            title: {
              text: 'Respiration'
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
          pointFormat: '{series.name}: <b>{point.y}</b><span style="padding-left: 5px;">  Source: {point.source}<br/>'
        },

        legend: {
        },

        series: [
          {
            name: 'Respiration',
            data: respirations,
            zIndex: 1,
            yAxis: 0
          }
        ]
      };
    }

    $scope.$watch('data', function(newValue, oldValue) {
      var i, point, date, respirations = [];
      if (newValue) {
        for (i = 0; i < newValue.length; i++) {
          point = newValue[i];
          date = new Date(point.date).getTime();
          respirations.push({
            x: date,
            y: parseInt(point.value, 10),
            source: point.source
          });
        }

        respirations.sort($scope.compareDates);

        if ($scope.chart) {
          $scope.chart.series[0].setData(respirations, true);
        }
        else {
          $scope.createChart(createOptions(respirations));
        }
      }
      else if ($scope.chart) {
        $scope.chart.series[0].setData([], true);
      }
    });
  }

})();
