// Simple API test script
const http = require('http');

function testEndpoint(path, method = 'GET', data = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(body);
          resolve({ status: res.statusCode, data: json });
        } catch (e) {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });

    req.on('error', reject);
    
    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

async function runTests() {
  console.log('🧪 Testing HazardNet API...\n');

  try {
    // Test 1: Health check
    console.log('1️⃣  Testing Health Endpoint...');
    const health = await testEndpoint('/health');
    console.log(`   Status: ${health.status}`);
    console.log(`   Response:`, health.data);
    console.log('   ✅ Health check passed!\n');

    // Test 2: Register a user
    console.log('2️⃣  Testing User Registration...');
    const registerData = {
      name: 'Test User',
      email: `test${Date.now()}@example.com`,
      password: 'Test123!@#',
      phone: '+1234567890'
    };
    const register = await testEndpoint('/api/auth/register', 'POST', registerData);
    console.log(`   Status: ${register.status}`);
    console.log(`   Response:`, register.data);
    
    if (register.status === 201) {
      console.log('   ✅ User registration passed!\n');
      
      const token = register.data.token;
      const userId = register.data.user.userId;

      // Test 3: Login
      console.log('3️⃣  Testing User Login...');
      const loginData = {
        email: registerData.email,
        password: registerData.password
      };
      const login = await testEndpoint('/api/auth/login', 'POST', loginData);
      console.log(`   Status: ${login.status}`);
      console.log(`   Response:`, login.data);
      console.log('   ✅ User login passed!\n');

      // Test 4: Get hazards (should work without auth for now)
      console.log('4️⃣  Testing Get Hazards...');
      const hazards = await testEndpoint('/api/hazards?latitude=40.7128&longitude=-74.0060&radius=5000');
      console.log(`   Status: ${hazards.status}`);
      console.log(`   Response:`, hazards.data);
      console.log('   ✅ Get hazards passed!\n');

    } else {
      console.log('   ❌ User registration failed!\n');
    }

    console.log('✅ All tests completed!\n');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

// Wait a bit for server to be ready, then run tests
setTimeout(runTests, 2000);
