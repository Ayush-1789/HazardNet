require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

async function addTestUser() {
  console.log('🔄 Adding test user to Neon database...\n');
  
  try {
    // Check if user already exists
    const existingUser = await pool.query(
      "SELECT email FROM users WHERE email = 'test.user@hazardnet.com'"
    );
    
    if (existingUser.rows.length > 0) {
      console.log('⚠️  Test user already exists!');
      return;
    }
    
    // Add test user with bcrypt password hash for "Test123!@#"
    const result = await pool.query(`
      INSERT INTO users (
        id, 
        email, 
        password_hash, 
        display_name, 
        phone_number, 
        created_at, 
        updated_at
      ) VALUES (
        '55555555-5555-5555-5555-555555555555',
        'test.user@hazardnet.com',
        '$2a$10$vI8aWBnW3fID.ZQ4/zo1G.q1lRps.9cGLcZEiGDMVr5yUP1KUOYTa',
        'Test User',
        '+91-9876543210',
        NOW(),
        NOW()
      )
      RETURNING id, email, display_name
    `);
    
    console.log('✅ Test user added successfully!\n');
    console.log('📧 Email:', result.rows[0].email);
    console.log('👤 Name:', result.rows[0].display_name);
    console.log('🔑 Password: Test123!@#');
    console.log('\n✨ You can now login with these credentials!');
    
  } catch (error) {
    console.error('❌ Error adding test user:', error.message);
  } finally {
    await pool.end();
  }
}

addTestUser();
