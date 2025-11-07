# Backend Setup Complete! ✅

Your backend API server is ready. Follow these steps to get it running:

---

## Step 1: Setup Neon PostgreSQL Database

### 1.1 Create Neon Account
1. Go to https://neon.tech
2. Sign up (use GitHub for quick signup)
3. Create new project: "HazardNet"

### 1.2 Get Connection String
1. In Neon dashboard, click on your project
2. Go to "Connection Details"
3. Copy the connection string (it looks like):
   ```
   postgresql://username:password@ep-xxxxx.us-east-2.aws.neon.tech/neondb?sslmode=require
   ```

### 1.3 Run Database Schema
Option A - Use Neon SQL Editor (Easiest):
1. Click "SQL Editor" in Neon dashboard
2. Copy entire content from `../database/schema.sql`
3. Paste and click "Run"
4. Should see success message

Option B - Use psql command line:
```bash
psql "your-connection-string-here" -f ../database/schema.sql
```

### 1.4 Add Test Data (Optional)
1. In SQL Editor, copy content from `../database/seed_data.sql`
2. Paste and click "Run"
3. Should see: 5 users and 10 hazards added

---

## Step 2: Configure Backend

### 2.1 Update .env File
Edit `backend/.env` file:

```env
# Replace this with your actual Neon connection string
DATABASE_URL=postgresql://your-actual-connection-string-from-neon

# Change this to a random secret (keep it secret!)
JWT_SECRET=your-super-secret-random-key-here

PORT=3000
NODE_ENV=development
```

**⚠️ IMPORTANT:** 
- Copy your Neon connection string to DATABASE_URL
- Change JWT_SECRET to something random and secure

---

## Step 3: Start the Server

### From PowerShell:
```powershell
# Make sure you're in the backend folder
cd backend

# Start the server in development mode (auto-restart on changes)
npm run dev
```

You should see:
```
🚀 HazardNet API Server running on http://localhost:3000
📊 Health check: http://localhost:3000/health
🌍 Environment: development
✅ Database connected successfully
```

---

## Step 4: Test the API

### Test Health Endpoint
Open new PowerShell window:
```powershell
curl http://localhost:3000/health
```

Expected response:
```json
{"status":"ok","timestamp":"2025-11-07T...","uptime":5.123}
```

### Test Registration
```powershell
curl -X POST http://localhost:3000/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"test@example.com\",\"password\":\"password123\",\"displayName\":\"Test User\",\"phoneNumber\":\"+919876543210\",\"vehicleType\":\"Car\"}'
```

Should return JWT token and user data!

---

## Available API Endpoints

### Authentication
- POST `/api/auth/register` - Register new user
- POST `/api/auth/login` - Login user
- GET `/api/auth/status` - Check auth status (requires token)
- GET `/api/auth/profile` - Get user profile (requires token)
- PATCH `/api/auth/damage-score` - Update damage score (requires token)
- POST `/api/auth/logout` - Logout (requires token)

### Hazards
- POST `/api/hazards/report` - Report hazard (requires token)
- GET `/api/hazards/nearby?latitude=X&longitude=Y&radius=5` - Get nearby hazards
- GET `/api/hazards` - Get all hazards
- GET `/api/hazards/:id` - Get specific hazard
- POST `/api/hazards/:id/verify` - Verify hazard (requires token)

### Alerts
- GET `/api/alerts` - Get user alerts (requires token)
- GET `/api/alerts/unread/count` - Get unread count (requires token)
- PATCH `/api/alerts/:id/read` - Mark as read (requires token)
- GET `/api/alerts/proximity?latitude=X&longitude=Y` - Get proximity alerts

### Trips
- POST `/api/trips/start` - Start trip (requires token)
- POST `/api/trips/:id/end` - End trip (requires token)
- GET `/api/trips/history` - Get trip history (requires token)
- GET `/api/trips/stats` - Get trip statistics (requires token)

### Sensor Data
- POST `/api/sensor-data/upload` - Upload sensor data (requires token)
- POST `/api/sensor-data/upload/batch` - Batch upload (requires token)
- GET `/api/sensor-data/impacts/:tripId` - Get impact detections (requires token)

---

## Troubleshooting

### "Database connection error"
- Check your DATABASE_URL in `.env` is correct
- Make sure Neon database is active
- Test connection: `psql "your-connection-string"`

### "Port 3000 already in use"
- Change PORT in `.env` to 3001 or other number
- Or kill process using port 3000

### "Cannot find module"
- Run `npm install` again
- Make sure you're in the backend folder

### "JWT_SECRET not defined"
- Check `.env` file exists
- Check JWT_SECRET is set in `.env`
- Restart server after changing `.env`

---

## Next Steps

1. ✅ Backend API server is running
2. ⏳ Configure Flutter app to connect to this server
3. ⏳ Test registration and login from app
4. ⏳ Test hazard reporting
5. ⏳ Deploy to production (Railway/Render/AWS)

---

## Files Created

```
backend/
├── server.js              # Main server file
├── package.json           # Dependencies and scripts
├── .env                   # Environment variables (DO NOT COMMIT!)
├── routes/
│   ├── auth.js           # Authentication routes
│   ├── hazards.js        # Hazard management routes
│   ├── alerts.js         # Alerts routes
│   ├── trips.js          # Trip tracking routes
│   └── sensor-data.js    # Sensor data routes
└── middleware/
    └── auth.js           # JWT authentication middleware
```

---

## Production Deployment

When ready to deploy:

1. Set `NODE_ENV=production` in .env
2. Use strong JWT_SECRET
3. Enable HTTPS
4. Consider deploying to:
   - Railway (easiest)
   - Render
   - AWS EC2
   - Google Cloud Run

---

**Backend is ready! 🚀**

Keep the server running and configure your Flutter app to use:
- Base URL: `http://localhost:3000/api`
- Or if testing on phone: `http://YOUR_PC_IP:3000/api`
