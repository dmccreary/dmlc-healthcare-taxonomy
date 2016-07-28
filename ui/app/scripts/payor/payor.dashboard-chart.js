(function () {

  'use strict';

  angular
    .module('app')
    .controller('DashChartCtrl', DashChartCtrl);

  DashChartCtrl.$inject = ['$scope'];
  function DashChartCtrl($scope) {

    var ctrl = this;
    ctrl.title = 'Data Sources';

    function createOptions(series, categories) {
      return {
        chart: {
          type: 'column'
        },

        title: {
          text: ''
        },

        xAxis: {
          categories: categories,
          labels: {
            // rotation: -45,
            style: {
              fontSize: '10px',
              fontFamily: 'Verdana, sans-serif'
            }
          }
        },

        yAxis: {
          min: 0,
          title: {
            text: 'Frequency'
          }
        },

        tooltip: {
          crosshairs: true,
          shared: false,
          useHTML: true,
          headerFormat: '<span class="name">{point.key}</span><br/>',
          pointFormat: '<b style="margin-top: 2px">{point.y} {point.format}</b><br/><p>{point.desc}</p>'
        },

        series: series
      };
    }

    $scope.$watch('data', function(newValue, oldValue) {
      var tuples;
      if (newValue) {
        tuples = newValue;
        var categoryDefs = [];
        var seriesDefs = [];
        var lookup = {};
        _.each(tuples, function(tuple) {
          var series = tuple['distinct-value'][0]._value;
          var category = tuple['distinct-value'][1]._value;
          categoryDefs.push(category);
          seriesDefs.push(series);
          lookup[series + ':' + category] = tuple.frequency;
        });

        categoryDefs = _.uniq(categoryDefs);
        seriesDefs = _.uniq(seriesDefs);
        var series = [];
        _.each(seriesDefs, function(seriesDef) {
          var data = [];
          _.each(categoryDefs, function(category) {
            data.push(lookup[seriesDef + ':' + category] || 0);
          });
          series.push({
            name: seriesDef,
            data: data
          });
        });

        if ($scope.chart) {
          while($scope.chart.series.length > 0) {
            $scope.chart.series[0].remove(false);
          }

          for (var i = 0; i < series.length; i++) {
            $scope.chart.addSeries(series[i], false);
          }
          $scope.chart.redraw();
        }
        else {
          $scope.createChart(createOptions(series, categoryDefs));
        }
      }
      else if ($scope.chart) {
        $scope.chart.series[0].setData([], true);
      }
    });
  }

})();

