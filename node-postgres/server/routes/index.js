var express = require('express');
var router = express.Router();
var pg = require('pg');
var path = require('path');
//var connectionString = process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/todo';
var connectionString = require(path.join(__dirname, '../', '../', 'config'));

/* GET home page. */
router.get('/', function(req, res, next) {
  res.sendFile(path.join(__dirname, '../', '../', 'client', 'views', 'index.html'));
});



router.post('/api/v1/todos', function(req, res) {

    var results = [];

    // Grab data from http request
    var data = {text: req.body.text, complete: false};

    // Get a Postgres client from the connection pool
    pg.connect(connectionString, function(err, client, done) {
        // Handle connection errors
        if(err) {
          done();
          console.log(err);
          return res.status(500).json({ success: false, data: err});
        }

        // SQL Query > Insert Data
        client.query("INSERT INTO items(text, complete) values($1, $2)", [data.text, data.complete]);

        // SQL Query > Select Data
        var query = client.query("SELECT * FROM items ORDER BY id ASC");

        // Stream results back one row at a time
        query.on('row', function(row) {
            results.push(row);
        });

        // After all data is returned, close connection and return results
        query.on('end', function() {
            done();
            return res.json(results);
        });


    });
});

router.get('/api/v1/todos', function(req, res) {

    var results = [];

    // Get a Postgres client from the connection pool
    pg.connect(connectionString, function(err, client, done) {
        // Handle connection errors
        if(err) {
          done();
          console.log(err);
          return res.status(500).json({ success: false, data: err});
        }

        // SQL Query > Select Data
        var query = client.query("SELECT * FROM items ORDER BY id ASC;");

        // Stream results back one row at a time
        query.on('row', function(row) {
            results.push(row);
        });

        // After all data is returned, close connection and return results
        query.on('end', function() {
            done();
            return res.json(results);
        });

    });

});

router.put('/api/v1/todos/:todo_id', function(req, res) {

    var results = [];

    // Grab data from the URL parameters
    var id = req.params.todo_id;

    // Grab data from http request
    var data = {text: req.body.text, complete: req.body.complete};

    // Get a Postgres client from the connection pool
    pg.connect(connectionString, function(err, client, done) {
        // Handle connection errors
        if(err) {
          done();
          console.log(err);
          return res.status(500).send(json({ success: false, data: err}));
        }

        // SQL Query > Update Data
        client.query("UPDATE items SET text=($1), complete=($2) WHERE id=($3)", [data.text, data.complete, id]);

        // SQL Query > Select Data
        var query = client.query("SELECT * FROM items ORDER BY id ASC");

        // Stream results back one row at a time
        query.on('row', function(row) {
            results.push(row);
        });

        // After all data is returned, close connection and return results
        query.on('end', function() {
            done();
            return res.json(results);
        });
    });

});

router.delete('/api/v1/todos/:todo_id', function(req, res) {

    var results = [];

    // Grab data from the URL parameters
    var id = req.params.todo_id;


    // Get a Postgres client from the connection pool
    pg.connect(connectionString, function(err, client, done) {
        // Handle connection errors
        if(err) {
          done();
          console.log(err);
          return res.status(500).json({ success: false, data: err});
        }

        // SQL Query > Delete Data
        client.query("DELETE FROM items WHERE id=($1)", [id]);

        // SQL Query > Select Data
        var query = client.query("SELECT * FROM items ORDER BY id ASC");

        // Stream results back one row at a time
        query.on('row', function(row) {
            results.push(row);
        });

        // After all data is returned, close connection and return results
        query.on('end', function() {
            done();
            return res.json(results);
        });
    });

});


//GetSitzverteilung
router.get('/api/v1/wahlinfo/:AbfrageID/:jahr/:param', function(req, res) {

    var results = [];

    // Grab data from the URL parameters
    var id = req.params.AbfrageID;
    var jahr = req.params.jahr;
    var param = req.params.param;

    var queryString = "";
    switch( id ) {
        case "stimmverteilung": 
            queryString = "SELECT bt.name, count(bt.name) AS count FROM bundestag" + jahr + " bt GROUP BY bt.name ORDER BY bt.name";
            break;
        case "wahlkreise":
            queryString = "select wk.id, wk.name from wahlkreise wk";
            break;
        case "bundestag":
            queryString = "select * from bundestag" + jahr;
            break;
        case "parteien":
            queryString = "select * from parteien p order by p.name";
            break;
        case "knappstesieger":
            queryString = "select * from knappsteSieger" + jahr + " ks where ks.id =" + param;
            break;
        case "wkuebersichtbeteiligung":
            jahr = jahr.substring(2, 4);
            queryString = "SELECT id, gewählt" + jahr + "*1.0/wähler" + jahr + " AS Wahlbeteiligung FROM wahlkreise WHERE id = " + param
            break;
        case "wkdirektmandat":
            queryString = "SELECT b.titel, b.vorname, b.nachname, b.jahrgang, p.name FROM direktmandate" + jahr + " dm, bewerber b, parteien p WHERE b.id = dm.idbewerber and p.id = fkpartei and idwahlkreis = " + param;
            break;
        case "wkstimmen":
            var jahrshort = jahr.substring(2, 4);
            queryString =   "SELECT  p.Name, stimmen AS StimmenAbs, stimmen*1.0/gewählt" + jahrshort + " AS StimmenRel " +
                            "FROM ergebnissezweit ez JOIN parteien p ON p.id = fkpartei JOIN wahlkreise wk ON wk.id = ez.fkwahlkreis " +
                            "WHERE jahr = " + jahr + " AND ez.fkwahlkreis = " + param +
                            " ORDER BY stimmenrel desc";
            break;
        case "wkdifference":
            queryString =   "SELECT p.name, ez1.stimmen-coalesce(ez2.stimmen, 0) AS veraenderungAbs FROM ergebnissezweit ez1 " + 
                            "LEFT JOIN ergebnissezweit ez2 ON ez1.fkwahlkreis = ez2.fkwahlkreis AND ez1.fkpartei = ez2.fkpartei JOIN parteien p ON p.id = ez1.fkpartei " +
                            "WHERE ez1.jahr = 2013 AND ez2.jahr = 2009 AND ez1.fkwahlkreis = " + param;
            break;
        default: break;
    };
    console.log("String succesfully parsed: " +  queryString);

    // Get a Postgres client from the connection pool
    pg.connect(connectionString, function(err, client, done) {
        // Handle connection errors
        if(err) {
          done();
          console.log(err);
          return res.status(500).json({ success: false, data: err});
        }

        // SQL Query > Select Data
        var query = client.query( queryString );

        // Stream results back one row at a time
        query.on('row', function(row) {
            results.push(row);
        });

        // After all data is returned, close connection and return results
        query.on('end', function() {
            done();
            return res.json(results);
        });

    });

});




module.exports = router;
