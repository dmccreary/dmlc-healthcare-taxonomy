(function () {

  'use strict';

  angular
    .module('app')
    .directive('patientView', PatientViewDirective)
    .controller('patientViewController', PatientViewController)
    .directive( 'popoverHtmlPopup', function($sce, $http, $modal) {
      return {
        restrict: 'EA',
        replace: true,
        scope: { title: '@', content: '@', placement: '@', animation: '&', isOpen: '&' },
        templateUrl: '/views/patient/highlight-popover.html',
        link: function(scope, element, attrs) {
          scope.safeContent = $sce.trustAsHtml(scope.content);

          element.bind('click', function(evt) {
            var e = $(evt.target);
            if (e.attr('data-drug')) {
              scope.showLabel(null, e.attr('data-drug'));
            }
          });

          scope.showLabel = function(spl, name) {
            var params = {};
            if (spl) {
              params['rs:spl'] = spl;
            }
            else {
              params['rs:drugName'] = name;
            }

            $modal.open({
              templateUrl: '/views/spl/spl.html',
              controller: 'SplCtrl as ctrl',
              resolve: {
                details: function () {
                  return $http({
                    method: 'GET',
                    url: '/v1/resources/spl?' + $.param(params),
                    headers: {
                      accept: 'application/json'
                    }
                  });
                }
              }
            });
          };
        }
      };
    })
    .directive( 'popoverHtml', [ '$compile', '$timeout', '$parse', '$window', '$tooltip', function ( $compile, $timeout, $parse, $window, $tooltip ) {
      return $tooltip( 'popoverHtml', 'popover', 'click' );
    }]);


  function PatientViewDirective() {
    return {
      restrict: 'E',
      scope: {
        patientUri: '=',
        patient: '='
      },
      templateUrl: '/views/patient/patient.html',
      controller: 'patientViewController',
      controllerAs: 'pvc'
    };
  }

  function PatientViewController($scope, $modal, $http, $sce, MLRest) {
    var ctrl = this;
    angular.extend(ctrl, {
      addVitals: addVitals,
      encounterDate: encounterDate,
      highlightClass: highlightClass
    });

    function addVitals() {
      var instance = $modal.open({
        templateUrl: '/views/patient/add-vitals.html',
        controller: 'AddVitalsCtrl as addVitalsCtrl',
        resolve: {
          patientId: function () {
            return $scope.patientUri;
          }
        }
      });
      instance.result.then(function () {
        MLRest.getDocument($scope.patientUri, { transform: 'patient-json' }).then(function(resp) {
          $scope.patient = resp.data;
        });
      });
    }
  }

  function encounterDate(date) {
    return moment(date).format('MMMM Do YYYY');
  }

  function highlightClass(type) {
    var t = type.toLowerCase().replace(/[^\w]+/g, '-');
    return t.replace(/medicine-([^-]+)-([^-]+)/, 'medicine-$2');
  }

})();
