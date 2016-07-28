(function () {

  'use strict';

  function getFileExtension(filename) {
    var pos = filename.lastIndexOf('.');
    if (pos !== -1) {
      return filename.substring(pos+1);
    } else {
      return '';
    }
  }

  angular
    .module('app')
    .controller('TaxonomyCtrl', TaxonomyCtrl);

  TaxonomyCtrl.$inject = ['$scope', '$http', '$sce'];

  function TaxonomyCtrl($scope, $http, $sce) {
    var note = 'Please select a RDF XML or TTL file';
    var ctrl = this;

    ctrl.deleteTaxonomy = deleteTaxonomy;

    $scope.uploader = {};
    $scope.note = note;
    $scope.hasTaxonomy = false;

    $scope.loading = true;

    var url = '/taxonomy/list';
    $http.get(url).then(function(response) {
      $scope.loading = false;

      if (response.data.taxonomies) {
        $scope.taxonomyName = response.data.taxonomies.name;
        $scope.hasTaxonomy = true;
      }
    }, function(response) {
      $scope.loading = false;
    });

    var tfile = null;

    $scope.onFileSelected = function(files) {
      var file = files[0];

      tfile = file;

      $scope.$apply(function($scope) {
        $scope.uploader.filename = file.name;
        $scope.uploader.filesize = file.size + ' bytes';

        var extension = getFileExtension($scope.uploader.filename);
        if (extension === 'xml' || extension === 'rdf' || extension === 'ttl') {
          $scope.showUploadButton = true;
          $scope.note = $scope.uploader.filename + ' ' + $scope.uploader.filesize;
        } else {
          $scope.showUploadButton = false;
          $scope.note = note;
        }
      });
    };

    $scope.uploadTaxonomy = function(event) {
      event.stopPropagation(); // Stop stuff happening
      event.preventDefault(); // Totally stop stuff happening

      var fdata = new FormData();
      fdata.append('taxonomy_file', tfile);

      $scope.clearMessage();
      $scope.uploader.working = true;

      $.ajax({
        url: '/taxonomy/upload',
        type: 'POST',
        data: fdata,
        cache: false,
        dataType: 'json',
        processData: false, // Don't process the files
        contentType: false, // Set content type to false as jQuery will tell the server its a query string request
        success: function(data, textStatus, jqXHR) {
          $scope.$apply(function($scope) {
            $scope.uploader.working = false;
            $scope.showMessage(data.message);

            if (data.success) {
              $scope.taxonomyName = $scope.uploader.filename;
              $scope.hasTaxonomy = true;
              $scope.note = note;
              $scope.showUploadButton = false;
            }
          });
        },
        error: function(jqXHR, textStatus, errorThrown) {
          $scope.uploader.working = false;
          $scope.showMessage(textStatus + ': ' + errorThrown);
        }
      });
    };

    $scope.showMessage = function(message) {
      $scope.message = message;
    };

    $scope.clearMessage = function() {
      $scope.message = '';
    };

    $scope.trustAsHtml = function(text) {
      return $sce.trustAsHtml(text);
    };

    function deleteTaxonomy() {
      $scope.clearMessage();
      var url = '/taxonomy/delete';
      $http.delete(url).then(function(response) {
        $scope.hasTaxonomy = false;
        $scope.showMessage(response.data.message);
      }, function(response) {
        $scope.hasTaxonomy = false;
      });
      return false;
    }
  }

})();
