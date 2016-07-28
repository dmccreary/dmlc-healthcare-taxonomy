(function () {

  'use strict';

  angular.module('app')
    .filter('object2Array', Object2Array)
    .filter('capitalize', Capitalize)
    .filter('phone', PhoneFilter)
    .filter('numeric', NumericFilter)
    .directive('tooltip', TooltipDirective);

    function Object2Array() {

      return function(input) {
        var out = [];
        for (var name in input) {
          input[name].__key = name;
          out.push(input[name]);
        }
        return out;
      };
    }

    function Capitalize() {
      return function(input) {
        if (input) {
          input = input[0].toUpperCase() + input.substr(1);
        }
        return input;
      };
    }

    var PHONEREG = /[^\d]/g;
    // I thought this would be the most flexible way.  Here's a fiddle http://jsfiddle.net/kuo4dhbr/
    // feel free to refactor if there's a better way to handle it
    function PhoneFilter() {
      return function(input) {
        input = (input + '').replace(PHONEREG,''); // strip any non-numbers
        var format = '', len = input.length, next;
        while (len--) { // go backwards
          next = input[len];
          switch (format.length) {
            case 4: format = next + '-' + format; break;
            case 8: format = next + ') ' + format; break;
            case 12: format = '(' + next + format; break;
            case 14: format = next + ' ' + format; break;
            default: format = next + format;
          }
        }
        if (format.length > 14) {
          format = '+' + format;
        }
        return format;
      };
    }

    function NumericFilter() {
      return function(input) {
        var str = ''+input, len = str.length, chars = len, result = [];
        if (len && !isNaN(input)) {
          while(len--) {
            if (result.length && (chars-len-1)%3===0) { // use the difference between input length and current place to count characters
              result.unshift(',');
            }
            result.unshift(str[len]);
          }
          input = result.join('');
        }
        return input;
      };
    }

    function TooltipDirective() {
      return {
        restrict: 'E',
        replace: true,
        transclude: true,
        link: function(scope,element,attr) {
          element = angular.element(element);
          element.parent().css('position','relative').on('mouseover', function() {
            element.addClass('shown');
          }).on('mouseleave', function() {
            element.removeClass('shown');
          });
        },
        template: '<div class="ml-tooltip" ng-transclude></div>'
      };
    }

})();
