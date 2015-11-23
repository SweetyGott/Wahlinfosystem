angular.module('nodeTodo', ['googlechart'])
//angular.module('nodeTodo', ['chart.js'])
//angular.module('nodeTodo', ["googlechart", "googlechart-docs"])

.controller('MainController', function($scope, $http) {

    $scope.formData = {};
    $scope.todoData = {};

    //$scope.sitzverteilungData = {};

    //Data GoogleChart
    /*
    $scope.chartObject = {};    
    $scope.chartObject.type = "PieChart";
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
    */

    $scope.chartObject = {
        "type": "AreaChart",
        "displayed": false,
        "data": {
            "cols": [
                {
                    "id": "month",
                    "label": "Month",
                    "type": "string",
                    "p": {}
                },
                {
                    "id": "laptop-id",
                    "label": "Laptop",
                    "type": "number",
                    "p": {}
                },
                {
                    "id": "desktop-id",
                    "label": "Desktop",
                    "type": "number",
                    "p": {}
                },
                {
                    "id": "server-id",
                    "label": "Server",
                    "type": "number",
                    "p": {}
                },
                {
                    "id": "cost-id",
                    "label": "Shipping",
                    "type": "number"
                }
            ],
            "rows": [
                {
                    "c": [
                        {
                            "v": "January"
                        },
                        {
                            "v": 19,
                            "f": "42 items"
                        },
                        {
                            "v": 12,
                            "f": "Ony 12 items"
                        },
                        {
                            "v": 7,
                            "f": "7 servers"
                        },
                        {
                            "v": 4
                        }
                    ]
                },
                {
                    "c": [
                        {
                            "v": "February"
                        },
                        {
                            "v": 13
                        },
                        {
                            "v": 1,
                            "f": "1 unit (Out of stock this month)"
                        },
                        {
                            "v": 12
                        },
                        {
                            "v": 2
                        }
                    ]
                },
                {
                    "c": [
                        {
                            "v": "March"
                        },
                        {
                            "v": 24
                        },
                        {
                            "v": 5
                        },
                        {
                            "v": 11
                        },
                        {
                            "v": 6
                        }
                    ]
                }
            ]
        },
        "options": {
            "title": "Sales per month",
            "isStacked": "true",
            "fill": 20,
            "displayExactValues": true,
            "vAxis": {
                "title": "Sales unit",
                "gridlines": {
                    "count": 10
                }
            },
            "hAxis": {
                "title": "Date"
            }
        },
        "formatters": {}
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
    // $scope.initView();


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
    /*$scope.getVoteDistribution = function() {
        $http.get('/api/v1/stimmverteilung')
            .success(function(data) {
                $scope.sitzverteilungData = data;
                console.log(data);
                return data;
            })
            .error(function(data) {
                console.log('Error: ' + data);
            });
    };*/

});





