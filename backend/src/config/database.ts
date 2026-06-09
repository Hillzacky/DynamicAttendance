import { Pool, PoolConfig } from 'pg';
import knex, { Knex } from 'knex';
import dotenv from 'dotenv';

dotenv.config();

// PostgreSQL Pool Config
const poolConfig: PoolConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'attendance_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  max: parseInt(process.env.DB_POOL_MAX || '20'),
  idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT || '30000'),
  connectionTimeoutMillis: parseInt(process.env.DB_CONN_TIMEOUT || '2000'),
  ssl: process.env.DB_SSL === 'true' ? {
    rejectUnauthorized: false
  } : undefined,
};

// PG Pool Instance
export const pgPool = new Pool(poolConfig);

// Knex Instance
export const db: Knex = knex({
  client: 'postgresql',
  connection: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 'attendance_db',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    ssl: process.env.DB_SSL === 'true' ? {
      rejectUnauthorized: false
    } : undefined,
  },
  pool: {
    min: 2,
    max: parseInt(process.env.DB_POOL_MAX || '20'),
  },
  acquireConnectionTimeout: 10000,
  debug: process.env.NODE_ENV === 'development',
});

// Test Connection
export const testConnection = async (): Promise<void> => {
  try {
    const client = await pgPool.connect();
    const result = await client.query('SELECT NOW()');
    client.release();
    console.log('✅ Database connected:', result.rows.now);
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    process.exit(1);
  }
};

// Graceful Shutdown
export const closeConnection = async (): Promise<void> => {
  await pgPool.end();
  await db.destroy();
  console.log('🔌 Database connections closed');
};