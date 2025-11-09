const axios = require('axios');

const LOCAL_API = 'http://192.168.31.39:3000/api';

async function testLocalLogin() {
  console.log('🔐 Testing login with LOCAL backend (connected to Neon)...\n');
  console.log('📡 API:', LOCAL_API);
  console.log('📧 Email: test.user@hazardnet.com');
  console.log('🔑 Password: Test123!@#\n');
  
  try {
    console.log('⏳ Sending login request...\n');
    
    const startTime = Date.now();
    
    const response = await axios.post(
      `${LOCAL_API}/auth/login`,
      {
        email: 'test.user@hazardnet.com',
        password: 'Test123!@#'
      },
      {
        timeout: 10000,
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
    
    if (error.response) {
      console.error('📦 Status:', error.response.status);
      console.error('📝 Error message:', error.response.data?.message || error.response.data);
    } else if (error.request) {
      console.error('❌ No response from server');
      console.error('💡 Make sure local backend is running on http://192.168.31.39:3000');
    } else {
      console.error('❌ Error:', error.message);
    }
  }
}

testLocalLogin();
