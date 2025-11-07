// ================================================================
// NEON POSTGRESQL CONNECTION TEST
// Version: 1.0.0
// Description: Test database connection and verify schema
// ================================================================

const { Client } = require('pg');

// ANSI color codes for terminal output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[36m',
  bold: '\x1b[1m'
};

// Database connection configuration
const config = {
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false // Required for Neon
  }
};

/**
 * Test basic database connection
 */
async function testConnection() {
  const client = new Client(config);
  
  try {
    console.log(`${colors.blue}${colors.bold}🔌 Testing database connection...${colors.reset}`);
    await client.connect();
    console.log(`${colors.green}✅ Successfully connected to Neon PostgreSQL!${colors.reset}\n`);
    return client;
  } catch (error) {
    console.error(`${colors.red}❌ Connection failed:${colors.reset}`, error.message);
    throw error;
  }
}

/**
 * Verify database schema exists
 */
async function verifySchema(client) {
  console.log(`${colors.blue}${colors.bold}📊 Verifying database schema...${colors.reset}`);
  
  const schemaQuery = `
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    ORDER BY table_name;
  `;
  
  try {
    const result = await client.query(schemaQuery);
    const tables = result.rows.map(row => row.table_name);
    
    if (tables.length === 0) {
      console.log(`${colors.yellow}⚠️  No tables found. Run schema.sql first!${colors.reset}\n`);
      return false;
    }
    
    console.log(`${colors.green}✅ Found ${tables.length} tables:${colors.reset}`);
    tables.forEach(table => console.log(`   - ${table}`));
    console.log('');
    return true;
  } catch (error) {
    console.error(`${colors.red}❌ Schema verification failed:${colors.reset}`, error.message);
    return false;
  }
}

/**
 * Check for seed data
 */
async function checkSeedData(client) {
  console.log(`${colors.blue}${colors.bold}🌱 Checking for seed data...${colors.reset}`);
  
  const queries = [
    { name: 'Users', query: 'SELECT COUNT(*) FROM users' },
    { name: 'Hazards', query: 'SELECT COUNT(*) FROM hazards' },
    { name: 'Alerts', query: 'SELECT COUNT(*) FROM alerts' }
  ];
  
  try {
    for (const { name, query } of queries) {
      const result = await client.query(query);
      const count = parseInt(result.rows[0].count);
      
      if (count > 0) {
        console.log(`${colors.green}✅ ${name}: ${count} records${colors.reset}`);
      } else {
        console.log(`${colors.yellow}⚠️  ${name}: No records (run seed_data.sql)${colors.reset}`);
      }
    }
    console.log('');
  } catch (error) {
    console.error(`${colors.red}❌ Data check failed:${colors.reset}`, error.message);
  }
}

/**
 * Test a sample query
 */
async function testQuery(client) {
  console.log(`${colors.blue}${colors.bold}🔍 Testing sample query...${colors.reset}`);
  
  const testQuery = `
    SELECT 
      h.type,
      h.severity,
      h.latitude,
      h.longitude,
      h.reported_by_name,
      h.verification_count
    FROM hazards h
    WHERE h.is_active = TRUE
    ORDER BY h.detected_at DESC
    LIMIT 5;
  `;
  
  try {
    const result = await client.query(testQuery);
    
    if (result.rows.length > 0) {
      console.log(`${colors.green}✅ Query successful! Recent hazards:${colors.reset}`);
      result.rows.forEach((row, index) => {
        console.log(`   ${index + 1}. ${row.type} (${row.severity}) at (${row.latitude}, ${row.longitude})`);
        console.log(`      Reported by: ${row.reported_by_name || 'Unknown'} | Verifications: ${row.verification_count}`);
      });
    } else {
      console.log(`${colors.yellow}⚠️  No hazards found in database${colors.reset}`);
    }
    console.log('');
  } catch (error) {
    console.error(`${colors.red}❌ Query test failed:${colors.reset}`, error.message);
  }
}

/**
 * Test database functions
 */
async function testFunctions(client) {
  console.log(`${colors.blue}${colors.bold}⚙️  Testing database functions...${colors.reset}`);
  
  const distanceQuery = `
    SELECT calculate_distance(28.6139, 77.2090, 19.0760, 72.8777) AS distance_km;
  `;
  
  try {
    const result = await client.query(distanceQuery);
    const distance = parseFloat(result.rows[0].distance_km).toFixed(2);
    console.log(`${colors.green}✅ Distance calculation function works!${colors.reset}`);
    console.log(`   Delhi to Mumbai: ${distance} km\n`);
  } catch (error) {
    console.error(`${colors.red}❌ Function test failed:${colors.reset}`, error.message);
  }
}

/**
 * Display connection information
 */
function displayConnectionInfo() {
  console.log(`${colors.blue}${colors.bold}📋 Connection Information:${colors.reset}`);
  
  if (!process.env.DATABASE_URL) {
    console.log(`${colors.red}❌ DATABASE_URL environment variable not set!${colors.reset}\n`);
    console.log(`${colors.yellow}ℹ️  Create a .env file with:${colors.reset}`);
    console.log(`   DATABASE_URL=postgresql://[user]:[password]@[host]/[database]?sslmode=require\n`);
    return false;
  }
  
  // Parse connection string (hide password)
  try {
    const url = new URL(process.env.DATABASE_URL);
    console.log(`   Host: ${url.hostname}`);
    console.log(`   Database: ${url.pathname.substring(1)}`);
    console.log(`   User: ${url.username}`);
    console.log(`   SSL: Enabled\n`);
    return true;
  } catch (error) {
    console.log(`${colors.red}❌ Invalid DATABASE_URL format${colors.reset}\n`);
    return false;
  }
}

/**
 * Main test runner
 */
async function main() {
  console.log(`\n${'='.repeat(60)}`);
  console.log(`${colors.bold}  🚗 HAZARDNET DATABASE CONNECTION TEST 🚗${colors.reset}`);
  console.log(`${'='.repeat(60)}\n`);
  
  // Check environment variable
  if (!displayConnectionInfo()) {
    process.exit(1);
  }
  
  let client;
  
  try {
    // Test connection
    client = await testConnection();
    
    // Run verification tests
    const hasSchema = await verifySchema(client);
    
    if (hasSchema) {
      await checkSeedData(client);
      await testQuery(client);
      await testFunctions(client);
    }
    
    console.log(`${'='.repeat(60)}`);
    console.log(`${colors.green}${colors.bold}🎉 All tests completed successfully!${colors.reset}`);
    console.log(`${'='.repeat(60)}\n`);
    
  } catch (error) {
    console.error(`\n${colors.red}${colors.bold}❌ Test suite failed!${colors.reset}`);
    console.error(`${colors.red}Error: ${error.message}${colors.reset}\n`);
    process.exit(1);
  } finally {
    if (client) {
      await client.end();
    }
  }
}

// Run tests
if (require.main === module) {
  main();
}

module.exports = { testConnection, verifySchema, checkSeedData };
