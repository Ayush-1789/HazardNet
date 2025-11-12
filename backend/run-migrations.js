const { pool } = require('./db');
const fs = require('fs');
const path = require('path');

async function runMigrations() {
  try {
    console.log('📚 Reading schema file...');
    const schemaSQL = fs.readFileSync(
      path.join(__dirname, 'database', 'schema.sql'),
      'utf8'
    );

    console.log('🔄 Running schema...');
    await pool.query(schemaSQL);

    console.log('📚 Reading migrations file...');
    const migrationSQL = fs.readFileSync(
      path.join(__dirname, 'database', 'migrations.sql'),
      'utf8'
    );

    console.log('🔄 Running migrations...');
    await pool.query(migrationSQL);

    console.log('✅ Migrations completed successfully!');
    console.log('\nNew tables created:');
    console.log('  - hazard_photos');
    console.log('  - hazard_votes');
    console.log('  - user_points');
    console.log('  - user_badges');
    console.log('  - emergency_contacts');
    console.log('  - sos_alerts');
    console.log('  - authority_users');
    console.log('  - hazard_authority_actions');
    console.log('  - weather_alerts');
    console.log('\nNew functions created:');
    console.log('  - calculate_user_points()');
    console.log('  - check_and_award_badges()');
    console.log('\nNew views created:');
    console.log('  - leaderboard');

    // process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    console.error(error);
    // process.exit(1); // Remove to not kill server
  }
}

module.exports = { runMigrations };
