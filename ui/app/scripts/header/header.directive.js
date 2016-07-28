(function () {

  'use strict';

  angular
    .module('app')
    .directive('header', Header);


  function Header() {
    return {
      restrict: 'E',
      replace: true,
      transcribe: true,
      controller: 'HeaderCtrl as ctrl',
      templateUrl: '/views/header/header.html'
    };
  }

})();
