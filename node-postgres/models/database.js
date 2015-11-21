
var pg = require('pg');
var connectionString = process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/db_proj1';

var client = new pg.Client(connectionString);
client.connect();
var query = client.query('select * from db.sitzeproland2013');
query.on('end', function() { client.end(); });
