# HazardNet - Road Hazard Detection App

![Flutter](https://img.shields.io/badge/Flutter-3.24.5-blue)
![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)
![Node.js](https://img.shields.io/badge/Node.js-20-green)
![AWS](https://img.shields.io/badge/AWS-Elastic%20Beanstalk-orange)
![License](https://img.shields.io/badge/License-MIT-green)

AI-powered hazard detection system with real-time alerts and emergency response. Mobile app (Flutter) + Backend (Node.js) on AWS.

AI-powered hazard detection system with real-time alerts and emergency response. Mobile app (Flutter) + Backend (Node.js) on AWS.

##  Features

### Core Features (MVP)
- ✅ **Real-time Hazard Detection** - Camera feed with frame processing ready for ML model integration
- ✅ **Location Tracking** - GPS-based location tracking with geolocator
- ✅ **Interactive Map with OSM** - OpenStreetMap integration showing hazards with color-coded pins
  - 🔵 Blue pins: Your own reported hazards
  - 🟠 Orange pins: Hazards reported by other users
  - ✅ Verified hazards marked with green checkmark
  - 📍 Real-time user location tracking
  - 🗺️ Dark mode support for maps
- ✅ **Alert System** - Real-time notifications for nearby hazards
- ✅ **User Authentication** - Mock auth ready for backend API integration
- ✅ **Dashboard** - Quick access to all features with stats
- ✅ **Vehicle Health Tracking** - Cumulative damage scoring system
- ✅ **Beautiful UI** - Material 3 design with smooth animations and dark mode

### Hazard Types Detected
- 🕳️ Potholes
- 🚧 Unmarked Speed Breakers
- 🚫 Obstacles on Road
- 🛑 Closed/Blocked Roads
- 🚦 Lane Blockages

## 📱 Screenshots

| Dashboard | Hazard Map | Detection |
|-----------|-----------|-----------|
| ![Dashboard](https://raw.githubusercontent.com/Ayush-1789/HazardNet/main/assets/screenshots/dashboard.jpg) | ![Map](https://raw.githubusercontent.com/Ayush-1789/HazardNet/main/assets/screenshots/map.jpg) | ![Detection](https://raw.githubusercontent.com/Ayush-1789/HazardNet/main/assets/screenshots/detection.jpg) |
| Home screen with journey stats, hazards count, and verified reports | Interactive map showing all hazards with real-time updates | Camera feed with AI hazard detection and bounding boxes |

| Hazard Details | Alerts | Scan Screen |
|-----------|-----------|-----------|
| ![Details](https://raw.githubusercontent.com/Ayush-1789/HazardNet/main/assets/screenshots/details.jpg) | ![Alerts](https://raw.githubusercontent.com/Ayush-1789/HazardNet/main/assets/screenshots/alerts.jpg) | ![Scan](https://raw.githubusercontent.com/Ayush-1789/HazardNet/main/assets/screenshots/scan.jpg) |
| Full information about detected hazards with photo and location | Real-time notifications for approaching hazards and warnings | Active hazard detection interface with FPS metrics |

## 🏗️ Tech Stack

**Mobile (Frontend)**
- Flutter 3.24.5 & Dart 3.9.2
- Material Design 3
- BLoC Pattern (State Management)
- Google Maps API
- TensorFlow Lite (On-device ML)

**Backend**
- Node.js 20 with Express.js
- AWS Elastic Beanstalk (hazardnet-production)
- AWS RDS PostgreSQL
- JWT Authentication with bcrypt

**Deployment**
- GitHub Actions CI/CD
- AWS Infrastructure
- Environment: Production

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/      # App constants, API endpoints
│   ├── theme/          # App theme, colors, typography
│   └── utils/          # Helper utilities
├── data/
│   ├── repositories/   # Data layer abstraction
│   └── services/       # API services, local storage
├── models/             # Data models (User, Hazard, Alert, etc.)
├── bloc/               # BLoC state management
│   ├── auth/           # Authentication state
│   ├── camera/         # Camera & detection logic
│   ├── hazard/         # Hazard detection state
│   ├── location/       # Location tracking state
│   └── alerts/         # Alerts management state
├── screens/            # UI screens
│   ├── welcome/        # Welcome/Onboarding screen
│   ├── dashboard/      # Main dashboard
│   ├── camera/         # Real-time hazard detection
│   ├── map/            # Google Maps with markers
│   ├── alerts/         # Alerts list
│   └── profile/        # User profile
└── widgets/            # Reusable widgets
```

**Backend**
```
backend/
├── routes/
│   ├── auth.js         # Authentication endpoints
│   ├── emergency.js    # Emergency/SOS endpoints
│   ├── alerts.js       # Alert management
│   └── authority.js    # Authority dashboard
├── middleware/
│   └── auth.js         # JWT verification middleware
├── services/           # Business logic
├── database/           # Database schemas & migrations
├── server.js           # Express app entry point
└── package.json        # Dependencies
```

## �️ Backend Setup

### Local Development

```bash
cd backend
npm install
cp .env.example .env
```

Edit `.env`:
```env
PORT=8080
DATABASE_URL=postgresql://user:password@localhost:5432/hazardnet
JWT_SECRET=your_local_secret_key
NODE_ENV=development
```

Start the server:
```bash
npm start
```

Server runs on `http://localhost:8080`

### AWS Deployment

For production deployment on AWS Elastic Beanstalk:
```bash
cd backend
eb init
eb deploy
```

### Update App Configuration

Update `lib/core/constants/app_constants.dart`:
```dart
// Local Backend
static const String apiUrl = 'http://192.168.x.x:8080/api';

// AWS Backend
static const String apiUrl = 'http://hazardnet-production.eba-74z3ihsf.us-east-1.elasticbeanstalk.com/api';
```

## �🚦 Getting Started

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the app**
   ```bash
   flutter run
   ```

## 📱 API Endpoints

**Auth:**
- POST /api/auth/register
- POST /api/auth/login
- GET /api/auth/status

**Emergency:**
- POST /api/emergency/sos
- GET /api/emergency/active
- PUT /api/emergency/:id/resolve

**Alerts:**
- GET /api/alerts
- POST /api/alerts
- PUT /api/alerts/:id

**Authority:**
- GET /api/authority/dashboard
- GET /api/authority/alerts
- PUT /api/authority/verify/:id

## 📡 API Integration Guide

### Hazard Detection API

The camera feed sends frames to the ML model API. Update `lib/bloc/camera/camera_bloc.dart` in the `_onProcessFrame` method to call your YOLOv8 API.

**Expected Request:**
```json
{
  "image": "base64_encoded_image",
  "timestamp": "2025-11-06T10:30:00Z",
  "location": {
    "latitude": 28.6139,
    "longitude": 77.2090
  }
}
```

**Expected Response:**
```json
{
  "detections": [
    {
      "type": "pothole",
      "confidence": 0.92,
      "severity": "high"
    }
  ]
}
```

## 🔧 Next Steps

1. **Setup Backend API**
   - Copy `.env.example` to `.env` and configure your backend API URL
   - Update `lib/core/constants/app_constants.dart` with your API endpoints
   - Implement authentication endpoints (JWT-based recommended)

2. **Connect ML Model**
   - Update API endpoint in `lib/core/constants/app_constants.dart`
   - Implement API call in `lib/bloc/camera/camera_bloc.dart`

3. **Setup Google Maps**
   - Get API key from Google Cloud Console
   - Add to Android manifest and iOS AppDelegate

4. **Setup PostgreSQL Backend**
   - Create database schema for users, hazards, alerts
   - Implement REST API endpoints for CRUD operations
   - Setup JWT authentication

## 📦 Built With

- Flutter 3.35.7
- BLoC for state management
- Material 3 Design
- Camera, GPS, Sensors integration
- Backend-ready (Postgres/REST API)
- Animations with flutter_animate

---

**Built with ❤️ for safer Indian roads**
