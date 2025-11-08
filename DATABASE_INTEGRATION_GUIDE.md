# 🔌 HazardNet Database Integration Guide

## ✅ What's Been Integrated

I've successfully integrated your **Neon PostgreSQL database** with your **Flutter app**! Here's what's been completed:

---

## 📁 New Files Created

### 1. **API Services** (lib/data/services/)

| File | Purpose |
|------|---------|
| `api_service.dart` | Base HTTP client with authentication, error handling |
| `auth_api_service.dart` | User registration, login, logout, token management |
| `hazard_api_service.dart` | Report hazards, get nearby hazards, verify hazards |
| `alert_api_service.dart` | Get alerts, mark as read, proximity alerts |
| `trip_api_service.dart` | Start/end trips, trip history, analytics |
| `sensor_data_api_service.dart` | Upload sensor data, impact detection |

### 2. **Configuration Updates**

| File | Changes |
|------|---------|
| `app_constants.dart` | Added all backend API endpoints |
| `.env.example` | Updated with comprehensive environment variables |

---

## 🚀 How It Works

### Architecture Overview

```
┌─────────────────┐
│  Flutter App    │
│   (Frontend)    │
└────────┬────────┘
         │ HTTP Requests (JSON)
         ▼
┌─────────────────┐
│   API Service   │  ← lib/data/services/api_service.dart
│  (HTTP Client)  │
└────────┬────────┘
         │ REST API Calls
         ▼
┌─────────────────┐
│  Backend API    │  ← Node.js/Express (TO BE CREATED)
│   (Server)      │
└────────┬────────┘
         │ SQL Queries
         ▼
┌─────────────────┐
│ Neon PostgreSQL │  ← Already Created (database/ folder)
│   (Database)    │
└─────────────────┘
```

---

## 📋 Step-by-Step Integration

### ✅ Step 1: Database Setup (DONE)
- ✅ Neon PostgreSQL schema created (`database/schema.sql`)
- ✅ Seed data prepared (`database/seed_data.sql`)
- ✅ Connection tests available (`database/test_connection.js`)

### ✅ Step 2: Flutter API Services (DONE)
- ✅ Base API client created
- ✅ Authentication service created
- ✅ Hazard service created
- ✅ Alert service created
- ✅ Trip tracking service created
- ✅ Sensor data service created

### ⏳ Step 3: Backend API (TO DO - Next Step)

You need to create a **Node.js/Express backend** that:
1. Connects to your Neon database
2. Implements REST API endpoints
3. Handles JWT authentication
4. Validates requests
5. Returns JSON responses

**Backend files needed:**
```
backend/
├── package.json
├── .env (with DATABASE_URL from Neon)
├── server.js
├── routes/
│   ├── auth.js
│   ├── hazards.js
│   ├── alerts.js
│   ├── trips.js
│   └── sensor-data.js
├── middleware/
│   ├── auth.js
│   └── validation.js
└── utils/
    └── database.js
```

### ⏳ Step 4: Update Flutter Config (TODO)

1. **Copy .env.example to .env**
   ```bash
   copy .env.example .env
   ```

2. **Update .env with your backend URL**
   ```bash
   API_BASE_URL=http://localhost:3000/api  # For local testing
   # OR
   API_BASE_URL=https://your-backend.vercel.app/api  # For production
   ```

---

## 🔧 How to Use the API Services

### Example 1: User Registration

```dart
import 'package:event_safety_app/data/services/auth_api_service.dart';

final authService = AuthApiService();

try {
  final user = await authService.register(
    email: 'user@example.com',
    password: 'securepassword123',
    displayName: 'John Doe',
    phoneNumber: '+919876543210',
    vehicleType: 'car',
  );
  
  print('User registered: ${user.displayName}');
  // Token is automatically saved and set
} catch (e) {
  print('Registration failed: $e');
}
```

### Example 2: Report a Hazard

```dart
import 'package:event_safety_app/data/services/hazard_api_service.dart';

final hazardService = HazardApiService();

try {
  final hazard = await hazardService.reportHazard(
    type: 'pothole',
    latitude: 28.6139,
    longitude: 77.2090,
    severity: 'high',
    confidence: 0.92,
    description: 'Large pothole near ITO intersection',
    depth: 12.5,
    lane: 'left_lane',
  );
  
  print('Hazard reported: ${hazard.id}');
} catch (e) {
  print('Failed to report hazard: $e');
}
```

### Example 3: Get Nearby Hazards

```dart
import 'package:event_safety_app/data/services/hazard_api_service.dart';

final hazardService = HazardApiService();

try {
  final nearbyHazards = await hazardService.getNearbyHazards(
    latitude: 28.6139,
    longitude: 77.2090,
    radiusKm: 0.5, // 500 meters
  );
  
  print('Found ${nearbyHazards.length} nearby hazards');
  for (var hazard in nearbyHazards) {
    print('${hazard.type} - ${hazard.severity}');
  }
} catch (e) {
  print('Failed to fetch hazards: $e');
}
```

### Example 4: Start a Trip

```dart
import 'package:event_safety_app/data/services/trip_api_service.dart';

final tripService = TripApiService();

try {
  final trip = await tripService.startTrip(
    startLatitude: 28.6139,
    startLongitude: 77.2090,
    startAddress: 'ITO, New Delhi',
  );
  
  final tripId = trip['id'];
  print('Trip started: $tripId');
  
  // Later, when trip ends:
  await tripService.endTrip(
    tripId: tripId,
    endLatitude: 28.5355,
    endLongitude: 77.3910,
    endAddress: 'Noida Sector 62',
    distanceKm: 18.5,
    durationMinutes: 45,
    hazardsDetected: 3,
    averageSpeed: 24.7,
    maxSpeed: 60.0,
    damageScoreIncrease: 15,
  );
} catch (e) {
  print('Trip error: $e');
}
```

### Example 5: Integration with BLoC

Update your `auth_bloc.dart`:

```dart
import 'package:event_safety_app/data/services/auth_api_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApiService _authService = AuthApiService();

  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignIn>(_onSignIn);
    on<SignUp>(_onSignUp);
    on<SignOut>(_onSignOut);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await _authService.checkAuthStatus();
      
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignIn(
    SignIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await _authService.login(
        email: event.email,
        password: event.password,
      );
      
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignUp(
    SignUp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await _authService.register(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        phoneNumber: event.phoneNumber,
        vehicleType: event.vehicleType,
      );
      
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignOut(
    SignOut event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logout();
    emit(Unauthenticated());
  }
}
```

---

## 🎯 Required Backend API Endpoints

Your backend must implement these endpoints:

### Authentication
- `POST /api/auth/register` - Create new user
- `POST /api/auth/login` - Login user, return JWT token
- `POST /api/auth/logout` - Logout user
- `GET /api/auth/check` - Verify JWT token

### Hazards
- `POST /api/hazards/report` - Report new hazard
- `GET /api/hazards/nearby?lat=X&lng=Y&radius=Z` - Get nearby hazards
- `GET /api/hazards/:id` - Get hazard details
- `POST /api/hazards/:id/verify` - Verify hazard
- `PATCH /api/hazards/:id/resolve` - Mark hazard as resolved

### Alerts
- `GET /api/alerts` - Get user alerts
- `GET /api/alerts/unread-count` - Get unread count
- `PATCH /api/alerts/:id/read` - Mark alert as read
- `PATCH /api/alerts/mark-all-read` - Mark all as read
- `DELETE /api/alerts/:id` - Delete alert

### Users
- `GET /api/users/profile` - Get user profile
- `PATCH /api/users/damage-score` - Update damage score
- `GET /api/users/stats` - Get user statistics

### Trips
- `POST /api/trips/start` - Start trip
- `PATCH /api/trips/end` - End trip
- `GET /api/trips/history` - Get trip history
- `GET /api/trips/:id` - Get trip details
- `GET /api/trips/stats` - Get trip statistics

### Sensor Data
- `POST /api/sensor-data` - Upload sensor data
- `POST /api/sensor-data/batch` - Upload batch sensor data
- `GET /api/sensor-data?trip_id=X` - Get trip sensor data

---

## 🔐 Authentication Flow

```
1. User Registration/Login
   ↓
2. Backend generates JWT token
   ↓
3. Token stored in SharedPreferences
   ↓
4. Token sent with every API request (Authorization: Bearer <token>)
   ↓
5. Backend validates token
   ↓
6. Request processed if valid, 401 error if invalid
```

---

## 📝 Next Steps for You and Ayush

### Immediate (This Week)

1. **Create Backend Project**
   ```bash
   mkdir backend
   cd backend
   npm init -y
   npm install express pg jsonwebtoken bcrypt dotenv cors
   ```

2. **Copy Database Connection String**
   - Get from Neon dashboard
   - Add to `backend/.env`

3. **Create Basic Server** (`backend/server.js`)
   ```javascript
   const express = require('express');
   const cors = require('cors');
   
   const app = express();
   app.use(cors());
   app.use(express.json());
   
   // Test endpoint
   app.get('/api/health', (req, res) => {
     res.json({ status: 'ok' });
   });
   
   app.listen(3000, () => {
     console.log('Server running on http://localhost:3000');
   });
   ```

4. **Test Connection**
   ```bash
   node server.js
   # Visit http://localhost:3000/api/health
   ```

### This Month

5. **Implement Authentication Endpoints** (see `database/backend_api_guide.md`)
6. **Implement Hazard Endpoints**
7. **Test with Flutter App**
8. **Deploy Backend** (Vercel/Railway/Render)

### Next Month

9. **Implement Trip & Sensor Endpoints**
10. **Add ML Model Integration**
11. **Production Testing**
12. **App Store Deployment**

---

## 🐛 Troubleshooting

### Error: "Connection refused"
- **Cause:** Backend not running
- **Solution:** Start backend with `node server.js`

### Error: "401 Unauthorized"
- **Cause:** Invalid or expired token
- **Solution:** Login again to get new token

### Error: "Network request failed"
- **Cause:** Wrong API URL in .env
- **Solution:** Check API_BASE_URL in .env file

### Error: "CORS error"
- **Cause:** Backend not allowing Flutter app origin
- **Solution:** Add CORS middleware in backend

---

## 📚 Additional Resources

- **Backend API Guide:** `database/backend_api_guide.md` (will create next)
- **Database Schema:** `database/DATABASE_ARCHITECTURE.md`
- **Setup Guide:** `database/README.md`

---

## ✅ Integration Checklist

**Flutter App:**
- [x] API services created
- [x] API constants defined
- [x] Error handling implemented
- [x] Token management ready
- [ ] Update BLoCs to use API services
- [ ] Update .env with backend URL
- [ ] Test API integration

**Backend:**
- [ ] Create Node.js project
- [ ] Connect to Neon database
- [ ] Implement authentication
- [ ] Implement hazard endpoints
- [ ] Implement alert endpoints
- [ ] Implement trip endpoints
- [ ] Deploy to cloud

**Database:**
- [x] Schema created
- [x] Seed data available
- [x] Connection tested
- [ ] Production database created
- [ ] Backups configured

---

**🎉 Your Flutter app is now database-ready! Next: Create the backend API.**

