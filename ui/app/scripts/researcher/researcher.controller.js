(function () {
  'use strict';

  angular.module('app')
    .controller('ResearcherCtrl', ResearcherCtrl);

    ResearcherCtrl.$inject = ['$scope', '$location', 'MLSearchFactory', 'MLRest', '$modal', 'savedSearches'];

    // inherit from MLSearchController
    var superCtrl = MLSearchController.prototype;
    ResearcherCtrl.prototype = Object.create(superCtrl);

    function ResearcherCtrl($scope, $location, searchFactory, mlRest, $modal, savedSearches) {
      var ctrl = this;
      var mlSearch = searchFactory.newContext({
        queryOptions: 'faers'
      }).setTransform('search-results');

      superCtrl.constructor.call(ctrl, $scope, $location, mlSearch);

      angular.extend(ctrl, {
        // TODO: remove when ml-search-ng is updated
        mlRest: mlRest,
        // override superCtrl methods
        _search: _search,
        updateSearchResults: updateSearchResults,
        reset: reset,
        // implement superCtrl extension methods
        parseExtraURLParams: parseExtraURLParams,
        updateExtraURLParams: updateExtraURLParams,

        savedSearches: savedSearches,
        saveSearch: saveSearch,
        runSearch: runSearch,
        deleteSearch: deleteSearch,
        addAdditionalDrugs: addAdditionalDrugs
      });

      ctrl.init();

      // override superCtrl method
      function _search() {
        ctrl.searchPending = true;
        var timestamp = Date.now();
        ctrl.currentSearchTimestamp = timestamp;
        addAdditionalDrugs().then(function() {
          mlSearch.search().then( ctrl.updateSearchResults.bind(ctrl, timestamp) );
        });
        ctrl.updateURLParams();
      }

      // override superCtrl method
      function updateSearchResults(timestamp, data) {
        if ( timestamp && !data ) {
          data = timestamp;
          timestamp = null;
        }

        if ( timestamp !== ctrl.currentSearchTimestamp ) {
          return console.log('timestamp mismatch');
        }

        superCtrl.updateSearchResults.call(ctrl, data);

        var expanded = mlSearch.getExpandedQtext();
        if (expanded !== ctrl.qtext) {
          ctrl.expandedQtext = expanded;
        } else {
          ctrl.expandedQtext = undefined;
        }
      }

      function reset() {
        $scope.shouldResolveBrands = false;
        $scope.shouldResolveDrugClasses = false;
        superCtrl.reset.call(ctrl);
      }
      // implement superCtrl extension method
      function parseExtraURLParams() {
        var params = _.pick( $location.search(), 'brands', 'drugClass' );
        /*jshint -W018 */
        var hasChanged = $scope.shouldResolveBrands !== !!params.brands ||
                         $scope.shouldResolveDrugClasses !== !!params.drugClass;

        if ( hasChanged ) {
          $scope.shouldResolveBrands = !!params.brands;
          $scope.shouldResolveDrugClasses = !!params.drugClass;
        }

        return hasChanged;
      }

      // implement superCtrl extension method
      function updateExtraURLParams() {
        $location.search( 'brands', $scope.shouldResolveBrands ? true : null );
        $location.search( 'drugClass', $scope.shouldResolveDrugClasses ? true : null );
      }

      function addAdditionalDrugs() {
        mlSearch.clearAdditionalQtext();
        var params = {
          'rs:qtext': mlSearch.qtext,
          'rs:brands': $scope.shouldResolveBrands,
          'rs:drugClasses': $scope.shouldResolveDrugClasses
        };
        return mlRest.extension('expand-drug', {params: params})
          .then(function(resp) {
            var additional = resp.data.additionalTerms;
            _.each(additional, function(term) {
              mlSearch.addAdditionalQtext('"' + term + '"');
            });
          });
      }

      function saveSearch() {
        var modalInstance = $modal.open({
          templateUrl: '/views/save-search/save-search.html',
          controller: 'SavedSearchCtrl as ctrl',
          size: 'sm',
          resolve: {
            items: function () {
              return $scope.items;
            }
          }
        });

        modalInstance.result.then(function (searchName) {
          ctrl.savedSearches.push({
            name: searchName,
            query: mlSearch.getParams()
          });
          mlRest.updateDocument(ctrl.savedSearches, { uri: '/saved-searches.json' } );
        });
      }

      function runSearch(search) {
        mlSearch.fromParams(search.query).then( ctrl._search.bind(ctrl) );
      }

      function deleteSearch(search) {
        _.remove(ctrl.savedSearches, function(ss) {
          return ss === search;
        });
        mlRest.updateDocument(ctrl.savedSearches, { uri: '/saved-searches.json' } );
      }
    }

}());
