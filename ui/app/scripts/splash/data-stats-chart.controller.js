(function () {

  'use strict';

  angular
    .module('app')
    .controller('DataStatsChartCtrl', DataStatsChartCtrl);

  DataStatsChartCtrl.$inject = ['$scope'];
  function DataStatsChartCtrl($scope) {

    var ctrl = this;
    ctrl.title = 'Data Sources';

    function createOptions(sources) {
      return {
        chart: {
          type: 'column'
        },

        title: {
          text: 'Data Sources'
        },

        xAxis: {
          type: 'category',
          labels: {
            // rotation: -45,
            style: {
              fontSize: '10px',
              fontFamily: 'Verdana, sans-serif'
            }
          }
        },

        yAxis: {
          min: 1,
          type: 'logarithmic',
          title: {
            text: 'Count'
          }
        },

        tooltip: {
          crosshairs: true,
          shared: false,
          useHTML: true,
          headerFormat: '<span class="name">{point.key}</span><br/>',
          pointFormat: '<b style="margin-top: 2px">{point.y} {point.format}</b><br/><a href="{point.url}" target="_blank">Source</a><br/><p>{point.desc}</p>'
        },

        series: [
          {
            name: 'Data Source',
            data: sources
          }
        ]
      };
    }

    $scope.$watch('data', function(newValue, oldValue) {
      var i, point, sources = [];
      if (newValue) {
        for (i = 0; i < newValue.length; i++) {
          point = newValue[i];
          sources.push({
            name: point.name,
            y: point.count,
            desc: point.description,
            format: point.format,
            url: point.url
          });
        }

        if ($scope.chart) {
          $scope.chart.series[0].setData(sources, true);
        }
        else {
          $scope.createChart(createOptions(sources));
        }
      }
      else if ($scope.chart) {
        $scope.chart.series[0].setData([], true);
      }
    });
  }

})();

