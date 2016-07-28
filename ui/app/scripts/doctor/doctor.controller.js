(function () {
  'use strict';

  angular.module('app')
    .controller('DoctorCtrl', DoctorCtrl);

    DoctorCtrl.$inject = ['$scope', '$location', 'MLSearchFactory', 'MLRest'];

    // inherit from MLSearchController
    var superCtrl = MLSearchController.prototype;
    DoctorCtrl.prototype = Object.create(superCtrl);

    function DoctorCtrl($scope, $location, searchFactory, mlRest) {
      var ctrl = this;
      var mlSearch = searchFactory.newContext({
        queryOptions: 'patients'
      }).setTransform('search-results');

      superCtrl.constructor.call(ctrl, $scope, $location, mlSearch);

      angular.extend(ctrl, {
        // TODO: remove when ml-search-ng is updated
        mlRest: mlRest,
        // override superCtrl method
        updateSearchResults: updateSearchResults,
        _search: _search,
        reset: reset,

        currentPolygon: null,
        mapOptions: {
          zoom: 8,
          minZoom: 2,
          center: new google.maps.LatLng(0, 0),
          mapTypeControl: false,
          streetViewControl: false,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        },
        markers: []
      });

      ctrl.init();

      function addGeoQuery() {
        if (ctrl.currentPolygon) {
          var query = {
            'geo-attr-pair-query': {
              'parent': {
                'name': 'addr',
                'ns': 'urn:hl7-org:v3'
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
        addGeoQuery();
        superCtrl._search.call(ctrl);
        fetchMarkers();
      }

      function reset() {
        ctrl.currentPolygon = null;
        superCtrl.reset.apply(ctrl);
      }

      // override superCtrl method
      function updateSearchResults(data) {
        superCtrl.updateSearchResults.apply(ctrl, arguments);

        _.forEach(ctrl.response.results, function(result) {
          // var json = JSON.parse(result.content);
          _.forEach(result.content, function(value, key) {
            result[key] = value;
          });
        });
      }

      function fetchMarkers() {
        var query = mlSearch.getQuery();
        var valueOptions = {
          format: 'json',
          options: 'patients',
          limit: '250'
        };
        mlRest.values('points', valueOptions, query).then(updateMarkers);
      }

      // function getSafeInt(strIn) {
      //   try {
      //     var ival = parseInt(strIn);
      //     return isNaN(ival) ? 0 : ival;
      //   }
      //   catch (e) {
      //     return 0;
      //   }
      // }

      function infoWindow(uri) {
        return mlRest.getDocument(uri, {transform: 'patient-json'}).then(function(resp) {
          var info = resp.data;
          return [
            '<div class="info-title"><a href="/physician/patients' + uri + '" target="details">' + info.name + '</a></div>',
            '<div class="info-street">' + info.address.streetAddressLine + '</div>',
            '<div>' + info.address.city + ' ' + info.address.state + ' ' + info.address.postalCode + '</div>'
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
              //   return mlRest.getDocument(uri, {transform: 'patient-json'}).then(function(resp) {
              //     var info = resp.data;
              //     return [
              //       '<div class="info-title"><a href="/physician/patients' + uri + '" target="details">' + info.name + '</a></div>',
              //       '<div class="info-street">' + info.address.streetAddressLine + '</div>',
              //       '<div>' + info.address.city + ' ' + info.address.state + ' ' + info.address.postalCode + '</div>'
              //     ].join('\n');
              //   });
              // }
            });
          }
        });
      }
    }

}());
