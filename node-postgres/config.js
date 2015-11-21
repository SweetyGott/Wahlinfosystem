var connectionString = process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/db_proj';

module.exports = connectionString;