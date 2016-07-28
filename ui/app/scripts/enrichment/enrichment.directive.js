(function () {

  'use strict';

  angular
    .module('app')
    .directive('enriched', EnrichedContentDirective)
    .directive('enrichedLegend', EnrichedLegendDirective)
    .controller('enrichedContentController', EnrichedContentController);

  function EnrichedContentDirective($sce, $compile) {
    function highlightClass(type) {
      var t = type.toLowerCase().replace(/[^\w]+/g, '-');
      t = t.replace(/[_]/, '-');
      return t.replace(/medicine-([^-]+)-([^-]+)/, 'medicine-$2');
    }

    function getTitle(item) {
      if (item.children) {
        return 'Mixed';
      }

      return item.type;
    }

    function getText(item) {
      var txt = item.text;
      if (item.children) {
        txt += _.map(item.children, function(child) {
          return getText(child);
        }).join(' ');
      }
      return txt;
    }
    return {
      restrict: 'E',
      scope: {
        content: '='
      },
      replace: true,
      template: '<p class="marked-up"></p>',
      controller: 'enrichedContentController',
      controllerAs: 'ecc',
      link: function($scope, element, attr) {

        var types = {};

        _.each($scope.content, function(item, index) {
          if (_.isString(item)) {
            element.append('<span>' + item + '</span>');
          }
          else {
            var hc = highlightClass(item.type);
            var newE = $('<span popover-html="{{ecc.getPopOverBody(content[' + index + '])}}" popover-title="' + getTitle(item) + '" class="highlight ' + hc + '">' + getText(item) + '</span>');
            element.append(newE);
            types[hc] = {
              title: item.type,
              cls: hc
            };
          }
        });

        $scope.types = types;

        if (attr.showLegend === 'true') {
          var legend = $('<enriched-legend types="types"></enriched-legend>');
          element.prepend(legend);
        }
        $compile(element.contents())($scope);
      }
    };
  }

  function EnrichedLegendDirective() {
    return {
      restrict: 'E',
      scope: {
        types: '='
      },
      replace: false,
      template: [
        '<div class="panel panel-default legend">',
          '<div class="panel-heading">Legend</div>',
          '<ul class="list-group">',
            '<li ng-repeat="type in types" class="list-group-item" ng-class="type.cls"><span class="title">{{type.title}}</span></li>',
          '</ul>',
        '</div>'
      ].join(''),
      link: LinkFunc
    };

    function LinkFunc($scope, element, attr) {

    }
  }

  function EnrichedContentController($sce) {
    var ctrl = this;
    angular.extend(ctrl, {
      getPopOverBody: getPopOverBody
    });

    function getPopOverBody(item) {
      var result;
      if (item.type === 'Medicine' || item.type === 'DRUG') {
        result = [
          '<span>Medication:</span> ',
          '<strong>',
          item.text,
          '</strong>',
          '<div>',
          '<a style="cursor:pointer;" data-drug="' + item.text + '">Product label</a>',
          '</div>'
        ].join('');
      }
      else {
        var parts = [];
        _.each(item, function(v, k) {
          parts.push('<div><strong>' + k + ':</strong> <span>' + v + '</span></div>');
        });
        result = parts.join('');
      }
      return $sce.trustAsHtml(result);
    }
  }

})();
