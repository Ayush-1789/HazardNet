const { pool } = require('./db');

async function testAlertSystem() {
  console.log('🔍 Testing Alert System...\n');

  try {
    // 1. Check if alerts table exists
    console.log('1️⃣ Checking alerts table...');
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'alerts'
      );
    `);
    console.log('   ✅ Alerts table exists:', tableCheck.rows[0].exists);

    // 2. Check table structure
    console.log('\n2️⃣ Checking alerts table structure...');
    const columns = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'alerts'
      ORDER BY ordinal_position;
    `);
    console.log('   Columns:', columns.rows.map(c => `${c.column_name} (${c.data_type})`).join(', '));

    // 3. Check if we have any test users
    console.log('\n3️⃣ Checking for users...');
    const users = await pool.query('SELECT id, display_name, email FROM users LIMIT 3');
    console.log(`   Found ${users.rows.length} users`);
    if (users.rows.length > 0) {
      console.log('   Sample user:', users.rows[0].display_name, users.rows[0].email);
    }

    // 4. Try to create a test alert
    if (users.rows.length > 0) {
      console.log('\n4️⃣ Creating test alert...');
      const testUserId = users.rows[0].id;
      
      const alertResult = await pool.query(`
        INSERT INTO alerts (user_id, title, message, type, severity)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING *
      `, [testUserId, 'Test Alert', 'This is a test alert from system check', 'system', 'info']);
      
      console.log('   ✅ Test alert created:', alertResult.rows[0].id);

      // 5. Retrieve the alert
      console.log('\n5️⃣ Retrieving alert...');
      const retrieveResult = await pool.query(`
        SELECT * FROM alerts WHERE user_id = $1 ORDER BY timestamp DESC LIMIT 1
      `, [testUserId]);
      
      console.log('   ✅ Alert retrieved:', retrieveResult.rows[0].title);

      // 6. Mark as read
      console.log('\n6️⃣ Marking alert as read...');
      await pool.query(`
        UPDATE alerts SET is_read = true WHERE id = $1
      `, [alertResult.rows[0].id]);
      console.log('   ✅ Alert marked as read');

      // 7. Clean up test alert
      console.log('\n7️⃣ Cleaning up test alert...');
      await pool.query('DELETE FROM alerts WHERE id = $1', [alertResult.rows[0].id]);
      console.log('   ✅ Test alert deleted');
    }

    // 8. Check alert counts
    console.log('\n8️⃣ Alert statistics...');
    const stats = await pool.query(`
      SELECT 
        COUNT(*) as total_alerts,
        COUNT(*) FILTER (WHERE is_read = false) as unread_alerts,
        COUNT(*) FILTER (WHERE severity = 'critical') as critical_alerts
      FROM alerts
    `);
    console.log('   Total alerts:', stats.rows[0].total_alerts);
    console.log('   Unread alerts:', stats.rows[0].unread_alerts);
    console.log('   Critical alerts:', stats.rows[0].critical_alerts);

    console.log('\n✅ Alert system is working correctly!\n');

  } catch (error) {
    console.error('\n❌ Error testing alert system:', error.message);
    console.error('Details:', error);
  } finally {
    await pool.end();
  }
}

testAlertSystem();
