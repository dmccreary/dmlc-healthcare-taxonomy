(function () {

  'use strict';

  angular
    .module('app')
    .controller('SplashCtrl', SplashCtrl);

  SplashCtrl.$inject = ['counts'];
  function SplashCtrl(counts) {
    var ctrl = this;
    angular.extend(ctrl, {
      counts: counts
    });
  }

})();
