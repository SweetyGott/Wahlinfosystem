angular.module('nodeTodo', ['googlechart', 'ngRoute'])

.config(function ($routeProvider) {
  $routeProvider.when("/", {
    templateUrl: "uebersicht.html",
  }).when("/knappsteSieger", {
    templateUrl: "knappsteSieger.html",
  }).otherwise({
    redirectTo: "/"
  });
})

.controller('MainController', function($scope, $http) {

    $scope.formData = {};
    $scope.todoData = {};



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


    //GetWahlkreise
    $scope.wahlkreise = {};

    $scope.getWahlkreiseNavBar = function() {
        // Get all todos
        $http.get('/api/v1/wahlinfo/wahlkreise')
            .success(function(data) {
                $scope.wahlkreise = data;
                console.log(data);
            })
            .error(function(error) {
                console.log('Error: ' + error);
            });
    };
    $scope.getWahlkreiseNavBar();




    //GetDistribution
    $scope.getVoteDistribution = function() {
        $http.get('/api/v1/wahlinfo/stimmverteilung')
            .success(function(data) {
                console.log(data);
                var chartData = [];
                j = 0;
                for (var i = 0, l = data.length; i < l; i++) {
                    chartData.push({ c: [ { v: data[i].name }, {v: (parseFloat(data[i].stimmen))} ] });
                    j += parseFloat(data[i].stimmen);
                }
                chartData.push({ c: [ { v: "" }, {v: j} ] });
                $scope.sitzverteilungChart.data.rows = chartData;
            })
            .error(function(data) {
                console.log('Error: ' + data);
            });
    };


    $scope.sitzverteilungChart = {};
    $scope.sitzverteilungChart.type = "PieChart";
    $scope.sitzverteilungChart.data = {"cols": [
        {id: "t", label: "Topping", type: "string"},
        {id: "s", label: "Slices", type: "number"}
    ], "rows": $scope.getVoteDistribution() };
    $scope.sitzverteilungChart.options = {
        pieHole: 0.5,
        pieStartAngle: -90,
        pieSliceText: 'value',
        colors: ['black', 'black', 'purple', 'green', 'red', 'transparent'],
        'title': 'Wahlergebnis'
    };

});





