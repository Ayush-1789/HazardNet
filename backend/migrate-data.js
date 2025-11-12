const { Pool } = require('pg');

// Neon connection
const neonPool = new Pool({
  connectionString: 'postgresql://neondb_owner:npg_qD9xQKlUm1io@ep-purple-forest-a8zm9xmt-pooler.eastus2.azure.neon.tech/neondb?sslmode=require'
});

// RDS connection from env
const rdsPool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

const tables = [
  'users'
  // 'hazards',
  // 'alerts',
  // 'trip_sessions',
  // 'sensor_data',
  // 'hazard_verifications',
  // 'hazard_photos',
  // 'hazard_votes',
  // 'user_points',
  // 'user_badges',
  // 'leaderboard',
  // 'emergency_contacts',
  // 'sos_alerts',
  // 'authority_users',
  // 'hazard_authority_actions',
  // 'weather_alerts',
  // 'maintenance_logs',
  // 'api_keys',
  // 'active_hazards_view',
  // 'user_stats_view'
];

async function migrateData() {
  console.log('Starting data migration from Neon to RDS...');
  try {
    console.log('Connecting to Neon...');
    const testNeon = await neonPool.query('SELECT 1');
    console.log('Neon connected');
    console.log('Connecting to RDS...');
    const testRds = await rdsPool.query('SELECT 1');
    console.log('RDS connected');
    console.log('Starting data migration from Neon to RDS...');

    for (const table of tables) {
      console.log(`Migrating table: ${table}`);

      // Skip views
      if (table.includes('_view')) {
        console.log(`Skipping view: ${table}`);
        continue;
      }

      // Get data from Neon
      const { rows } = await neonPool.query(`SELECT * FROM ${table}`);
      
      if (rows.length === 0) {
        console.log(`No data in ${table}`);
        continue;
      }

      // Clear RDS table
      await rdsPool.query(`DELETE FROM ${table}`);

      // Insert data to RDS
      const columns = Object.keys(rows[0]);
      const values = rows.map(row => `(${columns.map(col => {
        const val = row[col];
        if (val === null) return 'NULL';
        if (typeof val === 'string') return `'${val.replace(/'/g, "''")}'`;
        if (val instanceof Date) return `'${val.toISOString()}'`;
        if (typeof val === 'boolean') return val ? 'true' : 'false';
        return val;
      }).join(', ')})`);

      const insertQuery = `INSERT INTO ${table} (${columns.join(', ')}) VALUES ${values.join(', ')}`;
      
      await rdsPool.query(insertQuery);
      console.log(`Migrated ${rows.length} rows to ${table}`);
    }

    console.log('Data migration completed!');
  } catch (error) {
    console.error('Migration failed:', error);
  } finally {
    await neonPool.end();
    await rdsPool.end();
  }
}

module.exports = { migrateData };

// Run migration if called directly
if (require.main === module) {
  migrateData();
}