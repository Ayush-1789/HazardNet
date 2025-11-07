const http = require('http');

// Wait for server to be ready
setTimeout(() => {
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/health',
    method: 'GET'
  };

  const req = http.request(options, (res) => {
    let data = '';
    res.on('data', (chunk) => data += chunk);
    res.on('end', () => {
      console.log('\n✅ Test Results:');
      console.log('Status:', res.statusCode);
      console.log('Response:', data);
      process.exit(0);
    });
  });

  req.on('error', (error) => {
    console.error('\n❌ Test Failed:');
    console.error('Error:', error.message);
    process.exit(1);
  });

  req.setTimeout(5000, () => {
    console.error('\n❌ Test Failed: Request timeout');
    req.destroy();
    process.exit(1);
  });

  req.end();
}, 1000);
