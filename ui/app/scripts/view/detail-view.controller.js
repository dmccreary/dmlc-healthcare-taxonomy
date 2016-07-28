(function () {
  'use strict';

  angular.module('app')
    .controller('DetailViewCtrl', DetailViewCtrl);

    function DetailViewCtrl(doc, uri) {
      var ctrl = this;
      angular.extend(ctrl, {
        doc: doc,
        uri: uri
      });
    }

}());
