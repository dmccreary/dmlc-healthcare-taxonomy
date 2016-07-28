(function () {
  'use strict';

  angular.module('app')
    .controller('PatientProviderCtrl', PatientProviderCtrl);

    function PatientProviderCtrl(provider, $routeParams) {
      var ctrl = this;
      ctrl.provider = provider;
      ctrl.mapOptions = {
        zoom: 8,
        minZoom: 4,
        center: new google.maps.LatLng(provider.lat, provider.lng),
        mapTypeControl: false,
        streetViewControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };

      ctrl.markers = [];
      ctrl.markers.push({
        latitude: provider.lat,
        longitude: provider.lng,
        infoWindow: [
              '<div class="info-title" style="white-space: nowrap; text-overflow: ellipsis;" title="' + provider.name + '"><strong>' + provider.name + '</strong></div>',
              '<div class="info-street">' + (provider.address['addr-line1']||'') + ' ' + (provider.address['addr-line2']||'') +'</div>',
              '<div>' + (provider.address.city||'') + ' ' + (provider.address.state||'') + ' ' + (provider.address.zip5||'') + '</div>'
            ].join('\n')
      });

    }

}());
