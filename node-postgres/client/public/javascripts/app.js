angular.module('nodeTodo', ['googlechart'])
//angular.module('nodeTodo', ['chart.js'])
//angular.module('nodeTodo', ["googlechart", "googlechart-docs"])

.controller('MainController', function($scope, $http) {

    $scope.formData = {};
    $scope.todoData = {};
    $scope.sitzverteilungData = {};



    //Data GoogleChart
    $scope.chartObject = {};
    
    $scope.chartObject.type = "PieChart";
    
    $scope.onions = [
        {v: "Onions"},
        {v: 3},
    ];

    $scope.chartObject.data = {"cols": [
        {id: "t", label: "Topping", type: "string"},
        {id: "s", label: "Slices", type: "number"}
    ], "rows": [
        {c: [
            {v: "Mushrooms"},
            {v: 3},
        ]},
        {c: $scope.onions},
        {c: [
            {v: "Olives"},
            {v: 31}
        ]},
        {c: [
            {v: "Zucchini"},
            {v: 1},
        ]},
        {c: [
            {v: "Pepperoni"},
            {v: 2},
        ]}
    ]};

    $scope.chartObject.options = {
        'title': 'How Much Pizza I Ate Last Night'
    };


    //Data AngularChart
    $scope.labels = ["Download Sales", "In-Store Sales", "Mail-Order Sales", "Tele Sales", "Corporate Sales"];
    $scope.data = [300, 500, 100, 40, 120];

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




    //GetDistribution
    $scope.getVoteDistribution = function() {
        $http.get('/api/v1/stimmverteilung')
            .success(function(data) {
                console.log(data);
                var chartData = [];
                for (var i = 0, l = data.length; i < l; i++) {
                    chartData.push({ c: [ { v: data[i].name }, {v: parseFloat(data[i].stimmen)} ] });
                }
                $scope.sitzverteilungChart.data.rows = chartData;
            })
            .error(function(data) {
                console.log('Error: ' + data);
            });
    };





    
    //Sitzverteilung
    /*$scope.toGooglePie = function() {
        //var json = [{"name":"CDU","stimmen":"0.40474430307932882849"},{"name":"CSU","stimmen":"0.08797928534022331969"},{"name":"DIE LINKE","stimmen":"0.10187041310759579387"},{"name":"GRÜNE","stimmen":"0.10019842182054685307"},{"name":"SPD","stimmen":"0.30520757665230520489"}];
        //$scope.getVoteDistribution();
        //$scope.sitzverteilungData = $scope.getVoteDistribution();
        //$scope.sitzverteilungData = [{"name":"CDU","stimmen":"0.40474430307932882849"},{"name":"CSU","stimmen":"0.08797928534022331969"},{"name":"DIE LINKE","stimmen":"0.10187041310759579387"},{"name":"GRÜNE","stimmen":"0.10019842182054685307"},{"name":"SPD","stimmen":"0.30520757665230520489"}];
        var chartData = [];
                for (var i = 0, l = data.length; i < l; i++) {
                    chartData.push({ c: [ { v: data[i].name }, {v: parseFloat(data[i].stimmen)} ] });
                    console.log( 'yolo: ' + data[i].name + data[i].stimmen);
                }
                console.log(data);
                console.log(chartData);
                $scope.sitzverteilungData = data;
                console.log($scope.sitzverteilungData);
                return $scope.sitzverteilungData;
    };*/

    $scope.sitzverteilungChart = {};
    $scope.sitzverteilungChart.type = "PieChart";
    $scope.sitzverteilungChart.data = {"cols": [
        {id: "t", label: "Topping", type: "string"},
        {id: "s", label: "Slices", type: "number"}
    ], "rows": $scope.getVoteDistribution() };
    $scope.sitzverteilungChart.options = {
        'title': 'Wahlergebnis'
    };

});





