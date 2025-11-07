# 🚀 Quick Start Guide - New Features

## Install Dependencies

```bash
cd backend
npm install
```

## Run Database Migrations

### Option 1: Using psql (Recommended)
```bash
psql -h <your-neon-host>.neon.tech -U <username> -d <database> -f database/migrations.sql
```

### Option 2: Using Node.js
```bash
node -p "require('fs').readFileSync('./database/migrations.sql','utf8')" | psql <connection-string>
```

### Option 3: Copy-paste SQL
Open `database/migrations.sql` and run it in your Neon SQL Editor

## Start Backend Server

```bash
cd backend
npm run dev
```

Server will start on: `http://localhost:3000`

## Test New Endpoints

### 1. Photo Upload
```bash
curl -X POST http://localhost:3000/api/gamification/<hazard-id>/photos \
  -H "Authorization: Bearer <token>" \
  -F "photos=@image1.jpg" \
  -F "photos=@image2.jpg"
```

### 2. Vote on Hazard
```bash
curl -X POST http://localhost:3000/api/gamification/<hazard-id>/vote \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"voteType": "upvote"}'
```

### 3. Get Leaderboard
```bash
curl http://localhost:3000/api/gamification/leaderboard
```

### 4. Trigger SOS
```bash
curl -X POST http://localhost:3000/api/emergency/sos \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 28.7041,
    "longitude": 77.1025,
    "message": "Emergency help needed"
  }'
```

### 5. Authority Dashboard Stats
```bash
curl http://localhost:3000/api/authority/dashboard/stats \
  -H "Authorization: Bearer <token>"
```

## Build Android APK

### GitHub Actions (Easiest)
1. Go to: https://github.com/Ayush-1789/HazardNet/actions
2. Click "Build Android APK"
3. Click "Run workflow"
4. Download APK from Artifacts

### Local Build (if Android SDK installed)
```bash
flutter pub get
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

## Feature Access

### For Regular Users:
- ✅ Report hazards with photos
- ✅ Vote on hazards
- ✅ View leaderboard
- ✅ Earn points and badges
- ✅ Add emergency contacts
- ✅ Trigger SOS alerts

### For Authorities (requires registration + approval):
- ✅ View all hazards
- ✅ Take action on hazards
- ✅ Broadcast official alerts
- ✅ Access dashboard statistics

## Quick Test Workflow

1. **Register User**
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123",
    "fullName": "Test User"
  }'
```

2. **Login**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

3. **Report Hazard** (use token from login)
```bash
curl -X POST http://localhost:3000/api/hazards/report \
  -H "Authorization: Bearer <your-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "pothole",
    "latitude": 28.7041,
    "longitude": 77.1025,
    "severity": "high"
  }'
```

4. **Upload Photo** (use hazard ID from previous response)
```bash
curl -X POST http://localhost:3000/api/gamification/<hazard-id>/photos \
  -H "Authorization: Bearer <your-token>" \
  -F "photos=@photo.jpg"
```

5. **Vote on Hazard**
```bash
curl -X POST http://localhost:3000/api/gamification/<hazard-id>/vote \
  -H "Authorization: Bearer <your-token>" \
  -H "Content-Type: application/json" \
  -d '{"voteType": "upvote"}'
```

6. **Check Your Points**
```bash
curl http://localhost:3000/api/gamification/user/<your-user-id>/points
```

7. **View Leaderboard**
```bash
curl http://localhost:3000/api/gamification/leaderboard
```

## Troubleshooting

### Database Connection Error
- Check `.env` file has correct DATABASE_URL
- Ensure Neon database is running
- Test connection: `node backend/test-db.js`

### Photo Upload Fails
- Ensure `backend/uploads/hazard-photos/` directory exists
- Check file size < 5MB
- Verify image format (jpg, png, webp only)

### Multer Not Found
```bash
cd backend
npm install multer
```

### Migration Fails
- Check if tables already exist
- Use `DROP TABLE IF EXISTS` for testing
- Ensure uuid-ossp extension is enabled in Neon

## Documentation

- **NEW_FEATURES.md** - Detailed feature documentation
- **ALERT_SYSTEM_README.md** - Alert system guide
- **database/migrations.sql** - All new database schema
- **backend/routes/** - API endpoint implementations

## Support

For issues:
1. Check server logs: `npm run dev`
2. Test database: `node backend/test-db.js`
3. Check API: `curl http://localhost:3000/health`
4. Review NEW_FEATURES.md for API documentation

Happy coding! 🚀
