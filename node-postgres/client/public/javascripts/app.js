angular.module('nodeTodo', ['googlechart', 'ngRoute', 'ngTable', 'ui.router'])

.config(function ($routeProvider, $locationProvider) {
  $routeProvider.when("/", {
    templateUrl: "uebersicht.html",
  }).when("/bundestag", {
    name: "bundestag",
    templateUrl: "bundestag.html",
  }).when("/wahlkreisuebersicht", {
    templateUrl: "wahlkreisuebersicht.html",
  }).when("/wahlkreissieger", {
    templateUrl: "wahlkreissieger.html",
  }).when("/ueberhangmandate", {
    templateUrl: "ueberhangmandate.html",
  }).when("/knappsteSieger", {
    templateUrl: "knappsteSieger.html",
  }).when("/justbundestag", {
    templateUrl: "justbundestag.html",
  }).otherwise({
    redirectTo: "/"
  });
})

.controller('MainController', function($scope, $filter, $http, $route, ngTableParams) {

    $scope.formData = {};
    $scope.todoData = {};

    //pageStati
    $scope.jahr = 2013;
    $scope.currentpage = "main";

    //Bundestag
    $scope.bundestag = [];  

    //Fuer wkuebersicht
    $scope.aktivesBundesland = 0;
    $scope.bundeslaender = {};
    $scope.aktiverWahlkreis = 0;
    $scope.selectedwahlkreise = {};

    //Wk-Analyse
    $scope.wkwahlbeteiligung = 0;
    $scope.wkdirektmandat = "";
    $scope.wkstimmen = [];
    $scope.wkdifference = [];

    //Wahlkreissieger
    $scope.wahlkreissieger= [];

    //Überhangmandate
    $scope.ueberhangmandate = [];

    //knappsteSiegerAnalyse
    $scope.parteien = {};
    $scope.aktivePartei = 0; //defaultpartei
    $scope.knappsteSieger = [];
    

    /**Update On Top Function**/
    $scope.startMain = function() {
        $scope.currentpage = "main";
        $scope.getVoteDistribution();
    };
    $scope.startBundestag = function() {
        $scope.currentpage = "bundestag";
        $scope.getVoteDistribution();
        $scope.getBundestag();
    };
    $scope.startWahlkreisuebersicht = function() {
        $scope.currentpage = "wahlkreisuebersicht";
        $scope.getBundeslaender();
        $scope.loadSelectedWahlkreise(14);
        $scope.loadaktiverWahlkreis( { id: 215, name: "Freising"}  );
    };
    $scope.startWahlkreissieger = function() {
        $scope.currentpage = "wahlkreissieger";
        $scope.getwahlkreissieger();
    };
    $scope.startUeberhangmandate = function() {
        $scope.currentpage = "ueberhangmandate";
        $scope.getUeberhangmandate();
    };
    $scope.startKnappsteSieger = function() {
        $scope.currentpage = "knappstesieger";
        $scope.loadknappstesieger(65);
        $scope.getParteien();
    };
    $scope.startJustBundestag = function() {
        $scope.currentpage = "justbundestag";
        $scope.getBundestag();
    };

    /** Routing Page actualisation**/
    $scope.changeYear = function(year) {
        $scope.jahr = year;
        
        if( $scope.jahr == 2013) {
            $scope.sitzverteilungChart.options.colors = ['black', 'black', 'purple', 'green', 'red'];
        } else {
            $scope.sitzverteilungChart.options.colors = ['black', 'black', 'purple', 'yellow', 'green', 'red'];
        }

        switch( $scope.currentpage ) {
            case "main":
                $scope.startMain();
                break;
            case "bundestag":
                $scope.startBundestag();
                break;
            case "wahlkreisuebersicht":
                $scope.startWahlkreisuebersicht();
                break;
            case "wahlkreissieger":
                $scope.startWahlkreissieger();
                break; 
            case "ueberhangmandate":
                $scope.startUeberhangmandate();
                break;
            case "knappstesieger":
                $scope.startKnappsteSieger();
                break;
            case "justbundestag":
                $scope.startJustBundestag();
                break;
        }
    };



    /** ActionFunctions**/
    $scope.loadSelectedWahlkreise = function( bid ) {
        $scope.aktivesBundesland = bid;
        $scope.getSelectedWahlkreise();
    }
    $scope.loadaktiverWahlkreis = function( wkid ) {
        $scope.aktiverWahlkreis = wkid;

        $scope.getWahlbeteiligung();
        $scope.getDirektmandat();
        $scope.getStimmen();
        $scope.getDifferenz();
    };

    $scope.loadknappstesieger = function( parteiid ) {
        $scope.aktivePartei = parteiid;
        $scope.getKnappsteSieger();
    }

    /****GET DATA FUNCTIONS****/
    //Q1
    //GetPieChart
    $scope.getVoteDistribution = function() {
        $http.get('/api/v1/wahlinfo/stimmverteilung/' + $scope.jahr + '/0/')
            .success(function(data) {
                console.log(data);
                var chartData = [];
                j = 0;
                for (var i = 0, l = data.length; i < l; i++) {
                    chartData.push({ c: [ { v: data[i].name }, {v: (parseInt(data[i].count))} ] });
                    j += parseFloat(data[i].stimmen);
                }
                chartData.push({ c: [ { v: "" }, {v: j} ] });
                $scope.sitzverteilungChart.data.rows = chartData;
                $scope.sitzverteilungChart.options.title = 'Wahlergebnis ' + $scope.jahr + ':';
            })
            .error(function(data) {
                console.log('Error: ' + data);
            });
    };

    //Q2
    //GetBundestag
    $scope.getBundestag = function() {
        // Get all todos
        $http.get('/api/v1/wahlinfo/bundestag/' + $scope.jahr + '/0/')
            .success(function(data) {
                $scope.bundestag = data;
                $scope.bundestagtable.reload();

                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };


    //Q3
    //Analyse
    $scope.getWahlbeteiligung = function() {
        $http.get('/api/v1/wahlinfo/wkuebersichtbeteiligung/' + $scope.jahr + '/' + $scope.aktiverWahlkreis.id + '/')
            .success(function(data) {
                $scope.wkwahlbeteiligung = data;
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };
    $scope.getDirektmandat = function() {
        $http.get('/api/v1/wahlinfo/wkdirektmandat/' + $scope.jahr + '/' + $scope.aktiverWahlkreis.id + '/')
            .success(function(data) {
                $scope.wkdirektmandat = data;
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };
    $scope.getStimmen = function() {
        $http.get('/api/v1/wahlinfo/wkstimmen/' + $scope.jahr + '/' + $scope.aktiverWahlkreis.id + '/')
            .success(function(data) {
                $scope.wkstimmen = data;
                $scope.wkstimmentable.reload();
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };
    $scope.getDifferenz = function() {
        $http.get('/api/v1/wahlinfo/wkdifference/' + $scope.jahr + '/' + $scope.aktiverWahlkreis.id + '/')
            .success(function(data) {
                $scope.wkdifference = data;
                $scope.wkdifferencetable.reload();
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };

    //Q4
    //getwahlkreissieger
    $scope.getwahlkreissieger = function() {
        $http.get('/api/v1/wahlinfo/wahlkreissieger/' + $scope.jahr + '/0/')
            .success(function(data) {
                $scope.wahlkreissieger = data;
                $scope.wahlkreissiegertable.reload();
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };


    //Q5
    //Überhangmandate
    $scope.getUeberhangmandate = function() {
        $http.get('/api/v1/wahlinfo/ueberhangmandate/' + $scope.jahr + '/0/')
            .success(function(data) {
                $scope.ueberhangmandate = data;
                $scope.ueberhangmandattable.reload();
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };

    //Q6
    //GetClosestWinner
    $scope.getKnappsteSieger = function() {
        // Get all todos
        $http.get('/api/v1/wahlinfo/knappstesieger/' + $scope.jahr + '/' + $scope.aktivePartei + '/')
            .success(function(data) {
                $scope.knappsteSieger = data;
                $scope.knappstesiegertable.reload();
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };



    //GENERAL GETTER
    //GetParteien
    $scope.getParteien = function() {
        // Get all todos
        $http.get('/api/v1/wahlinfo/parteien/' + $scope.jahr + '/0/')
            .success(function(data) {
                $scope.parteien = data;
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };
    //Get Bundeslaender
    $scope.getBundeslaender = function() {
        // Get all todos
        $http.get('/api/v1/wahlinfo/bundeslaender/0/0/')
            .success(function(data) {
                $scope.bundeslaender = data;
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };

    //GetSelectedWahlkreise
    $scope.getSelectedWahlkreise = function() {
        // Get all todos
        $http.get('/api/v1/wahlinfo/wahlkreise/' + $scope.jahr + '/' + $scope.aktivesBundesland + '/')
            .success(function(data) {
                $scope.selectedwahlkreise = data;
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };



    //Kuchendiagramm
    $scope.sitzverteilungChart = {};
    $scope.sitzverteilungChart.type = "PieChart";
    $scope.sitzverteilungChart.data = {"cols": [
        {id: "t", label: "Topping", type: "string"},
        {id: "s", label: "Slices", type: "number"}
    ], "rows": "" };
    $scope.sitzverteilungChart.options = {
        pieHole: 0.4,
        pieStartAngle: -90,
        pieSliceText: 'value',
        colors: ['black', 'black', 'purple', 'green', 'red'],
        'title': 'Wahlergebnis ' + $scope.jahr + ':'
    };


    //Bundestagtable
    $scope.bundestagtable = new ngTableParams({
        page: 1,
        count: 20
    },{    
        total: $scope.bundestag.length, 
        getData: function ($defer, params) {
            $scope.bundestagdata = params.sorting() ? $filter('orderBy')($scope.bundestag, params.orderBy()) : $scope.bundestag;
            $scope.bundestagdata = params.filter() ? $filter('filter')($scope.bundestagdata, params.filter()) : $scope.bundestagdata;
            $scope.bundestagdata = $scope.bundestagdata.slice((params.page() - 1) * params.count(), params.page() * params.count());
            $defer.resolve($scope.bundestag);

            params.total($scope.bundestag.length); 
        }
    });

    //Wahlkreissiegertable
    $scope.wahlkreissiegertable = new ngTableParams({
        page: 1,
        count: 20
    },{    
        total: $scope.wahlkreissieger.length, 
        getData: function ($defer, params) {
            $scope.wahlkreissiegerdata = params.sorting() ? $filter('orderBy')($scope.wahlkreissieger, params.orderBy()) : $scope.wahlkreissieger;
            $scope.wahlkreissiegerdata = params.filter() ? $filter('filter')($scope.wahlkreissiegerdata, params.filter()) : $scope.wahlkreissiegerdata;
            $scope.wahlkreissiegerdata = $scope.wahlkreissiegerdata.slice((params.page() - 1) * params.count(), params.page() * params.count());
            $defer.resolve($scope.wahlkreissiegerdata);

            params.total($scope.wahlkreissieger.length); 
        }
    });

    //WkÜbersicht tables
    $scope.wkstimmentable = new ngTableParams({
        page: 1,
        count: 20
    },{    
        total: $scope.wkstimmen.length, 
        getData: function ($defer, params) {
            $scope.wkstimmendata = params.sorting() ? $filter('orderBy')($scope.wkstimmen, params.orderBy()) : $scope.wkstimmen;
            $scope.wkstimmendata = params.filter() ? $filter('filter')($scope.wkstimmendata, params.filter()) : $scope.wkstimmendata;
            $scope.wkstimmendata = $scope.wkstimmendata.slice((params.page() - 1) * params.count(), params.page() * params.count());
            $defer.resolve($scope.wkstimmendata);

            params.total($scope.wkstimmen.length); 
        }
    });
    $scope.wkdifferencetable = new ngTableParams({
        page: 1,
        count: 20
    },{    
        total: $scope.wkdifference.length, 
        getData: function ($defer, params) {
            $scope.wkdifferencedata = params.sorting() ? $filter('orderBy')($scope.wkdifference, params.orderBy()) : $scope.wkdifference;
            $scope.wkdifferencedata = params.filter() ? $filter('filter')($scope.wkdifferencedata, params.filter()) : $scope.wkdifferencedata;
            $scope.wkdifferencedata = $scope.wkdifferencedata.slice((params.page() - 1) * params.count(), params.page() * params.count());
            $defer.resolve($scope.wkdifferencedata);

            params.total($scope.wkdifference.length); 
        }
    });

    //Ueberhangmandattable
    $scope.ueberhangmandattable = new ngTableParams({
        page: 1,
        count: 20
    },{    
        total: $scope.ueberhangmandate.length, 
        getData: function ($defer, params) {
            $scope.ueberhangmandatedata = params.sorting() ? $filter('orderBy')($scope.ueberhangmandate, params.orderBy()) : $scope.ueberhangmandate;
            $scope.ueberhangmandatedata = params.filter() ? $filter('filter')($scope.ueberhangmandatedata, params.filter()) : $scope.ueberhangmandatedata;
            $scope.ueberhangmandatedata = $scope.ueberhangmandatedata.slice((params.page() - 1) * params.count(), params.page() * params.count());
            $defer.resolve($scope.ueberhangmandatedata);

            params.total($scope.ueberhangmandate.length); 
        }
    });

    //knappstesiegertabletable
    $scope.knappstesiegertable = new ngTableParams({
        page: 1,
        count: 20
    },{    
        total: $scope.knappsteSieger.length, 
        getData: function ($defer, params) {
            $scope.knappsteSiegerdata = params.sorting() ? $filter('orderBy')($scope.knappsteSieger, params.orderBy()) : $scope.knappsteSieger;
            $scope.knappsteSiegerdata = params.filter() ? $filter('filter')($scope.knappsteSiegerdata, params.filter()) : $scope.knappsteSiegerdata;
            $scope.knappsteSiegerdata = $scope.knappsteSiegerdata.slice((params.page() - 1) * params.count(), params.page() * params.count());
            $defer.resolve($scope.knappsteSiegerdata);
        }
    });


    //Init View
    $scope.initView = function() {
        switch( window.location.hash ) {
            case "#/bundestag":
                $scope.startBundestag();
                break;
            case "#/wahlkreisuebersicht":
                $scope.startWahlkreisuebersicht();
                break;
            case "#/wahlkreissieger":
                $scope.startWahlkreissieger();
                break;
            case "#/ueberhangmandate":
                $scope.startUeberhangmandate();
                break;
            case "#/knappsteSieger":
                $scope.startKnappsteSieger();                
                break;
            case "#/justbundestag":
                $scope.startJustBundestag();                
                break;
            default:
                $scope.startMain();
                break;
        }
    };
    $scope.initView();

});





