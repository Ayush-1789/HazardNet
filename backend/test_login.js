const axios = require('axios');

const RAILWAY_API = 'https://hazardnet-production.up.railway.app/api';

async function testLogin() {
  console.log('🔐 Testing login with Railway backend...\n');
  console.log('📡 API:', RAILWAY_API);
  console.log('📧 Email: test.user@hazardnet.com');
  console.log('🔑 Password: Test123!@#\n');
  
  try {
    console.log('⏳ Sending login request (may take 30-60s if Railway is waking up)...\n');
    
    const startTime = Date.now();
    
    const response = await axios.post(
      `${RAILWAY_API}/auth/login`,
      {
        email: 'test.user@hazardnet.com',
        password: 'Test123!@#'
      },
      {
        timeout: 65000, // 65 second timeout for Railway wake-up
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );
    
    const responseTime = Date.now() - startTime;
    
    console.log('✅ LOGIN SUCCESSFUL! 🎉\n');
    console.log('⏱️  Response time:', responseTime + 'ms');
    console.log('📦 Status:', response.status);
    console.log('\n📝 Response data:');
    console.log(JSON.stringify(response.data, null, 2));
    
    if (response.data.token) {
      console.log('\n🎫 JWT Token received!');
      console.log('Token preview:', response.data.token.substring(0, 50) + '...');
    }
    
    if (response.data.user) {
      console.log('\n👤 User details:');
      console.log('   Name:', response.data.user.displayName || response.data.user.display_name);
      console.log('   Email:', response.data.user.email);
      console.log('   ID:', response.data.user.id);
    }
    
  } catch (error) {
    console.error('❌ LOGIN FAILED!\n');
    
    if (error.code === 'ECONNABORTED') {
      console.error('⏱️  Timeout: Server took too long to respond (>65s)');
      console.error('💡 Railway might be sleeping or having issues');
    } else if (error.response) {
      console.error('📦 Status:', error.response.status);
      console.error('📝 Error message:', error.response.data?.message || error.response.data);
      
      if (error.response.status === 401) {
        console.error('\n🔍 Possible reasons:');
        console.error('   1. User not found in Railway database');
        console.error('   2. Incorrect password');
        console.error('   3. Railway not connected to Neon database');
        console.error('\n💡 Tip: Railway must be redeployed after changing DATABASE_URL');
      }
    } else if (error.request) {
      console.error('❌ No response from server');
      console.error('💡 Check if Railway backend is running');
    } else {
      console.error('❌ Error:', error.message);
    }
  }
}

testLogin();
