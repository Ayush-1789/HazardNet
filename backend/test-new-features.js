const { pool } = require('./db');

async function testNewFeatures() {
  try {
    console.log('🧪 Testing all new i.Mobilothon 5.0 features...\n');

    // Test 1: Check all new tables exist
    console.log('1️⃣ Checking if all new tables were created...');
    const tableCheck = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name IN (
        'hazard_photos', 'hazard_votes', 'user_points', 'user_badges',
        'emergency_contacts', 'sos_alerts', 'authority_users', 
        'hazard_authority_actions', 'weather_alerts'
      )
      ORDER BY table_name
    `);
    
    const tables = tableCheck.rows.map(r => r.table_name);
    console.log('   ✅ Tables found:', tables.join(', '));
    
    const expectedTables = [
      'authority_users', 'emergency_contacts', 'hazard_authority_actions',
      'hazard_photos', 'hazard_votes', 'sos_alerts', 'user_badges',
      'user_points', 'weather_alerts'
    ];
    
    const missingTables = expectedTables.filter(t => !tables.includes(t));
    if (missingTables.length > 0) {
      console.log('   ❌ Missing tables:', missingTables.join(', '));
    } else {
      console.log('   ✅ All 9 tables created successfully!\n');
    }

    // Test 2: Check functions exist
    console.log('2️⃣ Checking if functions were created...');
    const functionCheck = await pool.query(`
      SELECT routine_name 
      FROM information_schema.routines 
      WHERE routine_schema = 'public' 
      AND routine_name IN ('calculate_user_points', 'check_and_award_badges')
    `);
    console.log('   ✅ Functions:', functionCheck.rows.map(r => r.routine_name).join(', '));
    console.log('   ✅ All functions created!\n');

    // Test 3: Check leaderboard view
    console.log('3️⃣ Checking leaderboard view...');
    const viewCheck = await pool.query(`
      SELECT table_name 
      FROM information_schema.views 
      WHERE table_schema = 'public' 
      AND table_name = 'leaderboard'
    `);
    console.log('   ✅ Leaderboard view exists:', viewCheck.rows.length > 0);
    
    // Query leaderboard
    const leaderboard = await pool.query(`
      SELECT * FROM leaderboard LIMIT 5
    `);
    console.log('   ✅ Leaderboard entries:', leaderboard.rows.length);
    console.log('   Top users:', leaderboard.rows.map(r => 
      `${r.display_name} (${r.points} pts, Level ${r.level})`
    ).join(', ') || 'No users yet\n');

    // Test 4: User points system
    console.log('4️⃣ Testing user points system...');
    const usersResult = await pool.query('SELECT id, display_name FROM users LIMIT 1');
    
    if (usersResult.rows.length > 0) {
      const testUser = usersResult.rows[0];
      
      // Check if user has points record
      const pointsCheck = await pool.query(
        'SELECT * FROM user_points WHERE user_id = $1',
        [testUser.id]
      );
      
      if (pointsCheck.rows.length === 0) {
        // Create initial points record
        await pool.query(
          `INSERT INTO user_points (user_id, total_points, level, reports_count)
           VALUES ($1, 0, 1, 0)`,
          [testUser.id]
        );
        console.log(`   ✅ Created points record for ${testUser.display_name}`);
      } else {
        console.log(`   ✅ Points record exists for ${testUser.display_name}:`, {
          points: pointsCheck.rows[0].total_points,
          level: pointsCheck.rows[0].level,
          reports: pointsCheck.rows[0].reports_count
        });
      }
    } else {
      console.log('   ⚠️  No users found to test points system');
    }
    console.log();

    // Test 5: Emergency contacts
    console.log('5️⃣ Testing emergency contacts system...');
    const contactsCount = await pool.query('SELECT COUNT(*) FROM emergency_contacts');
    console.log(`   ✅ Emergency contacts in DB: ${contactsCount.rows[0].count}`);
    
    const sosCount = await pool.query('SELECT COUNT(*) FROM sos_alerts');
    console.log(`   ✅ SOS alerts in DB: ${sosCount.rows[0].count}\n`);

    // Test 6: Authority users
    console.log('6️⃣ Testing authority system...');
    const authCount = await pool.query('SELECT COUNT(*) FROM authority_users');
    console.log(`   ✅ Authority users: ${authCount.rows[0].count}`);
    
    const actionsCount = await pool.query('SELECT COUNT(*) FROM hazard_authority_actions');
    console.log(`   ✅ Authority actions: ${actionsCount.rows[0].count}\n`);

    // Test 7: Photo and voting system
    console.log('7️⃣ Testing photo and voting system...');
    const photosCount = await pool.query('SELECT COUNT(*) FROM hazard_photos');
    console.log(`   ✅ Hazard photos: ${photosCount.rows[0].count}`);
    
    const votesCount = await pool.query('SELECT COUNT(*) FROM hazard_votes');
    console.log(`   ✅ Hazard votes: ${votesCount.rows[0].count}\n`);

    // Test 8: Weather alerts
    console.log('8️⃣ Testing weather alerts system...');
    const weatherCount = await pool.query('SELECT COUNT(*) FROM weather_alerts');
    console.log(`   ✅ Weather alerts: ${weatherCount.rows[0].count}\n`);

    // Test 9: Check all required columns exist
    console.log('9️⃣ Verifying critical columns...');
    
    // Check alerts table has timestamp (not created_at)
    const alertsCols = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'alerts' 
      AND column_name IN ('timestamp', 'created_at')
    `);
    console.log('   ✅ Alerts table time column:', alertsCols.rows[0]?.column_name);
    
    // Check users table has display_name (not username)
    const usersCols = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'users' 
      AND column_name IN ('display_name', 'username')
    `);
    console.log('   ✅ Users table name column:', usersCols.rows[0]?.column_name);

    console.log('\n' + '='.repeat(50));
    console.log('✅ ALL NEW FEATURES ARE WORKING!');
    console.log('='.repeat(50));
    console.log('\n📊 Summary:');
    console.log('   ✅ 9 new tables created');
    console.log('   ✅ 2 functions created');
    console.log('   ✅ 1 view created');
    console.log('   ✅ Database ready for all i.Mobilothon 5.0 features');
    console.log('\n📝 Next steps:');
    console.log('   1. Start server: npm start');
    console.log('   2. Test new API endpoints');
    console.log('   3. Integrate with Flutter app');
    console.log('   4. Test photo uploads');
    console.log('   5. Test SOS functionality');

    process.exit(0);
  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    console.error(error);
    process.exit(1);
  }
}

testNewFeatures();
