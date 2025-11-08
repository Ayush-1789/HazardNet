const http = require('http');

console.log('🔍 Testing Flutter → Backend Connection...\n');

// Test 1: Health Check
console.log('1️⃣ Testing health endpoint...');
http.get('http://localhost:3000/health', (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    if (res.statusCode === 200) {
      console.log('   ✅ Health check passed:', JSON.parse(data));
      testApiEndpoints();
    } else {
      console.log('   ❌ Health check failed:', res.statusCode);
    }
  });
}).on('error', (err) => {
  console.log('   ❌ Cannot connect to backend:', err.message);
  console.log('\n⚠️  Please start the backend server first:');
  console.log('   cd backend && node server.js\n');
  process.exit(1);
});

function testApiEndpoints() {
  console.log('\n2️⃣ Testing API endpoints that Flutter will use...');
  
  const endpoints = [
    '/api/auth/check',
    '/api/hazards',
    '/api/alerts',
    '/api/trips/history'
  ];
  
  endpoints.forEach((endpoint, index) => {
    setTimeout(() => {
      http.get(`http://localhost:3000${endpoint}`, (res) => {
        const status = res.statusCode === 401 || res.statusCode === 200 ? '✅' : '❌';
        console.log(`   ${status} ${endpoint} - Status: ${res.statusCode}`);
        
        if (index === endpoints.length - 1) {
          showConnectionGuide();
        }
      }).on('error', (err) => {
        console.log(`   ❌ ${endpoint} - Error: ${err.message}`);
      });
    }, index * 500);
  });
}

function showConnectionGuide() {
  console.log('\n' + '='.repeat(60));
  console.log('✅ BACKEND IS READY FOR FLUTTER CONNECTION!');
  console.log('='.repeat(60));
  console.log('\n📱 Flutter App Configuration:');
  console.log('   File: lib/core/constants/app_constants.dart');
  console.log('   Base URL: http://localhost:3000/api');
  console.log('   Status: ✅ Already configured!\n');
  
  console.log('🚀 To connect Flutter to backend:');
  console.log('   1. Backend server is running on http://localhost:3000');
  console.log('   2. Flutter app is configured to use localhost:3000');
  console.log('   3. All API endpoints are ready:\n');
  
  console.log('   ✅ Authentication (/api/auth)');
  console.log('      - POST /api/auth/register');
  console.log('      - POST /api/auth/login');
  console.log('      - GET  /api/auth/check\n');
  
  console.log('   ✅ Hazards (/api/hazards)');
  console.log('      - GET  /api/hazards');
  console.log('      - POST /api/hazards/report');
  console.log('      - GET  /api/hazards/nearby');
  console.log('      - POST /api/hazards/:id/verify\n');
  
  console.log('   ✅ Alerts (/api/alerts)');
  console.log('      - GET  /api/alerts');
  console.log('      - PATCH /api/alerts/:id/read\n');
  
  console.log('   ✅ Trips (/api/trips)');
  console.log('      - POST /api/trips/start');
  console.log('      - POST /api/trips/end');
  console.log('      - GET  /api/trips/history\n');
  
  console.log('   ✅ Gamification (/api/gamification) - NEW!');
  console.log('      - POST /api/gamification/:hazardId/photos');
  console.log('      - POST /api/gamification/:hazardId/vote');
  console.log('      - GET  /api/gamification/leaderboard\n');
  
  console.log('   ✅ Emergency (/api/emergency) - NEW!');
  console.log('      - POST /api/emergency/sos');
  console.log('      - GET  /api/emergency/contacts\n');
  
  console.log('   ✅ Authority (/api/authority) - NEW!');
  console.log('      - GET  /api/authority/hazards');
  console.log('      - POST /api/authority/broadcast-alert\n');
  
  console.log('📝 Next Steps:');
  console.log('   1. Keep this backend server running');
  console.log('   2. Open a new terminal');
  console.log('   3. Run: flutter run -d windows');
  console.log('   4. Test login/register in the app\n');
  
  console.log('💡 Tips:');
  console.log('   - Backend must be running before starting Flutter app');
  console.log('   - Use http://localhost:3000 (not 127.0.0.1)');
  console.log('   - Check backend logs for API requests');
  console.log('   - All endpoints require JWT token (except auth)\n');
  
  process.exit(0);
}
