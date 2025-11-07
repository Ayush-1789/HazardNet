# HazardNet Testing Checklist

## Pre-Testing Setup ✅/❌

### Environment Setup
- [ ] Flutter SDK installed and in PATH
  - Run: `flutter doctor`
  - Should show no critical issues
  
- [ ] Neon PostgreSQL database created
  - Account created at https://neon.tech
  - Database created
  - Connection string saved
  
- [ ] Database schema deployed
  - `schema.sql` executed successfully
  - All 8 tables created
  - Triggers and functions working
  
- [ ] Backend server running
  - Node.js installed
  - Dependencies installed (`npm install`)
  - `.env` file configured
  - Server running on port 3000
  - Test: `curl http://localhost:3000/health`
  
- [ ] Flutter app configured
  - `flutter pub get` executed successfully
  - `.env` file created (or API_BASE_URL updated)
  - No compilation errors: `flutter analyze`

---

## Backend API Testing (Use Postman or curl)

### 1. Health Check
```bash
curl http://localhost:3000/health
# Expected: {"status":"ok","timestamp":"..."}
```
- [ ] Health endpoint working

### 2. Authentication Tests

#### Register New User
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "displayName": "Test User",
    "phoneNumber": "+919876543210",
    "vehicleType": "car"
  }'
```
- [ ] User created successfully
- [ ] JWT token returned
- [ ] User added to database

#### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```
- [ ] Login successful
- [ ] JWT token returned
- [ ] Token is valid

#### Get Profile (with token)
```bash
curl http://localhost:3000/api/auth/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```
- [ ] Profile data returned
- [ ] User details correct

### 3. Hazard Tests

#### Report Hazard
```bash
curl -X POST http://localhost:3000/api/hazards \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "pothole",
    "latitude": 28.6139,
    "longitude": 77.2090,
    "severity": "medium",
    "confidence": 0.85,
    "description": "Large pothole on main road"
  }'
```
- [ ] Hazard created
- [ ] Returned with ID
- [ ] Visible in database

#### Get Nearby Hazards
```bash
curl "http://localhost:3000/api/hazards/nearby?lat=28.6139&lng=77.2090&radius=5" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```
- [ ] Returns nearby hazards
- [ ] Distance calculated correctly
- [ ] Sorted by distance

#### Verify Hazard
```bash
curl -X POST http://localhost:3000/api/hazards/HAZARD_ID/verify \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"verified": true}'
```
- [ ] Verification recorded
- [ ] Verification count increased
- [ ] Status updated if threshold reached

### 4. Alerts Tests

#### Get User Alerts
```bash
curl http://localhost:3000/api/alerts \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```
- [ ] Returns user's alerts
- [ ] Sorted by timestamp
- [ ] Unread count correct

#### Mark Alert as Read
```bash
curl -X PUT http://localhost:3000/api/alerts/ALERT_ID/read \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```
- [ ] Alert marked as read
- [ ] is_read updated in database
- [ ] Unread count decreased

### 5. Trip Tests

#### Start Trip
```bash
curl -X POST http://localhost:3000/api/trips/start \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "startLatitude": 28.6139,
    "startLongitude": 77.2090
  }'
```
- [ ] Trip session created
- [ ] Trip ID returned
- [ ] Start time recorded

#### End Trip
```bash
curl -X POST http://localhost:3000/api/trips/TRIP_ID/end \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "endLatitude": 28.7041,
    "endLongitude": 77.1025,
    "totalDistance": 12.5,
    "hazardsEncountered": 3,
    "averageSpeed": 45.2
  }'
```
- [ ] Trip ended successfully
- [ ] Statistics calculated
- [ ] Duration computed

### 6. Sensor Data Tests

#### Upload Sensor Data
```bash
curl -X POST http://localhost:3000/api/sensor-data \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "tripSessionId": "TRIP_ID",
    "latitude": 28.6139,
    "longitude": 77.2090,
    "accelerometerData": {
      "x": 0.5,
      "y": -2.3,
      "z": 9.8
    },
    "gyroscopeData": {
      "x": 0.1,
      "y": 0.2,
      "z": 0.05
    },
    "speed": 45.0,
    "impactDetected": false
  }'
```
- [ ] Sensor data saved
- [ ] Linked to trip session
- [ ] Impact detection working

---

## Flutter App Testing

### 1. App Launch
- [ ] App launches without errors
- [ ] Splash screen appears
- [ ] No crash on startup

### 2. Authentication Flow

#### Registration
- [ ] Navigate to Sign Up screen
- [ ] Enter valid details
- [ ] Click Register button
- [ ] Loading indicator appears
- [ ] Success: Navigate to home screen
- [ ] Error: Appropriate error message shown

#### Login
- [ ] Navigate to Login screen
- [ ] Enter credentials
- [ ] Click Login button
- [ ] Loading indicator appears
- [ ] Success: Navigate to home screen
- [ ] Error: Show error message (wrong password, etc.)
- [ ] Token stored in SharedPreferences

#### Auto-Login
- [ ] Close and reopen app
- [ ] Should automatically login if token valid
- [ ] Should go to login screen if token expired

#### Logout
- [ ] Click logout button
- [ ] Confirm logout
- [ ] Token removed from storage
- [ ] Navigate to login screen

### 3. Hazard Detection & Reporting

#### Camera Access
- [ ] Open camera screen
- [ ] Camera permission requested
- [ ] Camera preview appears
- [ ] Camera switches (front/back) work

#### Hazard Detection
- [ ] Point camera at road
- [ ] ML model processes frames
- [ ] Detected hazards highlighted
- [ ] Confidence score displayed
- [ ] Only hazards >50% confidence shown

#### Hazard Reporting
- [ ] Detect hazard or tap "Report Hazard"
- [ ] Capture photo
- [ ] Photo shown in preview
- [ ] Can edit hazard type
- [ ] Can edit severity
- [ ] Can add description
- [ ] Submit hazard
- [ ] Loading indicator appears
- [ ] Success message shown
- [ ] Hazard appears in database

### 4. Map & Nearby Hazards

#### Map Display
- [ ] Open map screen
- [ ] Map loads correctly
- [ ] User location shown (blue dot)
- [ ] Location updates in real-time

#### Nearby Hazards
- [ ] Hazards displayed as markers
- [ ] Different colors for severity (red/yellow/orange)
- [ ] Can tap marker to see details
- [ ] Details show: type, severity, distance, time
- [ ] Can navigate to hazard location

#### Filtering
- [ ] Can filter by hazard type
- [ ] Can filter by severity
- [ ] Can filter by verification status
- [ ] Filters apply immediately

### 5. Alerts & Notifications

#### Alert List
- [ ] Open alerts screen
- [ ] Alerts displayed (newest first)
- [ ] Unread alerts highlighted
- [ ] Can see alert details
- [ ] Can mark as read
- [ ] Unread count updates

#### Proximity Alerts
- [ ] Drive near hazard
- [ ] Alert notification appears
- [ ] Alert sound plays
- [ ] Alert vibration (if enabled)
- [ ] Alert added to list

### 6. Trip Tracking

#### Start Trip
- [ ] Tap "Start Trip" button
- [ ] Location tracking starts
- [ ] Trip timer starts
- [ ] Distance counter starts
- [ ] Speed shown

#### During Trip
- [ ] Location updates every 10 meters
- [ ] Distance calculated correctly
- [ ] Speed shown accurately
- [ ] Hazards encountered counted
- [ ] Sensor data recorded

#### End Trip
- [ ] Tap "End Trip" button
- [ ] Confirm end trip
- [ ] Trip statistics shown:
  - [ ] Total distance
  - [ ] Duration
  - [ ] Average speed
  - [ ] Hazards encountered
  - [ ] Damage score
- [ ] Trip saved to history

#### Trip History
- [ ] Open trip history
- [ ] Past trips displayed
- [ ] Can view trip details
- [ ] Can see route on map
- [ ] Statistics accurate

### 7. User Profile

#### View Profile
- [ ] Open profile screen
- [ ] User details displayed:
  - [ ] Name
  - [ ] Email
  - [ ] Phone
  - [ ] Vehicle type
  - [ ] Damage score
  - [ ] Last maintenance

#### Edit Profile
- [ ] Can edit name
- [ ] Can edit phone
- [ ] Can change vehicle type
- [ ] Changes saved to backend
- [ ] Profile updates on screen

#### Damage Score
- [ ] Damage score increases when encountering hazards
- [ ] High score shows warning
- [ ] Maintenance reminder appears
- [ ] Score resets after maintenance

### 8. Settings

#### App Settings
- [ ] Can change notification settings
- [ ] Can adjust proximity alert radius
- [ ] Can change map type
- [ ] Can toggle dark mode
- [ ] Settings persist after app restart

#### Permissions
- [ ] Can view permission status
- [ ] Can request permissions
- [ ] Can open system settings

---

## Error Handling Tests

### Network Errors
- [ ] Turn off Wi-Fi/Data
- [ ] Try to login → Shows "No internet connection"
- [ ] Try to load hazards → Shows error message
- [ ] Turn on internet → Can retry successfully

### Invalid Data
- [ ] Try login with wrong password → Shows "Invalid credentials"
- [ ] Try register with existing email → Shows "Email already exists"
- [ ] Try submit hazard without image → Shows validation error

### Session Expiry
- [ ] Wait for JWT token to expire (or modify expiry time)
- [ ] Make API request → Should show "Session expired"
- [ ] Should redirect to login
- [ ] Should ask to login again

### Server Down
- [ ] Stop backend server
- [ ] Try to use app → Shows "Cannot connect to server"
- [ ] Graceful error messages (no crashes)
- [ ] Can retry when server is back

---

## Performance Tests

### App Launch Time
- [ ] Cold start < 3 seconds
- [ ] Warm start < 1 second
- [ ] No lag on splash screen

### Camera Performance
- [ ] Camera FPS > 15
- [ ] ML model inference < 200ms
- [ ] No frame drops
- [ ] No memory leaks

### Map Performance
- [ ] Map loads < 2 seconds
- [ ] Smooth panning/zooming
- [ ] Markers render quickly
- [ ] No lag with 100+ hazards

### Battery Usage
- [ ] Location tracking doesn't drain battery excessively
- [ ] Background location updates optimized
- [ ] Camera usage reasonable

---

## Database Verification

### Check Data Integrity
```sql
-- Check users table
SELECT * FROM users;

-- Check hazards table
SELECT * FROM hazards ORDER BY created_at DESC LIMIT 10;

-- Check verifications
SELECT h.type, COUNT(hv.id) as verification_count
FROM hazards h
LEFT JOIN hazard_verifications hv ON h.id = hv.hazard_id
GROUP BY h.id, h.type;

-- Check alerts
SELECT * FROM alerts ORDER BY created_at DESC LIMIT 10;

-- Check trip sessions
SELECT * FROM trip_sessions ORDER BY created_at DESC LIMIT 10;

-- Check sensor data
SELECT COUNT(*) FROM sensor_data;
```

### Verify Triggers
```sql
-- Insert test hazard
INSERT INTO hazards (type, latitude, longitude, severity, confidence, reported_by)
VALUES ('pothole', 28.6139, 77.2090, 'high', 0.95, 'user-id-here');

-- Verify alert was created by trigger
SELECT * FROM alerts WHERE hazard_id = 'hazard-id-from-above';

-- Add 3 verifications
INSERT INTO hazard_verifications (hazard_id, verified_by, verified)
VALUES 
  ('hazard-id', 'user1', true),
  ('hazard-id', 'user2', true),
  ('hazard-id', 'user3', true);

-- Check if hazard is auto-verified
SELECT is_verified FROM hazards WHERE id = 'hazard-id';
-- Should be true if verification_count >= 3
```

---

## Security Tests

### Authentication
- [ ] Cannot access protected endpoints without token
- [ ] Invalid token returns 401 Unauthorized
- [ ] Expired token returns 401
- [ ] Tokens are properly validated

### Authorization
- [ ] User can only access their own data
- [ ] Cannot modify other users' hazards
- [ ] Cannot delete other users' trips
- [ ] Admin endpoints protected (if applicable)

### Data Validation
- [ ] Email format validated
- [ ] Password strength checked
- [ ] Latitude/longitude ranges validated
- [ ] SQL injection prevented
- [ ] XSS attacks prevented

### Sensitive Data
- [ ] Passwords hashed (bcrypt)
- [ ] Tokens encrypted
- [ ] No sensitive data in logs
- [ ] HTTPS used (in production)

---

## Edge Cases

### GPS Issues
- [ ] No GPS signal → Shows error
- [ ] GPS permission denied → Request permission
- [ ] Location services disabled → Prompt to enable
- [ ] Weak GPS signal → Shows warning

### Camera Issues
- [ ] Camera permission denied → Request permission
- [ ] Camera busy → Shows error
- [ ] No camera available → Disable camera features
- [ ] Low light → Shows warning

### Data Limits
- [ ] 1000+ hazards on map → Cluster markers
- [ ] 100+ alerts → Pagination works
- [ ] Long trips (>8 hours) → Data saved correctly
- [ ] Large sensor data → Batch upload works

---

## Regression Tests (After Changes)

After making any code changes, retest:
- [ ] Authentication flow
- [ ] Hazard reporting
- [ ] Map display
- [ ] Alert notifications
- [ ] Trip tracking
- [ ] Error handling

---

## Final Checklist

### Before Release
- [ ] All critical bugs fixed
- [ ] All tests passing
- [ ] Documentation updated
- [ ] API endpoints secured
- [ ] Environment variables set
- [ ] Database backups configured
- [ ] Error logging implemented
- [ ] Analytics integrated (optional)
- [ ] App icon set
- [ ] Splash screen designed
- [ ] Terms & Privacy Policy added

### Production Deployment
- [ ] Backend deployed to cloud (AWS/Azure/GCP)
- [ ] Database migrated to production
- [ ] API URL updated in app
- [ ] SSL certificates configured
- [ ] Environment variables secured
- [ ] Rate limiting enabled
- [ ] Monitoring setup (Sentry, etc.)
- [ ] Performance optimizations
- [ ] App signed for release
- [ ] Submitted to Play Store/App Store

---

## Test Results Summary

### Functionality: ___/100
- Auth: ___/10
- Hazards: ___/10
- Map: ___/10
- Alerts: ___/10
- Trips: ___/10
- Profile: ___/10
- Settings: ___/10
- Error Handling: ___/10
- Performance: ___/10
- Security: ___/10

### Overall Status: ⬜ Pass / ⬜ Fail

### Notes:
```
[Add any issues, bugs, or observations here]
```

---

*Last Updated: ${DateTime.now().toString()}*
