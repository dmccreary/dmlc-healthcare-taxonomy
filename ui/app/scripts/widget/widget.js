(function () {

  'use strict';

  angular
    .module('app')
    .directive('widget', WidgetDirective)
    .controller('WidgetCtrl', WidgetCtrl)
    .directive('collapsibleSection', CollapsibleSectionDirective);

  function WidgetDirective() {
    return {
      restrict: 'A',
      scope: {
        widget: '=',
        constraints: '=',
        suggest: '=',
        removeWidget: '&'
      },
      controller: 'WidgetCtrl',
      templateUrl: '/views/widget/widget.html',
      link: function(scope, ele) {
        if (scope.widget.dimensions.length < 2) {
          scope.editing = true;
        }
        scope.$watch('widget.size', function(newValue, oldValue) {
          if (newValue && newValue === 'Full') {
            ele.removeClass('col-xs-6').addClass('col-xs-12');
          }
          else {
            ele.removeClass('col-xs-12').addClass('col-xs-6');
          }
        });
      }
    };
  }

  function WidgetCtrl($scope, payorService) {
    var model = {
      sizes: ['Full', 'Half'],
      resultLimit: 100,
      outputTypes: ['Table', 'Chart', 'Map'],
      mapOptions: {
        zoom: 8,
        minZoom: 4,
        center: new google.maps.LatLng('40.7903', '-73.9597'),
        mapTypeControl: false,
        streetViewControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      }
    };

    var originalConstraints = _.map($scope.constraints, function(constraint) {
      return _.omit(constraint, ['prettyName', 'extraPrettyName']);
    });

    _.each($scope.constraints, function(constraint) {
      constraint.prettyName = constraint.name.replace(/_/g, ' ');
      constraint.extraPrettyName = constraint.name.replace(/All_|Provider_|Patient_|Claim_/, '').replace(/_/g, ' ');
    });

    angular.extend($scope, {
      addDimension: addDimension,
      removeDimension: removeDimension,
      addConstraint: addConstraint,
      removeConstraint: removeConstraint,
      updateOutput: updateOutput,
      selectDimension: selectDimension,
      selectConstraint: selectConstraint,
      onSelectConstraint: onSelectConstraint,
      model: model,
      editing: false
    });

    function addDimension() {
      $scope.widget.dimensions.push({});
    }

    function removeDimension(idx) {
      $scope.widget.dimensions.splice(idx, 1);
      updateOutput();
    }

    function addConstraint() {
      $scope.widget.activeConstraints.push({});
    }

    function removeConstraint(idx) {
      $scope.widget.activeConstraints.splice(idx, 1);
      updateOutput();
    }

    function updateOutput() {
      if ($scope.widget.dimensions.length > 1) {
        var w = $scope.widget;
        payorService.getTuples(w.dimensions, originalConstraints, w.activeConstraints, w.query, w.resultLimit).then(function(resp) {
          model.tuples = resp['values-response'].tuple;
          updateMarkers();
        });
      }
      else {
        model.tuples = [];
      }
    }

    function updateMarkers() {
      var markers = [];
      _.each(model.tuples, function(tuple) {
        var marker = {};
        var infoTxt = '';
        for (var i = 0; i < $scope.widget.dimensions.length; i++) {
          var dimension = $scope.widget.dimensions[i];
          if (tuple['distinct-value'][i]._value.match(/[-\d.]+,[-\d.]+/)) {
            var splits = tuple['distinct-value'][i]._value.split(',');
            marker.latitude = Number(splits[0]);
            marker.longitude = Number(splits[1]);
          }
          else {
            infoTxt += '<div><span class="key">' + dimension.name + ':</span><span class="value">' + tuple['distinct-value'][i]._value + '</span></div>';
          }
        }

        marker.infoWindow = infoTxt;

        markers.push(marker);
      });

      model.markers = markers;
    }

    function selectDimension(index, constraint) {
      $scope.widget.dimensions[index] = constraint;
      updateOutput();
    }

    function selectConstraint(index, constraint) {
      $scope.widget.activeConstraints[index].constraint = constraint;
      updateOutput();
    }

    function onSelectConstraint($item, $model, $label) {
      updateOutput();
    }

    updateOutput();
  }

  function CollapsibleSectionDirective() {
    return {
      restrict: 'E',
      scope: {
        title: '@'
      },
      transclude: true,
      template: [
        '<div ng-click="collapsed=!collapsed" class="title">{{title}}&nbsp;<i class="fa" ng-class="{true: \'fa-caret-left\', false: \'fa-caret-down\'}[collapsed]"></i></div>',
        '<div ng-show="!collapsed"><ng-transclude/></div>'
      ].join(''),
      link: function(scope) {
        scope.collapsed = false;
      }
    };
  }

})();
