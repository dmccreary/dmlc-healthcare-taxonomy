(function () {

  'use strict';

  angular.module('ml.search', ['ml.common'])
    .filter('object2Array', object2Array)
    .filter('truncate', truncate);

  function object2Array() {
    return function(input) {
      var out = [];
      for (var name in input) {
        input[name].__key = name;
        out.push(input[name]);
      }
      return out;
    };
  }

  function truncate() {
    return function (text, length, end) {
      length = length || 10;
      // if (isNaN(length)) {
      //   length = 10;
      // }

      end = end || '...';
      // if (end === undefined) {
      //   end = '...';
      // }

      if (text.length <= length || text.length - end.length <= length) {
        return text;
      }
      else {
        return String(text).substring(0, length - end.length) + end;
      }

    };
  }

}());
