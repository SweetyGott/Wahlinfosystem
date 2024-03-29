var pg = require('pg');
var path = require('path');

//var connectionString = process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/todo';
var connectionString = require(path.join(__dirname, '../', '../', 'config'));

var client = new pg.Client(connectionString);
client.connect();
var query = client.query('CREATE TABLE items(id SERIAL PRIMARY KEY, text VARCHAR(40) not null, complete BOOLEAN)');
query.on('end', function() { client.end(); });
