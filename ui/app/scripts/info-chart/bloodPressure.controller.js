(function () {

  'use strict';

  angular
    .module('app')
    .controller('BpChartCtrl', BpChartCtrl);

  BpChartCtrl.$inject = ['$scope'];

  function BpChartCtrl($scope) {

    var ctrl = this;
    ctrl.title = 'Blood Pressure';

    function createOptions(systolics, diastolics) {
      var colors = {
        green: 'rgba(30, 188, 22, 0.35)',
        yellow: 'rgba(252, 255, 76, 0.35)',
        orange: 'rgba(255, 147, 21, 0.35)',
        pink: 'rgba(253, 74, 14, 0.35)',
        red: 'rgba(230, 0, 8, 0.35)'
      };

      return {
        title: {
          text: 'Blood Pressure'
        },

        xAxis: {
          type: 'datetime'
        },

        yAxis: [
          {
            title: {
              text: 'Systolic',
              style: {
                'color': Highcharts.getOptions().colors[1]
              }
            },
            min: 50,
            max: 230,
            tickInterval: 40,
            tickLength: 6,
            height: '40%',
            plotBands: [
              {
                from: 0,
                to: 120,
                color: colors.green
              },
              {
                from: 120,
                to: 140,
                color: colors.yellow
              },
              {
                from: 140,
                to: 160,
                color: colors.orange
              },
              {
                from: 160,
                to: 180,
                color: colors.pink
              },
              {
                from: 180,
                to: 250,
                color: colors.red
              }
            ]
          },
          {
            title: {
              text: 'Diastolic',
              style: {
                'color': Highcharts.getOptions().colors[1]
              }
            },
            min:35,
            max: 135,
            tickInterval: 25,
            tickLength: 6,
            top: '60%',
            height: '40%',
            opposite: true,
            plotBands: [
              {
                from: 0,
                to: 80,
                color: colors.green,
                innerRadius: '94%'
              },
              {
                from: 80,
                to: 90,
                color: colors.yellow,
                innerRadius: '94%'
              },
              {
                from: 90,
                to: 100,
                color: colors.orange,
                innerRadius: '94%'
              },
              {
                from: 100,
                to: 110,
                color: colors.pink,
                innerRadius: '94%'
              },
              {
                from: 110,
                to: 150,
                color: colors.red,
                innerRadius: '94%'
              }
            ]
          }
        ],

        tooltip: {
          crosshairs: true,
          shared: true,
          valueSuffix: ' mm Hg',
          xDateFormat: '%m-%d-%Y',
          pointFormat: '{series.name}: <b>{point.y}</b><span style="padding-left: 5px;">  Source: {point.source}<br/>'
        },

        series: [
          {
            name: 'Systolic',
            data: systolics,
            zIndex: 1,
            yAxis: 0,
            marker: {
              fillColor: 'black',
              lineWidth: 2,
              lineColor: Highcharts.getOptions().colors[1]
            }
          },
          {
            name: 'Diastolic',
            data: diastolics,
            zIndex: 1,
            yAxis: 1,
            marker: {
              fillColor: 'white',
              lineWidth: 2,
              lineColor: Highcharts.getOptions().colors[1]
            }
          }
        ]
      };
    }

    function parsePoints(points, targetArray) {
      _.forEach(points, function(point) {
        var date = new Date(point.date).getTime();
        targetArray.push({
          x: date,
          y: parseInt(point.value, 10),
          source: point.source
        });
      });
    }

    $scope.$watchGroup(['data', 'data2'], function(newValues, oldValues) {
      var systolics = [], diastolics = [];
      if (newValues && newValues.length === 2) {
        parsePoints(newValues[0], systolics);
        parsePoints(newValues[1], diastolics);

        systolics.sort($scope.compareDates);
        diastolics.sort($scope.compareDates);
        if ($scope.chart) {
          $scope.chart.series[0].setData(systolics, false);
          $scope.chart.series[1].setData(diastolics, false);
          $scope.chart.redraw();
        }
        else {
          $scope.createChart(createOptions(systolics, diastolics));
        }
      }
      else if ($scope.chart) {
        $scope.chart.series[1].setData([], false);
        $scope.chart.series[0].setData([], false);
        $scope.chart.redraw();
      }
    });
  }

})();
