require('dotenv').config();
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

async function debugLogin() {
  console.log('🔍 Debugging login issue...\n');
  
  try {
    // Check if user exists
    const userResult = await pool.query(
      "SELECT id, email, display_name, password_hash FROM users WHERE email = 'test.user@hazardnet.com'"
    );
    
    if (userResult.rows.length === 0) {
      console.log('❌ User NOT found in database!');
      console.log('💡 Run: node add_test_user.js');
      return;
    }
    
    const user = userResult.rows[0];
    console.log('✅ User found:');
    console.log('   Email:', user.email);
    console.log('   Name:', user.display_name);
    console.log('   ID:', user.id);
    console.log('   Password hash:', user.password_hash.substring(0, 20) + '...\n');
    
    // Test password
    const testPassword = 'Test123!@#';
    console.log('🔐 Testing password:', testPassword);
    
    const isValid = await bcrypt.compare(testPassword, user.password_hash);
    
    if (isValid) {
      console.log('✅ Password is CORRECT!');
      console.log('\n💡 Login should work. Issue might be with API request.');
    } else {
      console.log('❌ Password is INCORRECT!');
      console.log('\n💡 The password hash in database doesn\'t match "Test123!@#"');
      console.log('   Expected hash: $2a$10$vI8aWBnW3fID.ZQ4/zo1G.q1lRps.9cGLcZEiGDMVr5yUP1KUOYTa');
      console.log('   Actual hash:', user.password_hash);
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

debugLogin();
