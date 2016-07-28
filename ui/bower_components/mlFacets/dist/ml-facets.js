(function () {

  'use strict';

  var template =
    '<div class="facet-list">\n' +
      '<div class="chiclets">\n' +
        '<div class="btn btn-primary" ng-repeat="chiclet in selected">\n' +
          '<span>{{chiclet.facet}}: {{chiclet.value}}</span>\n' +
          '<span class="glyphicon glyphicon-remove-circle icon-white" ng-click="clear(chiclet)"></span>\n' +
        '</div>\n' +
      '</div>\n' +
      '<div class="facet" ng-repeat="(name, facet) in facets">\n' +
        '<h3>{{ name }}</h3>\n' +
        '<div ng-repeat="value in facet.facetValues">\n' +
          '<a ng-click="select({facet: name, value: value.name})">{{value.name}} ({{value.count}})</a>\n' +
        '</div>\n' +
      '</div>\n' +
    '</div> ';

  angular.module('mlFacets', [])
    .directive('mlFacets', [function () {
      return {
        restrict: 'AE',
        replace: true,
        scope: {
          facets: '=facetList',
          selected: '=selected',
          select: '&select',
          clear: '&clear'
        },
        template: template,
        link: function() {
        }
      };
    }]);
}());
