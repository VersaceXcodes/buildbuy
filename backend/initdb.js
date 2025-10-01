import dotenv from "dotenv";
import fs from "fs";
import pg from 'pg';
const { Pool } = pg;

dotenv.config();

const { DATABASE_URL, PGHOST, PGDATABASE, PGUSER, PGPASSWORD, PGPORT = 5432 } = process.env;

const pool = new Pool(
  DATABASE_URL
    ? { 
        connectionString: DATABASE_URL, 
        ssl: { require: true } 
      }
    : {
        host: PGHOST || "ep-ancient-dream-abbsot9k-pooler.eu-west-2.aws.neon.tech",
        database: PGDATABASE || "neondb",
        user: PGUSER || "neondb_owner",
        password: PGPASSWORD || "npg_jAS3aITLC5DX",
        port: Number(PGPORT),
        ssl: { require: true },
      }
);


async function initDb() {
  const client = await pool.connect();
  try {
    // Check if database is already initialized
    const checkResult = await client.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'users'
      );
    `);
    const dbExists = checkResult.rows[0].exists;
    
    if (dbExists) {
      console.log('Database already initialized. Skipping initialization.');
      return;
    }
    
    // Begin transaction
    await client.query('BEGIN');
    
    // Read and split SQL commands
    const sqlContent = fs.readFileSync(`./db.sql`, "utf-8").toString();
    const dbInitCommands = sqlContent.split(/(?=CREATE TABLE IF NOT EXISTS|INSERT INTO|ALTER TABLE)/g);

    // Execute each command
    for (let cmd of dbInitCommands) {
      const trimmedCmd = cmd.trim();
      if (!trimmedCmd) continue;
      
      console.dir({ "backend:db:init:command": trimmedCmd.substring(0, 100) + '...' });
      try {
        await client.query(trimmedCmd);
      } catch (err) {
        // Log but continue for some safe-to-ignore errors
        if (err.code === '42P07') {
          console.log('Table already exists, continuing...');
        } else if (err.code === '42710') {
          console.log('Object already exists, continuing...');
        } else {
          throw err;
        }
      }
    }

    // Commit transaction
    await client.query('COMMIT');
    console.log('Database initialization completed successfully');
  } catch (e) {
    // Rollback on error
    try {
      await client.query('ROLLBACK');
    } catch (rollbackErr) {
      console.error('Rollback failed:', rollbackErr);
    }
    console.error('Database initialization failed:', e);
    throw e;
  } finally {
    // Release client back to pool
    client.release();
  }
}

// Execute initialization
initDb().catch(console.error);
