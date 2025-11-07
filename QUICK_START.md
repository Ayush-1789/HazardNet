# HazardNet Quick Start Guide 🚀

## TL;DR - Get Started in 30 Minutes

This guide gets your HazardNet app running end-to-end.

---

## Prerequisites

- ✅ Windows PC (you have this)
- ⏳ Flutter SDK (need to install)
- ⏳ Node.js (for backend)
- ⏳ Neon account (free PostgreSQL hosting)

---

## Step 1: Install Flutter (10 min)

### Download & Install
1. Go to: https://docs.flutter.dev/get-started/install/windows
2. Download Flutter SDK ZIP
3. Extract to `C:\flutter`
4. Add to PATH:
   - Open System Environment Variables
   - Edit PATH
   - Add `C:\flutter\bin`
   - Click OK

### Verify Installation
```powershell
flutter doctor
```

Expected output:
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain
[✓] Chrome
...
```

**Don't worry about Android Studio warnings - not needed for testing on emulator.**

---

## Step 2: Setup Neon Database (5 min)

### Create Account
1. Go to https://neon.tech
2. Click "Sign Up" (use GitHub account for quick signup)
3. Create new project: "HazardNet"
4. Copy connection string (looks like):
   ```
   postgresql://user:pass@ep-something.us-east-2.aws.neon.tech/neondb?sslmode=require
   ```

### Run Schema
1. Click "SQL Editor" in Neon dashboard
2. Copy content from `database/schema.sql`
3. Paste and click "Run"
4. Should see: "Success: 8 tables created"

### Add Test Data (Optional)
1. Copy content from `database/seed_data.sql`
2. Paste in SQL Editor
3. Click "Run"
4. Should see: "Success: 5 users, 10 hazards added"

---

## Step 3: Create Backend API (10 min)

### Install Node.js
If you don't have Node.js:
1. Go to https://nodejs.org
2. Download LTS version
3. Install with default settings
4. Verify: `node --version`

### Setup Backend
```powershell
# Create backend folder
cd "C:\Users\Hammad\OneDrive\Documents\HazardNet_2.0.11"
mkdir backend
cd backend

# Initialize project
npm init -y

# Install dependencies
npm install express pg dotenv bcryptjs jsonwebtoken cors helmet
npm install --save-dev nodemon
```

### Create Files

**File 1: `backend/server.js`**
```javascript
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/hazards', require('./routes/hazards'));
app.use('/api/alerts', require('./routes/alerts'));
app.use('/api/trips', require('./routes/trips'));
app.use('/api/sensor-data', require('./routes/sensor-data'));

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
});

module.exports = { pool };
```

**File 2: `backend/.env`**
```env
DATABASE_URL=postgresql://your-connection-string-from-neon
JWT_SECRET=change-this-to-random-secret-key-in-production
PORT=3000
NODE_ENV=development
```
**⚠️ IMPORTANT: Replace `DATABASE_URL` with your actual Neon connection string!**

**File 3: `backend/package.json`** (add scripts)
```json
{
  "name": "hazardnet-backend",
  "version": "1.0.0",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.3",
    "dotenv": "^16.3.1",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  }
}
```

**Now copy the route files from `docs/API_Backend_Setup.md`:**
1. Create `backend/routes/` folder
2. Copy `auth.js`, `hazards.js`, `alerts.js`, `trips.js`, `sensor-data.js`
3. Create `backend/middleware/` folder
4. Copy `auth.js` middleware

**Quick way:** I've created all these files in `docs/API_Backend_Setup.md` - just copy-paste each section!

### Start Backend
```powershell
npm run dev
```

Should see:
```
🚀 Server running on http://localhost:3000
📊 Health check: http://localhost:3000/health
```

Test it:
```powershell
curl http://localhost:3000/health
```

---

## Step 4: Configure Flutter App (3 min)

### Install Dependencies
```powershell
cd "C:\Users\Hammad\OneDrive\Documents\HazardNet_2.0.11"
flutter pub get
```

### Update API URL
**Option A: Using .env (Recommended)**
Create `HazardNet_2.0.11/.env`:
```env
API_BASE_URL=http://localhost:3000/api
```

**Option B: Hardcode (Quick test)**
Edit `lib/core/constants/app_constants.dart` line 12:
```dart
static const String baseApiUrl = 'http://localhost:3000/api';
// Or if testing on phone: 'http://YOUR_PC_IP:3000/api'
```

### Find Your PC IP (if testing on phone)
```powershell
ipconfig
# Look for "IPv4 Address" under your active network
# Example: 192.168.1.100
```

---

## Step 5: Run the App (2 min)

### Check for Errors
```powershell
flutter analyze
```

Should show no errors (warnings are okay).

### Run on Emulator
```powershell
flutter run
```

Or use VS Code:
1. Press `F5`
2. Select device (Chrome/Android/iOS)
3. App should launch!

---

## Step 6: Test Basic Flow (5 min)

### Test Registration
1. Launch app
2. Tap "Sign Up"
3. Enter:
   - Email: `test@example.com`
   - Password: `password123`
   - Name: `Test User`
   - Phone: `+919876543210`
   - Vehicle: `Car`
4. Tap "Register"
5. Should see home screen!

### Test Hazard Reporting
1. Tap "Report Hazard" button
2. Allow camera permission
3. Take a photo
4. Select type: "Pothole"
5. Select severity: "Medium"
6. Tap "Submit"
7. Should see success message!

### Test Map
1. Tap "Map" tab
2. Should see your location
3. Should see nearby hazards (if any)
4. Tap a hazard marker
5. Should see details

### Test Logout
1. Go to Profile
2. Tap "Logout"
3. Should return to login screen

---

## Troubleshooting

### "Flutter not found"
- Make sure you added `C:\flutter\bin` to PATH
- Restart PowerShell/VS Code
- Run `flutter doctor`

### "Cannot connect to server"
- Check backend is running (`npm run dev`)
- Check URL in `app_constants.dart`
- Try `curl http://localhost:3000/health`

### "Database connection failed"
- Check `.env` has correct Neon connection string
- Check Neon database is active
- Test connection with: `psql "your-connection-string"`

### "No camera permission"
- Enable camera in phone settings
- Restart app
- Grant permission when prompted

### "Hazards not showing on map"
- Make sure you reported at least one hazard
- Check backend logs for errors
- Try refreshing map (pull down)

---

## What's Working Now ✅

After following this guide, you should have:
- ✅ Flutter app running
- ✅ Backend API server running
- ✅ PostgreSQL database with schema
- ✅ User registration/login working
- ✅ Hazard reporting working
- ✅ Map display working
- ✅ Alerts working

---

## Next Steps

### Enhance Features
- [ ] Add Google Maps integration (better maps)
- [ ] Implement push notifications
- [ ] Add profile picture upload
- [ ] Create admin dashboard

### Deploy to Production
- [ ] Deploy backend to Railway/Render/AWS
- [ ] Update API URLs to production
- [ ] Enable HTTPS
- [ ] Submit to Play Store/App Store

### Improve ML Model
- [ ] Train better hazard detection model
- [ ] Add more hazard types
- [ ] Improve accuracy
- [ ] Reduce false positives

---

## Important Files Reference

### Backend Files
- `backend/server.js` - Main server file
- `backend/.env` - Environment variables (DATABASE_URL, JWT_SECRET)
- `backend/routes/auth.js` - Authentication endpoints
- `backend/routes/hazards.js` - Hazard endpoints
- `backend/middleware/auth.js` - JWT authentication

### Flutter Files
- `lib/main.dart` - App entry point
- `lib/bloc/auth/auth_bloc.dart` - Authentication logic
- `lib/bloc/hazard/hazard_bloc.dart` - Hazard logic
- `lib/data/services/auth_api_service.dart` - Auth API calls
- `lib/core/constants/app_constants.dart` - API URLs

### Database Files
- `database/schema.sql` - Database structure
- `database/seed_data.sql` - Test data

### Documentation
- `INTEGRATION_COMPLETE.md` - Full integration details
- `TESTING_CHECKLIST.md` - Comprehensive testing guide
- `docs/Integration_Guide.md` - Detailed integration steps
- `docs/API_Backend_Setup.md` - Complete backend code

---

## Support

### Common Issues
Check `INTEGRATION_COMPLETE.md` section "Known Limitations"

### Testing
Use `TESTING_CHECKLIST.md` for comprehensive testing

### API Reference
See `docs/API_Endpoints.md` for all endpoints

---

## Success! 🎉

You now have a fully functional road hazard detection app with:
- Real-time hazard detection using ML
- User authentication
- Hazard reporting and verification
- Proximity alerts
- Trip tracking
- Damage score calculation

**Happy testing!** 🚗💨

---

*Estimated total time: 30-40 minutes*
*Difficulty: Beginner-friendly*
