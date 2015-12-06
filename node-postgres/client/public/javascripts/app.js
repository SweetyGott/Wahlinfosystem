angular.module('nodeTodo', ['googlechart', 'ngRoute', 'ngTable', 'ui.router'])

.config(function ($routeProvider, $locationProvider) {
  $routeProvider.when("/", {
    templateUrl: "uebersicht.html",
  }).when("/bundestag", {
    name: "bundestag",
    templateUrl: "bundestag.html",
  }).when("/knappsteSieger", {
    templateUrl: "knappsteSieger.html",
  }).when("/wahlkreisuebersicht", {
    templateUrl: "wahlkreisuebersicht.html",
  }).otherwise({
    redirectTo: "/"
  });
})

.controller('MainController', function($scope, $filter, $http, $route, ngTableParams) {

    $scope.formData = {};
    $scope.todoData = {};

    //pageStati
    $scope.jahr = 2013;
    $scope.currentpage = "";

    //Bundestag
    $scope.bundestag = [];  

    //Fuer wkuebersicht
    $scope.activesBundesland = 0;
    $scope.bundeslaender = {};
    $scope.aktiverWahlkreis = 0;
    $scope.selectedwahlkreise = {};


    $scope.initView = function() {
        // Get all todos
        $http.get('/api/v1/todos')
            .success(function(data) {
                $scope.todoData = data;
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };
    $scope.initView();
    //console.log($route.current.templateUrl);
    console.log($route);

    // Create a new todo
    $scope.createTodo = function(todoID) {
        $http.post('/api/v1/todos', $scope.formData)
            .success(function(data) {
                $scope.formData = {};
                $scope.todoData = data;
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };

    // Delete a todo
    $scope.deleteTodo = function(todoID) {
        $http.delete('/api/v1/todos/' + todoID)
            .success(function(data) {
                $scope.todoData = data;
                console.log(data);
            })
            .error(function(data) {
                console.log('Error: ' + data);
            });
    };


    /** Routing Page actualisation**/
    $scope.changeYear = function(year) {
        $scope.jahr = year;

        switch( $scope.currentpage ) {
            case "main":
                $scope.startMain();
                break;
            case "bundestag":
                $scope.startBundestag();
                break;
            case "knappstesieger":
                $scope.startKnappsteSieger();
                break;
            case "wahlkreisuebersicht":
                $scope.startWahlkreisuebersicht();
                break;
        }
    };

    /**Update On Top Function**/
    $scope.startMain = function() {
        $scope.currentpage = "main";
    };
    $scope.startBundestag = function() {
        $scope.currentpage = "bundestag";
        $scope.getVoteDistribution();
        $scope.getBundestag();
    };
    $scope.startKnappsteSieger = function() {
        $scope.currentpage = "knappstesieger";
        $scope.getParteien();
    }
    $scope.startWahlkreisuebersicht = function() {
        $scope.currentpage = "wahlkreisuebersicht";
        $scope.getBundeslaender();
        //$scope.getWahlkreise();
    }



    /** ActionFunctions**/
    $scope.loadSelectedWahlkreise = function( bid ) {
        $scope.aktivesBundesland = bid;
        $scope.getSelectedWahlkreise();

    }

    $scope.loadaktiverWahlkreis = function( wkid ) {
        console.log(wkid);
        $scope.aktiverWahlkreis = wkid;

        $scope.getWahlbeteiligung();
        $scope.getDirektmandat();
        $scope.getStimmen();
        $scope.getDifferenz();
    };






    /****GET DATA FUNCTIONS****/
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

    //Analyse
   $scope.wkwahlbeteiligung = 0;
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
    $scope.wkdirektmandat = "";
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
    $scope.wkstimmen = {};
    $scope.getStimmen = function() {
        $http.get('/api/v1/wahlinfo/wkstimmen/' + $scope.jahr + '/' + $scope.aktiverWahlkreis.id + '/')
            .success(function(data) {
                $scope.wkstimmen = data;
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };
    $scope.wkdifference = {};
    $scope.getDifferenz = function() {
        $http.get('/api/v1/wahlinfo/wkdifference/' + $scope.jahr + '/' + $scope.aktiverWahlkreis.id + '/')
            .success(function(data) {
                $scope.wkdifference = data;
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };

    

    //GetParteien
    $scope.parteien = {};
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

    //GetClosestWinner
    $scope.aktivePartei = 46;
    $scope.knappsteSieger = {};
    $scope.getKnappsteSieger = function() {
        // Get all todos
        $http.get('/api/v1/wahlinfo/knappstesieger/' + $scope.jahr + '/' + $scope.aktivePartei + '/')
            .success(function(data) {
                $scope.knappsteSieger = data;
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };
    $scope.loadknappstesieger = function( parteiid ) {
        $scope.aktivePartei = parteiid;
        $scope.getKnappsteSieger();
    }


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
        colors: ['black', 'black', 'purple', 'green', 'red', 'transparent'],
        'title': 'Wahlergebnis ' + $scope.jahr + ':'
    };



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
        }

    });

});





