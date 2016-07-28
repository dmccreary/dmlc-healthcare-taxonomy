(function () {

  'use strict';

  angular
    .module('app')
    .directive('newsResult', NewsResult);

  function NewsResult() {

    function _convertToOriginalPDFUri(uri) {
      return uri.replace('_pdf.xhtml', '.pdf');
    }

    function getUri(literature) {
      return '/v1/documents?uri=' + _convertToOriginalPDFUri(literature.uri);
    }

    function getTitle(literature) {
      return _convertToOriginalPDFUri(literature.uri);
    }

    return {
      restrict: 'E',
      replace: true,
      transcribe: true,
      templateUrl: '/views/search-results/news-result.html',
      scope: {
        news: '='
      },
      link: function(scope) {
        scope.getUri = getUri;
        scope.getTitle = getTitle;
      }
    };
  }

})();
