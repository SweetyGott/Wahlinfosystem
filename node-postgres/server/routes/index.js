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


/*******************************************************************************************/

/************************************** ÜBERSICHT ******************************************/

/*******************************************************************************************/
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
            queryString = "select wk.id, wk.name from wahlkreise wk where wk.fkbundesland = " + param;
            break;
        case "bundestag":
            queryString = "select * from bundestag" + jahr;
            break;
        case "parteien":
            //queryString = "select * from parteien p order by p.name";
            queryString =   "with parties as ( select distinct fkpartei from ergebnissezweit where jahr = " + jahr + " group by fkpartei " +
                            "union all " + 
                            "select distinct b.fkpartei from ergebnisseerst ee, bewerber b where ee.fkbewerber = b.id and ee.jahr = " + jahr + " group by fkpartei) " +
                            "select distinct p.id, p.name from parties p1, parteien p where p.id = p1.fkpartei";
            break;
        case "bundeslaender":
            queryString = "select * from bundesländer";
            break;
        case "knappstesieger":
            queryString = "select * from closest" + jahr + " ks where ks.id =" + param;
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
        case "ueberhangmandate":
            queryString =   "SELECT * " +
                            "FROM ( SELECT s.partei_id, p.name, sum(m.greatest-s.sitze) AS ueberhangmandate " +
                            "       FROM minsitzeproland" + jahr + " m JOIN generaterealSitzeProland" + jahr + "() s ON s.bl_id = m.bl_id AND m.partei_id = s.partei_id JOIN parteien p ON p.id = s.partei_id" +
                            "       GROUP BY s.partei_id, p.id) a " +
                            "WHERE a.ueberhangmandate > 0";
            break;
        case "wahlkreissieger":
            queryString =   "select * from wahlkreissieger" + jahr;
            break;
        default: break;
    };

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





/*******************************************************************************************/

/************************************** Stimmabgabe ******************************************/

/*******************************************************************************************/
/**Log In**/
router.get('/api/v1/vote/:AbfrageID/:param', function(req, res) {

    var results = [];
    var id = req.params.AbfrageID;
    var param = req.params.param;
    

    var queryString = "";
    switch( id ) {
        case "login": 
            var wk = param.substring(0,3)
            var token = param.substring(3);
            queryString = "select * from token t where t.wk_id = " + wk + " and t.token_id = " + token;
            break;
        case "geterst":
            queryString =   "select b.id, b.titel, b.vorname, b.nachname, b.jahrgang,p.name " +
                            "from bewerber b , parteien p " +
                            "where b.jahrbewerbung = 2013 and b.fkwahlkreis = " + param + " and p.id = b.fkpartei";
            break;
        case "getzweit":
            queryString =   "select p.id, p.name " +
                            "from landeslisten l , parteien p, wahlkreise wk " +
                            "where l.jahr = 2013 and " +
                            "wk.id = " + param + " and l.fkbundesland = wk.fkbundesland and wk.fkbundesland = l.fkbundesland and p.id = l.fkpartei";
            break;
        default: break;
    };
    
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


/**Give Vote**/
router.post('/api/v1/vote/giveVote/:authkey/:voteerst/:votezweit', function(req, res) {

    var results = [];
    var authkey = req.params.authkey;
    var wk = authkey.substring(0,3)
    var token = authkey.substring(3);
    var voteerst = req.params.voteerst;
    var votezweit = req.params.votezweit;

    // Get a Postgres client from the connection pool
    pg.connect(connectionString, function(err, client, done) {
        // Handle connection errors
        if(err) {
          done();
          console.log(err);
          return res.status(500).json({ success: false, data: err});
        }

        // SQL Query > Insert Data
        var query = client.query("SELECT insertstimme($1, $2, $3, $4);", [wk, token, voteerst, votezweit]);

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














































/*tbdeleted*/
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
/* End to be deleted*/




module.exports = router;
