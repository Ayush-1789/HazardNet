# HazardNet - Road Hazard Detection App

![Flutter](https://img.shields.io/badge/Flutter-3.35.7-blue)
![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)
![License](https://img.shields.io/badge/License-MIT-green)

A comprehensive cross-platform mobile application for detecting and reporting road hazards using AI-powered computer vision. Built with Flutter for Android, iOS, and Web.

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
│   ├── auth/
│   ├── camera/
│   ├── hazard/
│   ├── location/
│   └── alerts/
├── screens/            # UI screens
│   ├── welcome/
│   ├── dashboard/
│   ├── camera/
│   ├── map/
│   ├── alerts/
│   └── profile/
└── widgets/            # Reusable widgets
```

## 🚦 Getting Started

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the app**
   ```bash
   flutter run
   ```

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
