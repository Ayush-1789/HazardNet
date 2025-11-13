# HazardNet - Road Hazard Detection App# HazardNet - Road Hazard Detection App



![Flutter](https://img.shields.io/badge/Flutter-3.24.5-blue)![Flutter](https://img.shields.io/badge/Flutter-3.24.5-blue)

![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)

![Node.js](https://img.shields.io/badge/Node.js-20-green)![Node.js](https://img.shields.io/badge/Node.js-20-green)

![AWS](https://img.shields.io/badge/AWS-Elastic%20Beanstalk-orange)![AWS](https://img.shields.io/badge/AWS-Elastic%20Beanstalk-orange)

![License](https://img.shields.io/badge/License-MIT-green)![License](https://img.shields.io/badge/License-MIT-green)



AI-powered hazard detection system with real-time alerts and emergency response. Mobile app (Flutter) + Backend (Node.js) on AWS.AI-powered hazard detection system with real-time alerts and emergency response. Mobile app (Flutter) + Backend (Node.js) on AWS.



## 📱 Screenshots## � Screenshots



### Dashboard| Dashboard | Hazard Map | Detection |

Home screen with journey stats, hazards count, and verified reports|-----------|-----------|-----------|

- Today's journey distance and statistics| ![Dashboard](https://github.com/Ayush-1789/HazardNet/raw/main/assets/screenshots/dashboard.png) | ![Map](https://github.com/Ayush-1789/HazardNet/raw/main/assets/screenshots/map.png) | ![Detection](https://github.com/Ayush-1789/HazardNet/raw/main/assets/screenshots/detection.png) |

- Hazard count, verified hazards, and points earned| **Home Dashboard** - Journey stats, hazards count, verified reports | **Hazard Map** - Interactive map with color-coded markers, nearby hazards list | **Real-time Detection** - Camera feed with ML detection, hazard bounding boxes |

- Quick access buttons for Start Scan and View Map

| Detection Details | Alerts | Scan Screen |

### Hazard Map|-----------|-----------|-----------|

Interactive map showing all hazards with real-time updates| ![Details](https://github.com/Ayush-1789/HazardNet/raw/main/assets/screenshots/details.png) | ![Alerts](https://github.com/Ayush-1789/HazardNet/raw/main/assets/screenshots/alerts.png) | ![Scan](https://github.com/Ayush-1789/HazardNet/raw/main/assets/screenshots/scan.png) |

- Color-coded markers (Red: Your reports, Blue: Others' reports)| **Hazard Details** - Full hazard info, photo, location, confidence score | **Alerts** - Real-time notifications for hazards, road closures, vehicle maintenance | **Scan Screen** - Active detection with FPS metrics and capture buttons |

- Nearby hazards list with risk levels

- Real-time location tracking with map controls## �🚀 Features



### Real-time Detection### Core Features (MVP)

Camera feed with AI hazard detection- ✅ **Real-time Hazard Detection** - Camera feed with frame processing ready for ML model integration

- Live camera feed processing- ✅ **Location Tracking** - GPS-based location tracking with geolocator

- FPS metrics and frame count- ✅ **Interactive Map with OSM** - OpenStreetMap integration showing hazards with color-coded pins

- Hazard detection with bounding boxes (36.7% confidence)  - 🔵 Blue pins: Your own reported hazards

- Capture and flip camera buttons  - 🟠 Orange pins: Hazards reported by other users

  - ✅ Verified hazards marked with green checkmark

### Hazard Details  - 📍 Real-time user location tracking

Full information about detected hazards  - 🗺️ Dark mode support for maps

- Hazard type and confidence score- ✅ **Alert System** - Real-time notifications for nearby hazards

- Photo with detection visualization- ✅ **User Authentication** - Mock auth ready for backend API integration

- Location coordinates and risk level- ✅ **Dashboard** - Quick access to all features with stats

- Report timestamp and user information- ✅ **Vehicle Health Tracking** - Cumulative damage scoring system

- ✅ **Beautiful UI** - Material 3 design with smooth animations and dark mode

### Alerts

Real-time notifications for approaching hazards### Hazard Types Detected

- Pothole Detected Ahead alerts- 🕳️ Potholes

- Road Closure alerts- 🚧 Unmarked Speed Breakers

- Vehicle Maintenance due notifications- 🚫 Obstacles on Road

- Suspension Check Recommended alerts- 🛑 Closed/Blocked Roads

- WARNING and CRITICAL severity labels- 🚦 Lane Blockages



### Scan Screen## 🏗️ Tech Stack

Active hazard detection interface

- Real-time detection status**Mobile (Frontend)**

- FPS (Frames Per Second) metrics- Flutter 3.24.5 & Dart 3.9.2

- Frame count and detection count- Material Design 3

- Camera capture and recording controls- BLoC Pattern (State Management)

- Google Maps API

## 🚀 Features- TensorFlow Lite (On-device ML)



### Core Features (MVP)**Backend**

- ✅ **Real-time Hazard Detection** - Camera feed with frame processing ready for ML model integration- Node.js 20 with Express.js

- ✅ **Location Tracking** - GPS-based location tracking with geolocator- AWS Elastic Beanstalk (hazardnet-production)

- ✅ **Interactive Map** - OpenStreetMap integration showing hazards with color-coded pins- AWS RDS PostgreSQL

  - 🔵 Blue pins: Your own reported hazards- JWT Authentication with bcrypt

  - 🟠 Orange pins: Hazards reported by other users

  - ✅ Verified hazards marked with green checkmark**Deployment**

  - 📍 Real-time user location tracking- GitHub Actions CI/CD

  - 🗺️ Dark mode support for maps- AWS Infrastructure

- ✅ **Alert System** - Real-time notifications for nearby hazards- Environment: Production

- ✅ **User Authentication** - JWT auth with backend integration

- ✅ **Dashboard** - Quick access to all features with stats## 🏗️ Project Architecture

- ✅ **Vehicle Health Tracking** - Cumulative damage scoring system

- ✅ **Beautiful UI** - Material 3 design with smooth animations and dark mode```

lib/

### Hazard Types Detected├── core/

- 🕳️ Potholes│   ├── constants/      # App constants, API endpoints

- 🚧 Unmarked Speed Breakers│   ├── theme/          # App theme, colors, typography

- 🚫 Obstacles on Road│   └── utils/          # Helper utilities

- 🛑 Closed/Blocked Roads├── data/

- 🚦 Lane Blockages│   ├── repositories/   # Data layer abstraction

│   └── services/       # API services, local storage

## 🏗️ Tech Stack├── models/             # Data models (User, Hazard, Alert, etc.)

├── bloc/               # BLoC state management

**Mobile (Frontend)**│   ├── auth/           # Authentication state

- Flutter 3.24.5 & Dart 3.9.2│   ├── camera/         # Camera & detection logic

- Material Design 3│   ├── hazard/         # Hazard detection state

- BLoC Pattern (State Management)│   ├── location/       # Location tracking state

- Google Maps API│   └── alerts/         # Alerts management state

- TensorFlow Lite (On-device ML)├── screens/            # UI screens

│   ├── welcome/        # Welcome/Onboarding screen

**Backend**│   ├── dashboard/      # Main dashboard

- Node.js 20 with Express.js│   ├── camera/         # Real-time hazard detection

- AWS Elastic Beanstalk (hazardnet-production)│   ├── map/            # Google Maps with markers

- AWS RDS PostgreSQL│   ├── alerts/         # Alerts list

- JWT Authentication with bcrypt│   └── profile/        # User profile

└── widgets/            # Reusable widgets

**Deployment**```

- GitHub Actions CI/CD

- AWS Infrastructure## 🖥️ Backend Architecture

- Environment: Production

```

## 🖥️ Backend Setupbackend/

├── routes/

### Local Development│   ├── auth.js         # Authentication endpoints

│   ├── emergency.js    # Emergency/SOS endpoints

```bash│   ├── alerts.js       # Alert management

cd backend│   └── authority.js    # Authority dashboard

npm install├── middleware/

cp .env.example .env│   └── auth.js         # JWT verification middleware

```├── services/           # Business logic

├── database/           # Database schemas & migrations

Edit `.env`:├── server.js           # Express app entry point

```env└── package.json        # Dependencies

PORT=8080```

DATABASE_URL=postgresql://user:password@localhost:5432/hazardnet

JWT_SECRET=your_local_secret_key2. **Run the app**

NODE_ENV=development   ```bash

```   flutter run

   ```

Start the server:

```bash## �️ Backend Setup

npm start

```### Local Development



Server runs on `http://localhost:8080````bash

cd backend

### AWS Deploymentnpm install

cp .env.example .env

For production deployment on AWS Elastic Beanstalk:```

```bash

cd backendEdit `.env`:

eb init```env

eb deployPORT=8080

```DATABASE_URL=postgresql://user:password@localhost:5432/hazardnet

JWT_SECRET=your_local_secret_key

Environment variables are configured in AWS Elastic Beanstalk console.NODE_ENV=development

```

### Update App Configuration

Start the server:

If using local backend, update `lib/core/constants/app_constants.dart`:```bash

npm start

```dart```

// For Local Backend:

static const String apiUrl = 'http://192.168.x.x:8080/api';  // Your machine IPServer runs on `http://localhost:8080`



// For AWS Backend:### AWS Deployment

static const String apiUrl = 'http://hazardnet-production.eba-74z3ihsf.us-east-1.elasticbeanstalk.com/api';

```For production deployment on AWS Elastic Beanstalk:

```bash

## 🚦 Getting Startedcd backend

eb init

### Installationeb deploy

```

1. **Install dependencies**

   ```bashEnvironment variables are configured in AWS Elastic Beanstalk console.

   flutter pub get

   ```### Update App Configuration



2. **Run the app**If using local backend, update `lib/core/constants/app_constants.dart`:

   ```bash

   flutter run```dart

   ```// For Local Backend:

static const String apiUrl = 'http://192.168.x.x:8080/api';  // Your machine IP

## 📡 API Integration Guide

// For AWS Backend:

### Hazard Detection APIstatic const String apiUrl = 'http://hazardnet-production.eba-74z3ihsf.us-east-1.elasticbeanstalk.com/api';

```

The camera feed sends frames to the ML model API. Update `lib/bloc/camera/camera_bloc.dart` in the `_onProcessFrame` method to call your YOLOv8 API.

## 🚦 Getting Started

**Expected Request:**

```json### Installation

{

  "image": "base64_encoded_image",1. **Install dependencies**

  "timestamp": "2025-11-06T10:30:00Z",   ```bash

  "location": {   flutter pub get

    "latitude": 28.6139,   ```

    "longitude": 77.2090

  }## 📡 API Integration Guide

}

```### Hazard Detection API



**Expected Response:**The camera feed sends frames to the ML model API. Update `lib/bloc/camera/camera_bloc.dart` in the `_onProcessFrame` method to call your YOLOv8 API.

```json

{**Expected Request:**

  "detections": [```json

    {{

      "type": "pothole",  "image": "base64_encoded_image",

      "confidence": 0.92,  "timestamp": "2025-11-06T10:30:00Z",

      "severity": "high"  "location": {

    }    "latitude": 28.6139,

  ]    "longitude": 77.2090

}  }

```}

```

## 🔧 Configuration

**Expected Response:**

### Backend Environment Variables```json

{

```env  "detections": [

PORT=8080    {

DATABASE_URL=postgresql://user:pass@rds-host:5432/hazardnet      "type": "pothole",

JWT_SECRET=hazardnet_jwt_secret_key_2025_production      "confidence": 0.92,

NODE_ENV=production      "severity": "high"

```    }

  ]

### Flutter Configuration}

```

Update `lib/core/constants/app_constants.dart`:

```dart## 🔧 Configuration

static const String apiUrl = 'http://hazardnet-production.eba-74z3ihsf.us-east-1.elasticbeanstalk.com/api';

static const String googleMapsKey = 'YOUR_GOOGLE_MAPS_API_KEY';### Backend Environment Variables

```

```env

### AWS SetupPORT=8080

DATABASE_URL=postgresql://user:pass@rds-host:5432/hazardnet

1. **Elastic Beanstalk** - Backend hosting (hazardnet-production)JWT_SECRET=hazardnet_jwt_secret_key_2025_production

2. **RDS PostgreSQL** - Database on AWSNODE_ENV=production

3. **GitHub Secrets** - AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY```

4. **Android Network Security** - HTTP cleartext traffic enabled

### Flutter Configuration

## 🏗️ Project Architecture

Update `lib/core/constants/app_constants.dart`:

``````dart

lib/static const String apiUrl = 'http://hazardnet-production.eba-74z3ihsf.us-east-1.elasticbeanstalk.com/api';

├── core/static const String googleMapsKey = 'YOUR_GOOGLE_MAPS_API_KEY';

│   ├── constants/      # App constants, API endpoints```

│   ├── theme/          # App theme, colors, typography

│   └── utils/          # Helper utilities### AWS Setup

├── data/

│   ├── repositories/   # Data layer abstraction1. **Elastic Beanstalk** - Backend hosting (hazardnet-production)

│   └── services/       # API services, local storage2. **RDS PostgreSQL** - Database on AWS

├── models/             # Data models (User, Hazard, Alert, etc.)3. **GitHub Secrets** - AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY

├── bloc/               # BLoC state management4. **Android Network Security** - HTTP cleartext traffic enabled

│   ├── auth/           # Authentication state

│   ├── camera/         # Camera & detection logic## 🔧 Next Steps

│   ├── hazard/         # Hazard detection state

│   ├── location/       # Location tracking state## 📦 Built With

│   └── alerts/         # Alerts management state

├── screens/            # UI screens- Flutter 3.24.5 + Dart 3.9.2

│   ├── welcome/        # Welcome/Onboarding screen- Node.js 20 + Express.js

│   ├── dashboard/      # Main dashboard- PostgreSQL (AWS RDS)

│   ├── camera/         # Real-time hazard detection- AWS Elastic Beanstalk

│   ├── map/            # Google Maps with markers- TensorFlow Lite

│   ├── alerts/         # Alerts list- Google Maps API

│   └── profile/        # User profile- BLoC state management

└── widgets/            # Reusable widgets- Material Design 3

```- GitHub Actions CI/CD



## 🖥️ Backend Architecture## 📱 API Endpoints



```**Auth:**

backend/- POST /api/auth/register

├── routes/- POST /api/auth/login

│   ├── auth.js         # Authentication endpoints- GET /api/auth/status

│   ├── emergency.js    # Emergency/SOS endpoints

│   ├── alerts.js       # Alert management**Emergency:**

│   └── authority.js    # Authority dashboard- POST /api/emergency/sos

├── middleware/- GET /api/emergency/active

│   └── auth.js         # JWT verification middleware- PUT /api/emergency/:id/resolve

├── services/           # Business logic

├── database/           # Database schemas & migrations**Alerts:**

├── server.js           # Express app entry point- GET /api/alerts

└── package.json        # Dependencies- POST /api/alerts

```- PUT /api/alerts/:id



## 📱 API Endpoints**Authority:**

- GET /api/authority/dashboard

**Auth:**- GET /api/authority/alerts

- POST /api/auth/register- PUT /api/authority/verify/:id

- POST /api/auth/login

- GET /api/auth/status## 🏥 Health Check



**Emergency:**```bash

- POST /api/emergency/soscurl http://hazardnet-production.eba-74z3ihsf.us-east-1.elasticbeanstalk.com/health

- GET /api/emergency/active```

- PUT /api/emergency/:id/resolve

---

**Alerts:**

- GET /api/alerts**Built with ❤️ for safer roads**

- POST /api/alerts
- PUT /api/alerts/:id

**Authority:**
- GET /api/authority/dashboard
- GET /api/authority/alerts
- PUT /api/authority/verify/:id

## 🏥 Health Check

```bash
curl http://hazardnet-production.eba-74z3ihsf.us-east-1.elasticbeanstalk.com/health
```

## 📦 Built With

- Flutter 3.24.5 + Dart 3.9.2
- Node.js 20 + Express.js
- PostgreSQL (AWS RDS)
- AWS Elastic Beanstalk
- TensorFlow Lite
- Google Maps API
- BLoC state management
- Material Design 3
- GitHub Actions CI/CD

## 📸 How to Add Screenshots

To add actual screenshots to the README:

1. Create `assets/screenshots/` folder in your repository
2. Add your screenshots as PNG files:
   - `dashboard.png`
   - `map.png`
   - `detection.png`
   - `details.png`
   - `alerts.png`
   - `scan.png`

3. Update the README with image links:
```markdown
![Dashboard](assets/screenshots/dashboard.png)
```

4. Commit and push to GitHub

## License

MIT License

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

Made with ❤️ for safer roads
