function MLSearchController($scope, $location, mlSearch) {
  'use strict';
  if ( !(this instanceof MLSearchController) ) {
    return new MLSearchController($scope, $location, mlSearch);
  }

  // TODO: error if not passed
  this.$scope = $scope;
  this.$location = $location;
  this.mlSearch = mlSearch;

  this.searchPending = false;
  this.page = 1;
  this.qtext = '';
  this.response = {};
}

(function() {
  'use strict';

  MLSearchController.prototype.init = function init() {
    // monitor URL params changes (forward/back, etc.)
    this.$scope.$on('$locationChangeSuccess', this.locationChange.bind(this));

    // capture initial URL params in mlSearch and ctrl
    if ( this.parseExtraURLParams ) {
      this.parseExtraURLParams();
    }

    return this.mlSearch.fromParams()
      .then( this._search.bind(this) );
  };

  MLSearchController.prototype.locationChange = function locationChange(e, newUrl, oldUrl){
    var self = this,
        shouldUpdate = false;

    if ( this.parseExtraURLParams ) {
      shouldUpdate = this.parseExtraURLParams();
    }

    return this.mlSearch.locationChange( newUrl, oldUrl )
      .then(
        this._search.bind(this),
        function() {
          if (shouldUpdate) {
            self._search.call(self);
          }
        }
      );
  };

  MLSearchController.prototype._search = function _search() {
    this.searchPending = true;

    var promise = this.mlSearch.search()
      .then( this.updateSearchResults.bind(this) );

    this.updateURLParams();
    return promise;
  };

  MLSearchController.prototype.updateSearchResults = function updateSearchResults(data) {
    this.searchPending = false;
    this.response = data;
    this.qtext = this.mlSearch.getText();
    this.page = this.mlSearch.getPage();
    return this;
  };

  MLSearchController.prototype.updateURLParams = function updateURLParams() {
    var params = _.chain( this.$location.search() )
      .omit( this.mlSearch.getParamsKeys() )
      .merge( this.mlSearch.getParams() )
      .value();

    this.$location.search( params );

    if ( this.updateExtraURLParams ) {
      this.updateExtraURLParams();
    }
    return this;
  };

  MLSearchController.prototype.search = function search(qtext) {
    if ( arguments.length ) {
      this.qtext = qtext;
    }

    this.mlSearch.setText( this.qtext ).setPage( this.page );
    return this._search();
  };

  MLSearchController.prototype.reset = function reset() {
    this.mlSearch
      .clearAllFacets()
      .clearAdditionalQueries()
      .clearBoostQueries();
    this.qtext = '';
    this.page = 1;
    return this.search();
  };

  MLSearchController.prototype.toggleFacet = function toggleFacet(facetName, value) {
    this.mlSearch.toggleFacet( facetName, value );
    return this._search();
  };

  MLSearchController.prototype.showMoreFacets = function showMoreFacets(facet, facetName) {
    // TODO: update ml-search-ng
    // return mlSearch.showMoreFacets(facet, facetName);

    var self = this;

    var optionsName = self.mlSearch.getQueryOptions();

    self.mlRest.queryConfig(optionsName, 'constraint').then(function(resp) {
      var options = resp.data.options.constraint;

      var myOption = options.filter(function (option) {
        return option.name === facetName;
      })[0];

      var searchOptions = self.mlSearch.getQuery();

      searchOptions.options = {};
      searchOptions.options.constraint = _.cloneDeep(options);
      myOption['values-option'] = 'frequency-order';
      searchOptions.options.values = myOption;

      var searchConfig = {
        search: searchOptions
      };

      var start = facet.facetValues.length + 1;
      var limit = start + 5;

      self.mlRest.values(facetName, {start: start, limit: limit, options: optionsName}, searchConfig).then(function(resp) {
        var newFacets = resp.data['values-response']['distinct-value'];
        if (!newFacets || newFacets.length < (limit - start)) {
          facet.displayingAll = true;
        }

        _.each(newFacets, function(newFacetValue) {
          var newFacet = {};
          newFacet.name = newFacetValue._value;
          newFacet.value = newFacetValue._value;
          newFacet.count = newFacetValue.frequency;
          facet.facetValues.push(newFacet);
        });
      });

    });
  };

  MLSearchController.prototype.clearFacets = function clearFacets() {
    this.mlSearch.clearAllFacets();
    return this._search();
  };

  MLSearchController.prototype.suggest = function suggest(val) {
    return this.mlSearch.suggest(val).then(function(res) {
      return res.suggestions || [];
    });
  };

})();
