(function () {

  'use strict';

  angular
    .module('app')
    .directive('payorDash', PayorDashDirective)
    .controller('PayorDashCtrl', PayorDashCtrl);


  function PayorDashDirective() {
    return {
      restrict: 'EA',
      replace: false,
      scope: {
        constraints: '='
      },
      templateUrl: '/views/payor/payor-dashboard.html',
      controller: 'PayorDashCtrl',
      controllerAs: 'payorDashCtrl'
    };
  }

  function PayorDashCtrl(payorService, $scope, MLRest) {

    angular.extend($scope, {
      addWidget: addWidget,
      removeWidget: removeWidget,
      saveWidgets: saveWidgets,
      suggest: suggest,
      widgets: []
    });

    function addWidget() {
      $scope.widgets.push({
        dimensions: [],
        activeConstraints: [],
        size: 'Full',
        outputType: 'Table',
        resultLimit: 100
      });
    }

    function removeWidget(idx) {
      $scope.widgets.splice(idx, 1);
    }

    function saveWidgets() {
      MLRest.updateDocument($scope.widgets, {
        uri: '/widgets/widget.json',
        collection: 'widgets'
      });
    }

    MLRest.getDocument('/widgets/widget.json').then(function(resp) {
      var widgets = resp.data || [];

      _.each(widgets, function(widget) {
        widget.dimensions = _.map(widget.dimensions, function(dimension) {
          return _.find($scope.constraints, function(constraint) { return constraint.name === dimension.name; });
        });
      });

      $scope.widgets = widgets;
    });

    function suggest(constraint, val) {
      var params = {
        format: 'json',
        'partial-q': val
      };

      var combined = {
        search: {
          query: {
            'and-query': []
          },
          options: {
            constraint: [_.omit(constraint, ['prettyName', 'extraPrettyName'])],
            'suggestion-source': [{
              ref: constraint.name,
              'suggestion-option': [
                'frequency-order',
                'descending'
              ]
            }],
            'default-suggestion-source': {
              ref: constraint.name
            }
          }
        }
      };
      return MLRest.suggest(params, combined).then(function(res) {
        return res.data.suggestions || [];
      });
    }
  }

})();
