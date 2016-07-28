(function () {

  'use strict';

  angular.module('app')
  .config(Config);

  function Config($locationProvider, $routeProvider) {

    $locationProvider.html5Mode(true);
    $locationProvider.hashPrefix('!');

    function resolveUser(AuthenticationService) {
      return AuthenticationService.getUser().then(function(user) {
        return user;
      });
    }

    $routeProvider
      .when('/login/', {
        templateUrl: '/views/login/login.html',
        controller: 'LoginCtrl',
        controllerAs: 'ctrl'
      })
      .when('/', {
        templateUrl: '/views/splash/splash.html',
        controller: 'SplashCtrl',
        controllerAs: 'splashCtrl',
        resolve: {
          counts: function($http) {
            return $http.get('/v1/resources/datasources').then(function(resp) {
              return resp.data;
            });
          },
          user: resolveUser
        }
      })
      .when('/physician/', {
        templateUrl: '/views/doctor/home.html',
        controller: 'DoctorCtrl',
        controllerAs: 'ctrl',
        resolve: {
          user: resolveUser
        },
        reloadOnSearch: false
      })
      .when('/payor/:search?', {
        templateUrl: '/views/payor/home.html',
        controller: 'PayorCtrl',
        controllerAs: 'payorCtrl',
        resolve: {
          user: resolveUser,
          constraints: function(MLRest) {
            return MLRest.queryConfig('payor-dash', 'constraint').then(function(resp) {
              return resp.data.options.constraint;
            });
          }
        },
        reloadOnSearch: false
      })
      .when('/patient/:docFind?', {
        templateUrl: '/views/patient/home.html',
        controller: 'PatientCtrl',
        controllerAs: 'ctrl',
        resolve: {
          user: resolveUser,
          patientUri: function($route) {
            return '/patients/200-48-0000.xml';
          },
          patient: function($route, MLRest) {
            return MLRest.getDocument('/patients/200-48-0000.xml', { transform: 'patient-json' }).then(function(resp) {
              return resp.data;
            });
          }
        },
        reloadOnSearch: false
      })
      .when('/researcher/', {
        templateUrl: '/views/researcher/home.html',
        controller: 'ResearcherCtrl',
        controllerAs: 'researcherCtrl',
        resolve: {
          user: resolveUser,
          savedSearches: function(MLRest) {
            return MLRest.getDocument('/saved-searches.json').then(function(resp) {
              return resp.data || [];
            },
            function() {
              return [];
            });
          }
        },
        reloadOnSearch: false
      })
      .when('/taxonomy/', {
        templateUrl: '/views/taxonomy/home.html',
        controller: 'TaxonomyCtrl',
        controllerAs: 'taxonomyCtrl',
        resolve: {
          user: resolveUser
        },
        reloadOnSearch: false
      })
      .when('/view/providers:providerId*', {
        templateUrl: '/views/provider/details.html',
        controller: 'PatientProviderCtrl',
        controllerAs: 'patientProviderCtrl',
        resolve: {
          user: resolveUser,
          provider: function(MLRest, $route) {
            return MLRest.getDocument($route.current.params.providerId, { transform: 'provider-json' }).then(function(resp) {
              return resp.data;
            });
          }
        }
      })
      .when('/view/patients:patientId*', {
        template: '<patient-view patient="ctrl.doc" patient-uri="ctrl.uri"></patient-view>',
        controller: 'DetailViewCtrl',
        controllerAs: 'ctrl',
        resolve: {
          user: resolveUser,
          uri: function($route) {
            return $route.current.params.patientId;
          },
          doc: function($route, MLRest) {
            return MLRest.getDocument($route.current.params.patientId, { transform: 'patient-json' }).then(function(resp) {
              return resp.data;
            });
          }
        }
      })
      .when('/view/claims:claimId*', {
        templateUrl: '/views/claim/claim.html',
        controller: 'DetailViewCtrl',
        controllerAs: 'ctrl',
        resolve: {
          user: resolveUser,
          uri: function($route) {
            return $route.current.params.claimId;
          },
          doc: function(payorService, $route) {
            var uri = $route.current.params.claimId;
            return payorService.getClaim(uri);
          }
        }
      })
      .when('/view/medicared:prescriberId*', {
        templateUrl: '/views/prescriber/prescriber.html',
        controller: 'DetailViewCtrl',
        controllerAs: 'ctrl',
        resolve: {
          user: resolveUser,
          uri: function($route) {
            return $route.current.params.prescriberId;
          },
          doc: function($route, MLRest) {
            return MLRest.getDocument($route.current.params.prescriberId, { transform: 'prescriber-json' }).then(function(resp) {
              return resp.data;
            });
          }
        }
      })
      .when('/view/diabetes:diabetesId*', {
        templateUrl: '/views/diabetes/details.html',
        controller: 'DetailViewCtrl',
        controllerAs: 'ctrl',
        resolve: {
          user: resolveUser,
          uri: function($route) {
            return $route.current.params.diabetesId;
          },
          doc: function($route, MLRest) {
            return MLRest.getDocument($route.current.params.diabetesId, { transform: 'diabetes-json' }).then(function(resp) {
              return resp.data;
            });
          }
        }
      })
      .when('/view/safetyrecord:safetyrecordId*', {
        templateUrl: '/views/safetyrecord/details.html',
        controller: 'DetailViewCtrl',
        controllerAs: 'ctrl',
        resolve: {
          user: resolveUser,
          uri: function($route) {
            return $route.current.params.safetyrecordId;
          },
          doc: function($route, MLRest) {
            return MLRest.getDocument($route.current.params.safetyrecordId, { transform: 'faers-json' }).then(function(resp) {
              return resp.data;
            });
          }
        }
      })
      .when('/view/spl:splId*', {
        templateUrl: '/views/spl/details.html',
        controller: 'DetailViewCtrl',
        controllerAs: 'ctrl',
        resolve: {
          user: resolveUser,
          uri: function($route) {
            return $route.current.params.splId;
          },
          doc: function($route, splService) {
            return splService.getSplDoc($route.current.params.splId);
          }
        }
      })
      .otherwise({
        redirectTo: '/'
      });
  }
})();
