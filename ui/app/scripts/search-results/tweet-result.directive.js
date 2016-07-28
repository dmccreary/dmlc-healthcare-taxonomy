(function () {

  'use strict';

  angular
    .module('app')
    .directive('tweetResult', TweetResult);

  function TweetResult() {
    return {
      restrict: 'E',
      replace: true,
      transcribe: true,
      templateUrl: '/views/search-results/tweet-result.html',
      scope: {
        tweet: '='
      }
    };
  }

})();
