(function () {
  'use strict';

  angular.module('app')
    .controller('ProviderSearchCtrl', ProviderSearchCtrl);

    ProviderSearchCtrl.$inject = ['$scope', '$location', '$http', 'MLSearchFactory', 'MLRest'];

    // inherit from MLSearchController
    var superCtrl = MLSearchController.prototype;
    ProviderSearchCtrl.prototype = Object.create(superCtrl);

    function ProviderSearchCtrl($scope, $location, $http, searchFactory, mlRest) {
      var ctrl = this;
      var mlSearch = searchFactory.newContext({
        queryOptions: 'providers'
      }).setTransform('search-results');

      superCtrl.constructor.call(ctrl, $scope, $location, mlSearch);

      ctrl.mapOptions = {
        zoom: 8,
        minZoom: 2,
        center: new google.maps.LatLng('40.7903', '-73.9597'),
        mapTypeControl: false,
        streetViewControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };

      angular.extend(ctrl, {
        currentPolygon: null,
        // TODO: remove when ml-search-ng is updated
        mlRest: mlRest,
        // override superCtrl methods
        _search: _search,
        // implement superCtrl extension methods
        parseExtraURLParams: parseExtraURLParams,
        updateExtraURLParams: updateExtraURLParams,

        reset: reset,
        suggest: suggest,
        search: search,

        qzip: null,
        qradius: null,
        qsemantic: true,
        refreshMap: refreshMap
      });

      ctrl.init();

      function addGeoQuery() {
        if (ctrl.currentPolygon) {
          var query = {
            'geo-attr-pair-query': {
              'parent': {
                'name': 'address',
                'ns': 'http://marklogic.com/cms'
              },
              'lat': {
                'name': 'lat',
                'ns': null
              },
              'lon': {
                'name': 'lng',
                'ns': null
              }
            }
          };
          query['geo-attr-pair-query'][ctrl.currentPolygon.type] = [ctrl.currentPolygon.bounds];
          mlSearch.addAdditionalQuery(query);
        }
      }

      // override superCtrl method
      function _search() {
        mlSearch.clearAdditionalQueries(); // no way to remove the geo directly?
        addRadiusQuery();
        addGeoQuery();
        superCtrl._search.call(ctrl);
        fetchMarkers();
      }

      function suggest(val) {
        if (!ctrl.qsemantic) {
          //return superCtrl.suggest.call(ctrl, val);
          return mlSearch.suggest(val).then(function(res) {
            var existingSuggestions = [];

            res.suggestions.forEach(function(key) {
              existingSuggestions.push({
                'concept': 'Default',
                'synonym': key
              });
            });

            return existingSuggestions;
          });
        } else {
          // Merge the suggests from the existing system with 
          // the suggests from the taxonomy.
          return mlSearch.suggest(val).then(function(res) {
            var existingSuggestions = [];

            res.suggestions.forEach(function(key) {
              existingSuggestions.push({
                'concept': 'Default',
                'show': false,
                'synonym': key
              });
            });

            var url = '/taxonomy/suggest?term=' + val;

            return $http.get(url).then(function(response) {
              var suggests = [];

              if (response.data.suggests) {
                response.data.suggests.forEach(function(itm) {
                  //suggests.push(itm.suggest);
                  suggests.push({
                    'concept': itm.concept,
                    'show': true,
                    'synonym': itm.suggest
                  });
                });
              }

              return suggests.concat(existingSuggestions);
            }, function(response) {
              return existingSuggestions;
            });
          });
        }
      }

      function search(qtext) {
        if (!ctrl.qsemantic) {
          return superCtrl.search.call(ctrl, qtext);
        } else {
          if ( arguments.length ) {
            var url = '/taxonomy/narrator?term=' + qtext;
            $http.get(url).then(function(response) {
              //console.log(JSON.stringify(response.data, null, 4));
              var synonyms = [];

              if (response.data.synonyms) {
                response.data.synonyms.forEach(function(itm) {
                  synonyms.push(itm.synonym);
                });
              }

              if (synonyms.length === 0) {
                ctrl.qtext = qtext;
              } else {
                ctrl.qtext = synonyms.join(' OR ');
              }

              executeEearch();
            }, function(response) {
              ctrl.qtext = qtext;
              executeEearch();
            });
          } else {
            executeEearch();
          }
        }
      }

      function executeEearch() {
        ctrl.mlSearch.setText( ctrl.qtext ).setPage( ctrl.page );
        return ctrl._search();
      }

      // implement superCtrl extension method
      function parseExtraURLParams() {
        var params = _.pick( $location.search(), 'qzip', 'qradius' );
        var hasChanged = ctrl.qzip !== params.qzip ||
                         ctrl.qradius !== params.qradius;

        if ( hasChanged ) {
          ctrl.qzip = params.qzip;
          ctrl.qradius = parseInt(params.qradius) || 3000;
        }
        return hasChanged;
      }

      // implement superCtrl extension method
      function updateExtraURLParams() {
        if (ctrl.qzip) {
          $location.search( 'qzip', ctrl.qzip );
          $location.search( 'qradius', ctrl.qradius );
        } else {
          $location.search( 'qzip', null );
          $location.search( 'qradius', null );
        }
      }

      function reset() {
        ctrl.currentPolygon = null;
        superCtrl.reset.apply(ctrl);
      }

      function addRadiusQuery() {
        if (ctrl.qzip) {
          mlSearch.addAdditionalQuery({
          'custom-constraint-query': {
            'constraint-name': 'nearzip',
            'radius': ctrl.qradius || 3000,
            'zip': ctrl.qzip
          }});
        }
      }

      function fetchMarkers() {
        var query = mlSearch.getQuery();
        var valueOptions = {
          format: 'json',
          options: 'providers',
          limit: '250'
        };
        mlRest.values('points', valueOptions, query).then(updateMarkers);
      }

      function infoWindow(uri) {
        return mlRest.getDocument(uri, {transform: 'provider-json'}).then(function(resp) {
          var info = resp.data;
          return [
            '<div class="info-title"><a href="/patient/providers' + uri + '" target="details">' + (info.name || info.org) + '</a></div>',
            '<div class="info-street">' + info.address['addr-line1'] + '</div>',
            '<div>' + info.address.city + ' ' + info.address.state + ' ' + info.address.zip5 + '</div>'
          ].join('\n');
        });
      }

      function updateMarkers(resp) {
        ctrl.markers = [];
        angular.forEach(resp.data['values-response'].tuple, function(tuple) {
          if (tuple && tuple['distinct-value']) {
            var uri = tuple['distinct-value'][0]._value;

            var latLng = tuple['distinct-value'][1]._value.split(',');
            ctrl.markers.push({
              latitude: latLng[0],
              longitude: latLng[1],
              infoWindow: function() { return infoWindow(uri); }
            });
          }
        });
      }

      function refreshMap() {
        return $location.path() === '/patient/docfind';
      }
    }

}());
