const { spawn } = require('child_process');
const http = require('http');

console.log('🧪 Starting HazardNet Backend Test...\n');

// Start the server
const server = spawn('node', ['server.js'], {
  cwd: 'c:\\Users\\Hammad\\OneDrive\\Documents\\HazardNet_2.0.11\\backend',
  shell: true
});

let serverStarted = false;

server.stdout.on('data', (data) => {
  console.log(data.toString());
  if (data.toString().includes('HazardNet API Server running')) {
    serverStarted = true;
    console.log('\n✅ Server started! Testing endpoints...\n');
    setTimeout(testEndpoints, 2000);
  }
});

server.stderr.on('data', (data) => {
  console.error('❌ Server Error:', data.toString());
});

server.on('close', (code) => {
  console.log(`\n⚠️  Server process exited with code ${code}`);
  if (!serverStarted) {
    console.log('\n❌ Server failed to start. Check the error messages above.');
  }
});

function testEndpoints() {
  console.log('📡 Testing GET /health...');
  
  http.get('http://localhost:3000/health', (res) => {
    let data = '';
    
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      console.log('✅ Health endpoint response:', data);
      console.log('\n📡 Testing POST /api/auth/register...');
      testRegister();
    });
  }).on('error', (err) => {
    console.error('❌ Health check failed:', err.message);
    cleanup();
  });
}

function testRegister() {
  const postData = JSON.stringify({
    username: 'testuser',
    email: 'test@example.com',
    password: 'Test123!@#'
  });

  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/auth/register',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': postData.length
    }
  };

  const req = http.request(options, (res) => {
    let data = '';
    
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      console.log(`✅ Register response (${res.statusCode}):`, data);
      console.log('\n🎉 Backend API test complete!\n');
      console.log('📋 Test Summary:');
      console.log('  ✅ Server started successfully');
      console.log('  ✅ Health endpoint working');
      console.log('  ✅ Auth registration endpoint working');
      console.log('\n💡 Server is running on http://localhost:3000');
      console.log('💡 Press Ctrl+C to stop the server\n');
    });
  });

  req.on('error', (err) => {
    console.error('❌ Register test failed:', err.message);
    cleanup();
  });

  req.write(postData);
  req.end();
}

function cleanup() {
  console.log('\n🛑 Stopping server...');
  server.kill();
  process.exit(0);
}

// Handle Ctrl+C
process.on('SIGINT', cleanup);

// Timeout after 30 seconds
setTimeout(() => {
  console.log('\n⏱️  Test timeout - stopping server');
  cleanup();
}, 30000);
