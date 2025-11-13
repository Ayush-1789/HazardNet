# HazardNet - Road Hazard Detection App

[![Flutter](https://img.shields.io/badge/Flutter-3.24.5-blue)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)](https://dart.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20-green)](https://nodejs.org)
[![AWS](https://img.shields.io/badge/AWS-Elastic%20Beanstalk-orange)](https://aws.amazon.com/elasticbeanstalk)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

AI-powered hazard detection system with real-time alerts and emergency response. Mobile app (Flutter) + Backend (Node.js) on AWS.

## 🚀 Features

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

## ⚙️ Backend Setup

### Clone the Repository

```bash
git clone https://github.com/Ayush-1789/HazardNet.git
cd HazardNet
```

### Local Development (In Progress)

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

### AWS Deployment (Recommended for Production)

For production deployment on AWS Elastic Beanstalk:
```bash
cd backend
eb init
eb deploy
```

**AWS Configuration:**
- Elastic Beanstalk Environment: hazardnet-production
- RDS PostgreSQL: Configured and running
- CI/CD: GitHub Actions automated deployment

### Update App Configuration

Update `lib/core/constants/app_constants.dart`:

**For Local Development:**
```dart
static const String apiUrl = 'http://localhost:8080/api';  // Local backend
static const String googleMapsKey = 'YOUR_GOOGLE_MAPS_KEY';
```

**For AWS Deployment (when ready):**
```dart
static const String apiUrl = 'http://hazardnet-production.eba-74z3ihsf.us-east-1.elasticbeanstalk.com/api';  // AWS backend
static const String googleMapsKey = 'YOUR_GOOGLE_MAPS_KEY';
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24.5+
- Node.js 20+
- PostgreSQL
- Android Studio / VS Code

### Installation

**1. Clone Repository:**
```bash
git clone https://github.com/Ayush-1789/HazardNet.git
cd HazardNet
```

**2. Frontend Setup:**
```bash
flutter pub get
```

**3. Backend Setup:**
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

---

## 📁 Project Structure

**Frontend (Flutter)**
- `lib/` - Flutter application source code
  - `bloc/` - BLoC state management
  - `screens/` - UI screens
  - `widgets/` - Reusable components
  - `core/` - Constants and utilities
  - `data/` - API services and models

**Backend (Node.js)**
- `backend/` - Express.js server
  - `routes/` - API endpoints
  - `middleware/` - Authentication
  - `services/` - Business logic
  - `database/` - Schema and migrations

---

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/status` - Check auth status
- `GET /api/auth/profile` - Get user profile

### Hazards
- `GET /api/hazards` - Get all hazards
- `GET /api/hazards/nearby` - Get nearby hazards
- `POST /api/hazards/report` - Report new hazard
- `PUT /api/hazards/:id/verify` - Verify hazard

### Alerts
- `GET /api/alerts` - Get user alerts
- `PUT /api/alerts/:id/read` - Mark alert as read

### Trips
- `POST /api/trips/start` - Start trip
- `POST /api/trips/end` - End trip
- `GET /api/trips/history` - Get trip history

---

## 🧪 Testing

### Run Flutter Tests
```bash
flutter test
```

### Run Backend Tests
```bash
cd backend
npm test
```

### Test API Endpoints
```bash
curl http://localhost:8080/health
```

---

## 🚀 Deployment

### GitHub Actions CI/CD
Push to `main` branch triggers automatic deployment:
1. Code linting and testing
2. Build application
3. Deploy to AWS Elastic Beanstalk (when configured)
4. Database migrations
5. Health check verification

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

---

## 📝 Code Standards

- Follow Flutter best practices
- Use BLoC pattern for state management
- Write meaningful commit messages
- Add tests for new features
- Update documentation

---

## 🐛 Troubleshooting

### App Won't Connect to Backend
- Verify API URL in `app_constants.dart`
- Check if backend server is running
- Verify Android network security config

### Hazard Detection Not Working
- Grant camera and location permissions
- Ensure device has sufficient storage
- Check TensorFlow Lite model is loaded

### Build Issues
```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

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

## 📄 License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2025 HazardNet Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

---

**Built with ❤️ for safer Indian roads**
