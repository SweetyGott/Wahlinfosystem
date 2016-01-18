var connectionString = process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5433/db_proj';

module.exports = connectionString;