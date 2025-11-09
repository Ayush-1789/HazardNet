require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function checkDatabase() {
  try {
    console.log('🔍 Connecting to Neon database...\n');
    
    // Count records
    const users = await pool.query('SELECT COUNT(*) FROM users');
    const hazards = await pool.query('SELECT COUNT(*) FROM hazards');
    const alerts = await pool.query('SELECT COUNT(*) FROM alerts');
    
    console.log('=== NEON DATABASE STATUS ===');
    console.log('👥 Users:', users.rows[0].count);
    console.log('⚠️  Hazards:', hazards.rows[0].count);
    console.log('🔔 Alerts:', alerts.rows[0].count);
    
    // Show recent hazards
    console.log('\n=== RECENT HAZARDS (Last 6) ===');
    const recent = await pool.query(
      'SELECT id, type, severity, latitude, longitude, created_at FROM hazards ORDER BY created_at DESC LIMIT 6'
    );
    
    if (recent.rows.length === 0) {
      console.log('❌ No hazards found in database');
    } else {
      recent.rows.forEach((h, i) => {
        console.log(`${i+1}. ${h.type.toUpperCase()} - ${h.severity} severity`);
        console.log(`   Location: ${h.latitude}, ${h.longitude}`);
        console.log(`   Created: ${new Date(h.created_at).toLocaleString()}`);
        console.log('');
      });
    }
    
    // Check for test user
    console.log('=== TEST USER STATUS ===');
    const testUser = await pool.query(
      "SELECT id, email, display_name, password_hash IS NOT NULL as has_password FROM users WHERE email = 'test.user@hazardnet.com'"
    );
    
    if (testUser.rows.length > 0) {
      const user = testUser.rows[0];
      console.log('✅ Test user exists:');
      console.log('   Email:', user.email);
      console.log('   Name:', user.display_name);
      console.log('   Has password:', user.has_password ? 'Yes' : 'No');
    } else {
      console.log('❌ Test user NOT found in database');
    }
    
    await pool.end();
    console.log('\n✅ Connection closed');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error('Full error:', error);
    await pool.end();
  }
}

checkDatabase();
