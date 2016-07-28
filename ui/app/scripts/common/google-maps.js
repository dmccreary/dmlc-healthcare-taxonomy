/**!
 * The MIT License
 *
 * Copyright (c) 2010-2012 Google, Inc. http://angularjs.org
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * angular-google-maps
 * https://github.com/nlaplante/angular-google-maps
 *
 * @author Nicolas Laplante https://plus.google.com/108189012221374960701
 */

(function () {

  'use strict';

  /*
   * Utility functions
   */

  /**
   * Check if 2 floating point numbers are equal
   *
   * @see http://stackoverflow.com/a/588014
   */
  function floatEqual (f1, f2) {
    return (Math.abs(f1 - f2) < 0.000001);
  }

  /*
   * Create the model in a self-contained class where map-specific logic is
   * done. This model will be used in the directive.
   */

  var MapModel = (function () {

    var _defaults = {
      zoom: 8,
      container: null,
    };

    /**
     *
     */
    function PrivateMapModel(opts) {

      var _instance = null,
      _markers = [],  // caches the instances of google.maps.Marker
      _handlers = [], // event handlers
      _onceHandlers = [],
      _currentPolygon = null,
      _windows = [],  // InfoWindow objects
      o = angular.extend({}, _defaults, opts),
      that = this,
      currentInfoWindow = null;

      this.center = opts.center;
      this.zoom = o.zoom;
      this.dragging = false;
      this.selector = o.container;
      this.markers = [];
      this.options = o;

      this.draw = function () {

        if (that.center === null) {
          // TODO log error
          return;
        }

        if (_instance === null) {

          // Create a new map instance

          _instance = new google.maps.Map(that.selector, that.options);

          google.maps.event.addListener(_instance, 'dragstart',

              function () {
                that.dragging = true;
              }
          );

          google.maps.event.addListener(_instance, 'idle',

              function () {
                that.dragging = false;
              }
          );

          google.maps.event.addListener(_instance, 'drag',

              function () {
                that.dragging = true;
              }
          );

          google.maps.event.addListener(_instance, 'zoom_changed',

              function () {
                that.zoom = _instance.getZoom();
                that.center = _instance.getCenter();
              }
          );

          google.maps.event.addListener(_instance, 'center_changed',

              function () {
                that.center = _instance.getCenter();
              }
          );

          if (_onceHandlers.length) {
            angular.forEach(_onceHandlers, function(h) {
              google.maps.event.addListenerOnce(_instance, h.on, h.handler);
            });
          }

          // Attach additional event listeners if needed
          if (_handlers.length) {

            angular.forEach(_handlers, function (h) {

              google.maps.event.addListener(_instance,
                  h.on, h.handler);
            });
          }
        }
        else {

          // Refresh the existing instance
          google.maps.event.trigger(_instance, 'resize');

          var instanceCenter = _instance.getCenter();

          if (!floatEqual(instanceCenter.lat(), that.center.lat()) ||
              !floatEqual(instanceCenter.lng(), that.center.lng())) {_instance.setCenter(that.center);
          }

          if (_instance.getZoom() !== that.zoom) {
            _instance.setZoom(that.zoom);
          }
        }
      };

      this.fit = function () {
        if (_instance && _markers.length) {

          var bounds = new google.maps.LatLngBounds();

          angular.forEach(_markers, function (m) {
            bounds.extend(m.getPosition());
          });

          if (_currentPolygon) {
            if (_currentPolygon.getBounds) {
              bounds.union(_currentPolygon.getBounds());
            }
            else if (_currentPolygon.getPath) {
              _currentPolygon.getPath().forEach(function(e) {
                bounds.extend(e);
              });
            }
          }

          _instance.fitBounds(bounds);
          _instance.panToBounds(bounds);
        }
      };

      this.on = function(event, handler) {
        _handlers.push({
          'on': event,
          'handler': handler
        });
      };

      this.once = function(event, handler) {
        _onceHandlers.push({
          on: event,
          handler: handler
        });
      };

      this.getMap = function() {
        return _instance;
      };

      this.currentPolygon = function() {
        return _currentPolygon;
      };

      this.setCurrentPolygon = function(p) {
        _currentPolygon = p;
      };

      this.addMarker = function (lat, lng, icon, infoWindowContent, label, url,
          thumbnail) {

        if (that.findMarker(lat, lng) !== null) {
          return;
        }

        var marker = new google.maps.Marker({
          position: new google.maps.LatLng(lat, lng),
          map: _instance,
          icon: icon
        });

        if (label) {

        }

        if (url) {

        }

        function showInfoWindow(content) {
          var infoWindow = new google.maps.InfoWindow({
            content: content
          });

          if (currentInfoWindow !== null) {
            currentInfoWindow.close();
          }
          infoWindow.open(_instance, marker);
          currentInfoWindow = infoWindow;
        }

        if (infoWindowContent !== null) {
          google.maps.event.addListener(marker, 'click', function() {
            if (typeof infoWindowContent === 'function') {
              infoWindowContent().then(function(res) {
                showInfoWindow(res);
              });
            } else {
              showInfoWindow(infoWindowContent);
            }
          });
        }

        // Cache marker
        _markers.unshift(marker);

        // Cache instance of our marker for scope purposes
        that.markers.unshift({
          'lat': lat,
          'lng': lng,
          'icon': icon,
          'infoWindowContent': infoWindowContent,
          'label': label,
          'url': url,
          'thumbnail': thumbnail
        });

        // Return marker instance
        return marker;
      };

      this.findMarker = function (lat, lng) {
        for (var i = 0; i < _markers.length; i++) {
          var pos = _markers[i].getPosition();

          if (floatEqual(pos.lat(), lat) && floatEqual(pos.lng(), lng)) {
            return _markers[i];
          }
        }

        return null;
      };

      this.findMarkerIndex = function (lat, lng) {
        for (var i = 0; i < _markers.length; i++) {
          var pos = _markers[i].getPosition();

          if (floatEqual(pos.lat(), lat) && floatEqual(pos.lng(), lng)) {
            return i;
          }
        }

        return -1;
      };

      this.addInfoWindow = function (lat, lng, html) {
        var win = new google.maps.InfoWindow({
          content: html,
          position: new google.maps.LatLng(lat, lng)
        });

        _windows.push(win);

        return win;
      };

      this.hasMarker = function (lat, lng) {
        return that.findMarker(lat, lng) !== null;
      };

      this.getMarkerInstances = function () {
        return _markers;
      };

      this.removeMarkers = function (markerInstances) {

        var s = this;

        angular.forEach(markerInstances, function (v) {
          var pos = v.getPosition(),
            lat = pos.lat(),
            lng = pos.lng(),
            index = s.findMarkerIndex(lat, lng);

          // Remove from local arrays
          _markers.splice(index, 1);
          s.markers.splice(index, 1);

          // Remove from map
          v.setMap(null);
        });
      };
    }

    // Done
    return PrivateMapModel;
  }());

  // End model

  // Start Angular directive

  var googleMapsModule = angular.module('google-maps', []);
  googleMapsModule.directive('googleMap', MapsDirective);
  /**
   * Map directive
   */
  MapsDirective.$inject = ['$log', '$timeout', '$window'];
  function MapsDirective($log, $timeout, $window) {

    var _m = null;

    function clearPolygon() {
      if (_m.currentPolygon()) {
        _m.currentPolygon().setMap(null);
        _m.setCurrentPolygon(null);
      }
    }

    function toML(overlay) {
      var METERS_PER_MILE = 0.000621371;
      if (overlay.type === 'rectangle') {
        var bounds = overlay.overlay.getBounds();
        return {
          type: 'box',
          bounds: {
            south: bounds.getSouthWest().lat(),
            west: bounds.getSouthWest().lng(),
            north: bounds.getNorthEast().lat(),
            east: bounds.getNorthEast().lng()
          }
        };
      }
      else if (overlay.type === 'circle') {
        return {
          type: 'circle',
          bounds: {
            radius: overlay.overlay.getRadius() * METERS_PER_MILE,
            point: {
              latitude: overlay.overlay.getCenter().lat(),
              longitude: overlay.overlay.getCenter().lng()
            }
          }
        };
      }
      else if (overlay.type === 'polygon') {
        var points = [];
        overlay.overlay.getPath().forEach(function(latlng) {
          points.push({
            latitude: latlng.lat(),
            longitude: latlng.lng()
          });
        });
        return {
          type: 'polygon',
          bounds: {
            point: points
          }
        };
      }
    }

    function customControls(scope) {
      var drawingManager = new google.maps.drawing.DrawingManager({
        drawingControl: true,
        drawingControlOptions: {
          position: google.maps.ControlPosition.TOP_LEFT,
          drawingModes: [
            google.maps.drawing.OverlayType.CIRCLE,
            google.maps.drawing.OverlayType.POLYGON,
            google.maps.drawing.OverlayType.RECTANGLE
          ]
        },
        polygonOptions: {
          strokeColor: 'black',
          fillColor: scope.options.colors[0]
        },
        circleOptions: {
          strokeColor: 'black',
          fillColor: scope.options.colors[0]
        }
      });

      drawingManager.setMap(_m.getMap());

      google.maps.event.addListener(drawingManager, 'overlaycomplete', function(overlay) {
        clearPolygon();
        _m.setCurrentPolygon(overlay.overlay);
        scope.currentPolygon = toML(overlay);
        scope.$apply();
      });
    }

    return {
      restrict: 'ECA',
      priority: 100,
      transclude: true,
      template: '<div class="angular-google-map" ng-transclude></div>',
      replace: false,
      scope: {
        currentPolygon: '=',
        options: '=options', // required
        markers: '=markers', // optional
        latitude: '=latitude', // required
        longitude: '=longitude', // required
        refresh: '&refresh', // optional
        windows: '=windows', // optional
        events: '=events',
        customControls: '=customControls'
      },
      link: function (scope, element, attrs) {

        scope.options.colors = scope.options.colors || ['red', 'green', 'blue', 'grey', 'orange', 'yellow', 'purple', 'green'];

        if (!angular.isDefined(scope.options)) {
          $log.error('angular-google-maps: map options property not set');
          return;
        }

        // Parse options
        var opts = angular.extend(scope.options, {
          container: element[0]
        });

        // Create our model
        _m = new MapModel(opts);

        if (attrs.showTools === 'true') {
          _m.once('idle', function() {
            customControls(scope);
          });
        }

        _m.on('drag', function () {

          var c = _m.center;

          $timeout(function () {

            scope.$apply(function () {
              scope.options.center.latitude = c.lat();
              scope.options.center.longitude = c.lng();
            });
          });
        });

        _m.on('zoom_changed', function () {

          if (scope.zoom !== _m.zoom) {

            $timeout(function () {

              scope.$apply(function () {
                scope.zoom = _m.zoom;
              });
            });
          }
        });

        _m.on('center_changed', function () {
          var c = _m.center;

          $timeout(function () {

            scope.$apply(function () {

              if (!_m.dragging) {
                scope.options.center.latitude = c.lat();
                scope.options.center.longitude = c.lng();
              }
            });
          });
        });


        if (angular.isDefined(scope.events)) {
          var eventName = null;
          var f = function() {
            scope.events[eventName].apply(scope, [_m, eventName, arguments]);
          };
          for (var e in scope.events) {
            eventName = e;
            if (scope.events.hasOwnProperty(eventName) && angular.isFunction(scope.events[eventName])) {
              _m.on(eventName, f);
            }
          }
        }

        if (attrs.markClick === 'true') {
          (function () {
            var cm = null;

            _m.on('click', function (e) {
              if (cm === null) {

                cm = {
                  latitude: e.latLng.lat(),
                  longitude: e.latLng.lng()
                };

                scope.markers.push(cm);
              }
              else {
                cm.latitude = e.latLng.lat();
                cm.longitude = e.latLng.lng();
              }


              $timeout(function () {
                scope.latitude = cm.latitude;
                scope.longitude = cm.longitude;
                scope.$apply();
              });
            });
          }());
        }

        // Put the map into the scope
        scope.map = _m;

        // Check if we need to refresh the map
        if (angular.isUndefined(scope.refresh())) {
          // No refresh property given; draw the map immediately
          _m.draw();
        }
        else {
          var hasDrawn = false;
          scope.$watch('refresh()', function (newValue, oldValue) {
            if (newValue && (!hasDrawn || !oldValue)) {
              _m.draw();
              hasDrawn = true;
            }
          });
        }

        // Markers
        scope.$watch('markers', function (newValue) {
          $timeout(function () {

            angular.forEach(newValue, function (v) {
              if (!_m.hasMarker(v.latitude, v.longitude)) {
                _m.addMarker(v.latitude, v.longitude, v.icon, v.infoWindow);
              }
            });

            // Clear orphaned markers
            var orphaned = [];

            angular.forEach(_m.getMarkerInstances(), function (v) {
              // Check our scope if a marker with equal latitude and longitude.
              // If not found, then that marker has been removed form the scope.

              var pos = v.getPosition(),
                lat = pos.lat(),
                lng = pos.lng(),
                found = false;

              // Test against each marker in the scope
              for (var si = 0; si < scope.markers.length; si++) {

                var sm = scope.markers[si];

                if (floatEqual(sm.latitude, lat) && floatEqual(sm.longitude, lng)) {
                  // Map marker is present in scope too, don't remove
                  found = true;
                  break;
                }
              }

              // Marker in map has not been found in scope. Remove.
              if (!found) {
                orphaned.push(v);
              }
            });

            if (orphaned.length) {
              _m.removeMarkers(orphaned);
            }

            // Fit map when there are more than one marker.
            // This will change the map center coordinates
            if (attrs.fit === 'true' && newValue && newValue.length >= 1) {
              _m.fit();
            }
          });

        }, true);


        // Update map when center coordinates change
        scope.$watch('center', function (newValue, oldValue) {
          if (newValue === oldValue) {
            return;
          }

          if (!_m.dragging) {
            _m.center = new google.maps.LatLng(newValue.latitude,
                newValue.longitude);
            _m.draw();
          }
        }, true);

        scope.$watch('zoom', function (newValue, oldValue) {
          if (newValue === oldValue) {
            return;
          }

          _m.zoom = newValue;
          _m.draw();
        });

        scope.$watch('currentPolygon', function(newValue) {
          if (!newValue) {
            clearPolygon();
          }
        });
      }
    };
  }
}());
