# 🛡️ HazardNet# 🛡️ HazardNet# HazardNet<div align="center"># HazardNet# HazardNet - AI-Powered Road Hazard Detection System# 🚗 HazardNet - AI-Powered Road Hazard Detection System# 🚗 HazardNet - AI-Powered Road Hazard Detection System



Real-time AI-powered hazard detection and emergency response system built with Flutter and AWS.



---### Real-Time AI-Powered Hazard Detection & Emergency Response System



## Features



- 🎥 **Real-time Hazard Detection** - TensorFlow Lite AI model detects potholes, obstacles, hazards![Flutter](https://img.shields.io/badge/Flutter-3.24.5-blue?logo=flutter) ![Node.js](https://img.shields.io/badge/Node.js-20-green?logo=node.js) ![AWS](https://img.shields.io/badge/AWS-Elastic%20Beanstalk-orange?logo=amazon-aws) ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-RDS-blue?logo=postgresql)AI-powered road hazard detection and reporting system for safer driving.

- 🗺️ **Google Maps Integration** - Interactive map with hazard markers and real-time location

- 🚨 **Emergency SOS** - One-tap emergency alerts with GPS location sharing

- 🎤 **Voice Alerts** - ElevenLabs TTS for audio warnings

- 👮 **Authority Dashboard** - Manage and respond to emergenciesA comprehensive mobile application that detects hazards in real-time using AI, coordinates emergency responses, and connects users with authorities instantly.

- 🔐 **JWT Authentication** - Secure user authentication and authorization



---

---## About# HazardNet## AI-Powered Road Hazard Detection System

## Tech Stack



**Mobile (Frontend)**

- Flutter 3.24.5 & Dart 3.9.2## 📸 Screenshots

- Material Design 3

- BLoC Pattern (State Management)

- Google Maps API

- TensorFlow Lite (On-device ML)| Feature | Description |HazardNet is a mobile application that uses machine learning to detect road hazards in real-time. The app alerts drivers about potholes, obstacles, and speed breakers, while building a community-driven hazard database.



**Backend**|---------|-------------|

- Node.js 20 with Express.js

- AWS Elastic Beanstalk| **Hazard Detection** | Real-time AI detection using TensorFlow Lite |

- AWS RDS PostgreSQL

- JWT Authentication| **Emergency SOS** | One-tap emergency alerts with location |



**Deployment**| **Authority Dashboard** | Manage and respond to emergencies |## Features### Real-time AI-Powered Road Hazard Detection System

- GitHub Actions CI/CD

- AWS Infrastructure

- Environment: Production

---

---



## Quick Start

## 🌟 Features- Real-time hazard detection using TensorFlow Lite

### Prerequisites



```bash

- Flutter SDK 3.24.5+| 🎯 AI-Powered Detection | 🚨 Emergency Response |- Interactive map with hazard markers

- Node.js 20+

- Android Studio / Xcode|-------------------------|----------------------|

- Google Maps API Key

- AWS Account (for backend)| ✅ Real-time hazard detection using TensorFlow Lite<br>✅ Multi-object recognition<br>✅ Instant hazard alerts | ✅ One-tap SOS with GPS location<br>✅ Direct authority notification<br>✅ Emergency history tracking |- Voice alerts for approaching hazards  [![Flutter](https://img.shields.io/badge/Flutter-3.24.5-02569B?logo=flutter)](https://flutter.dev)---

```



### Installation

| 🗺️ Location Services | 🔒 Security & Auth |- Community hazard reporting

```bash

# Clone repo|---------------------|-------------------|

git clone https://github.com/Ayush-1789/HazardNet.git

cd HazardNet| ✅ Google Maps integration<br>✅ Real-time location tracking<br>✅ Geofencing capabilities | ✅ JWT-based authentication<br>✅ Role-based access control<br>✅ Secure API endpoints |- Trip tracking and analytics[![Node.js](https://img.shields.io/badge/Node.js-20.x-339933?logo=node.js)](https://nodejs.org)



# Frontend

flutter pub get

flutter run| 🎤 Accessibility | 👮 Authority Dashboard |- User authentication and profiles



# Backend|-----------------|----------------------|

cd backend

npm install| ✅ Voice commands<br>✅ Text-to-speech feedback<br>✅ Multilingual support | ✅ Real-time alert management<br>✅ User verification<br>✅ Response coordination |[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12+-4169E1?logo=postgresql)](https://postgresql.org)Real-time road hazard detection using machine learning and computer vision to make driving safer for everyone.

npm start

```



------## Tech Stack



## API Endpoints



### Auth## 🏗️ Architecture[![AWS](https://img.shields.io/badge/AWS-Elastic%20Beanstalk-232F3E?logo=amazon-aws)](https://aws.amazon.com)

- `POST /api/auth/register` - Register user

- `POST /api/auth/login` - User login

- `GET /api/auth/status` - Check auth status

### Tech Stack- **Mobile:** Flutter 3.24.5, Dart 3.9.2

### Emergency

- `POST /api/emergency/sos` - Create SOS alert

- `GET /api/emergency/active` - Get active alerts

- `PUT /api/emergency/:id/resolve` - Resolve alert| Component | Technologies |- **Backend:** Node.js 20, Express.js, PostgreSQL[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)## Project Description



### Alerts|-----------|--------------|

- `GET /api/alerts` - Get all alerts

- `POST /api/alerts` - Create alert| **Frontend** | Flutter 3.24.5, Dart 3.9.2, Material Design 3 |- **Cloud:** AWS Elastic Beanstalk, AWS RDS

- `PUT /api/alerts/:id` - Update alert

| **State Management** | BLoC Pattern |

### Authority

- `GET /api/authority/dashboard` - Authority dashboard| **AI/ML** | TensorFlow Lite (On-Device) |- **AI/ML:** TensorFlow Lite INT8 model

- `GET /api/authority/alerts` - Alerts for authority

- `PUT /api/authority/verify/:id` - Verify user| **Backend** | Node.js 20, Express.js |



---| **Database** | PostgreSQL (AWS RDS) |- **Maps:** Google Maps Platform



## Configuration| **Authentication** | JWT, bcrypt |



### Environment Variables| **Maps** | Google Maps API |- **Voice:** ElevenLabs TTS API[Features](#features) • [Architecture](#architecture) • [Installation](#installation) • [Documentation](#api-documentation) • [Contributing](#contributing)



**Backend (.env)**| **Voice** | ElevenLabs TTS |

```

PORT=8080| **Deployment** | AWS Elastic Beanstalk, AWS RDS |

DATABASE_URL=postgresql://user:pass@host:5432/db

JWT_SECRET=your_jwt_secret| **CI/CD** | GitHub Actions |

NODE_ENV=production

```## Installation



**Flutter (lib/core/constants/app_constants.dart)**---

```dart

static const String apiUrl = 'http://your-api-url/api';

static const String googleMapsKey = 'YOUR_GOOGLE_MAPS_KEY';

```## 🚀 Quick Start



---### Mobile App</div>HazardNet is an intelligent road safety application designed to detect and report road hazards in real-time using advanced machine learning and computer vision technologies. The system integrates mobile application development, backend infrastructure, and AI-driven analytics to create a comprehensive solution for driver safety and road awareness.



## Project Structure### Prerequisites



```

HazardNet/

├── lib/                    # Flutter app```bash

│   ├── bloc/              # State management

│   ├── screens/           # UI screens# Required tools```bash

│   ├── widgets/           # Reusable widgets

│   ├── core/              # Constants & utilities- Flutter SDK 3.24.5+

│   └── data/              # API & data models

├── backend/               # Node.js backend- Dart SDK 3.9.2+git clone https://github.com/Ayush-1789/HazardNet.git

│   ├── routes/            # API routes

│   ├── middleware/        # Auth middleware- Node.js 20+

│   └── services/          # Business logic

├── database/              # Schema & migrations- PostgreSQLcd HazardNet---**Version:** 1.0.0  ![Flutter](https://img.shields.io/badge/Flutter-3.24.5-blue)![Flutter](https://img.shields.io/badge/Flutter-3.24.5-blue)

├── detection_models/      # TensorFlow Lite models

└── android/               # Android config- AWS CLI (for deployment)

```

- Android Studio / Xcodeflutter pub get

---

```

## Deployment

flutter run

### AWS Elastic Beanstalk

### Installation

```bash

# Automatic deployment on push to main```

git push origin main

```bash

# Or manual deployment

cd backend# Clone the repository## OverviewThe application leverages TensorFlow Lite for on-device machine learning inference, Google Maps for spatial data visualization, and cloud infrastructure for scalable backend operations. Built for the i.Mobilothon Competition, HazardNet represents a complete end-to-end solution combining mobile development, cloud services, and artificial intelligence.

eb init

eb deploygit clone https://github.com/Ayush-1789/HazardNet.git

```

cd HazardNet### Backend

---



## Testing

# Install Flutter dependencies

```bash

# Test health endpointflutter pub get

curl http://localhost:8080/health

```bash

# Test login

curl -X POST http://localhost:8080/api/auth/login \# Install backend dependencies

  -H "Content-Type: application/json" \

  -d '{"email": "test@example.com", "password": "password123"}'cd backendcd backendHazardNet is an intelligent mobile application that leverages artificial intelligence and computer vision to detect road hazards in real-time. The system combines TensorFlow Lite machine learning models, Google Maps integration, and cloud infrastructure to create a comprehensive road safety solution.**License:** MIT  

```

npm install

---

npm install

## Building APK

# Configure environment

```bash

# Build release APKcp .env.example .envnpm start

flutter build apk --release

# Edit .env with your credentials

# Output: build/app/outputs/flutter-apk/app-release.apk

`````````



---



## License### Local Development### Key Highlights---



MIT License - See LICENSE file for details



---**Backend:**### Build APK



## Contributing```bash



1. Fork the repositorycd backend

2. Create feature branch (`git checkout -b feature/amazing-feature`)

3. Commit changes (`git commit -m 'Add feature'`)npm start

4. Push to branch (`git push origin feature/amazing-feature`)

5. Open Pull Request# Server runs on http://localhost:8080```bash



---```



Made with ❤️ for safer roadsflutter build apk --release- **Real-time Detection**: On-device ML inference with <500ms latency**Platform:** Android (Flutter)![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)



**GitHub**: [@Ayush-1789](https://github.com/Ayush-1789)**Flutter App:**


```bash```

flutter run

# Or build APK- **Community-Driven**: Collaborative hazard reporting and verification system

flutter build apk --release

```## API Endpoints



### Deploy to AWS- **Scalable Backend**: AWS-hosted infrastructure with auto-scaling capabilities## System Architecture



```bash**Authentication**

# Backend deployment (via GitHub Actions)

git push origin main- `POST /api/auth/register` - Register user- **Production-Ready**: Full CI/CD pipeline with automated deployments



# Manual deployment- `POST /api/auth/login` - Login user

cd backend

eb init

eb create

eb deploy**Hazards**

```

- `GET /api/hazards` - Get all hazards---

---

- `GET /api/hazards/nearby` - Get nearby hazards

## 📁 Project Structure

- `POST /api/hazards/report` - Report hazard### Component Overview

```

HazardNet/

├── 📱 lib/                      # Flutter application

│   ├── bloc/                    # BLoC state management**Trips**## Features

│   │   ├── auth/               # Authentication BLoC

│   │   ├── emergency/          # Emergency BLoC- `POST /api/trips/start` - Start trip

│   │   └── hazard/             # Hazard detection BLoC

│   ├── core/                    # Core utilities- `POST /api/trips/end` - End trip---![TensorFlow Lite](https://img.shields.io/badge/TensorFlow-Lite-orange)![TensorFlow Lite](https://img.shields.io/badge/TensorFlow-Lite-orange)

│   │   ├── constants/          # App constants & config

│   │   ├── network/            # API services

│   │   └── utils/              # Helper functions

│   ├── data/                    # Data layer## Configuration### Core Capabilities

│   │   ├── models/             # Data models

│   │   └── repositories/       # Data repositories

│   ├── screens/                 # UI screens

│   │   ├── auth/               # Login/RegisterCreate `.env` file:**Mobile Application (Flutter)**

│   │   ├── home/               # Dashboard

│   │   ├── emergency/          # SOS screen

│   │   └── authority/          # Authority dashboard

│   └── widgets/                 # Reusable widgets```env- **AI-Powered Detection**: TensorFlow Lite model (3.2 MB INT8) detects potholes, obstacles, and speed breakers

├── 🖥️ backend/                   # Node.js backend

│   ├── routes/                  # API routesAPI_BASE_URL=http://your-api-url/api

│   │   ├── auth.js             # Authentication

│   │   ├── emergency.js        # Emergency endpointsGOOGLE_MAPS_API_KEY=your_maps_key- **Interactive Mapping**: Google Maps integration with real-time location tracking and hazard visualization- Cross-platform development using Flutter framework

│   │   ├── alerts.js           # Alert management

│   │   └── authority.js        # Authority endpointsELEVENLABS_API_KEY=your_voice_key

│   ├── middleware/              # Express middleware

│   │   └── auth.js             # JWT verification```- **Voice Alerts**: ElevenLabs TTS integration for audio warnings of approaching hazards

│   ├── services/                # Business logic

│   └── server.js               # Express app entry

├── 🗄️ database/                  # Database files

│   ├── schema.sql              # Database schemaBackend `.env`:- **User Authentication**: Secure JWT-based authentication with bcrypt password encryption- Real-time camera processing for hazard detection

│   ├── migrations.sql          # Migration scripts

│   └── seed_data.sql           # Sample data

├── 🤖 detection_models/          # AI models

│   └── unified_hazards_int8.tflite```env- **Trip Tracking**: Complete journey recording with metrics and analytics

├── 🐳 .github/workflows/        # CI/CD pipelines

│   └── deploy.yml              # AWS deploymentDATABASE_URL=postgresql://user:pass@host:5432/db

└── 📄 README.md                 # This file

```JWT_SECRET=your_secret_key- **Community Verification**: Multi-user hazard confirmation system- GPS-based location tracking and mapping## Overview![Platform](https://img.shields.io/badge/Platform-Android-green)![Platform](https://img.shields.io/badge/Platform-Android-green)



---NODE_ENV=production



## 🔌 API Endpoints```- **Damage Scoring**: Vehicle wear tracking based on hazard exposure



### Authentication

```http

POST /api/auth/register     # Register new user## Project Structure- State management using BLoC pattern

POST /api/auth/login        # User login

GET  /api/auth/status       # Check auth status

POST /api/auth/logout       # Logout user

``````---



### EmergencyHazardNet/

```http

POST /api/emergency/sos           # Create SOS alert├── lib/              # Flutter app source- Offline-first data synchronization

GET  /api/emergency/active        # Get active alerts

GET  /api/emergency/history/:id   # Get user history├── backend/          # Node.js backend

PUT  /api/emergency/:id/resolve   # Resolve alert

```├── android/          # Android config## Architecture



### Alerts├── assets/           # Images and resources

```http

GET  /api/alerts              # Get all alerts└── detection_models/ # ML models

GET  /api/alerts/:id          # Get specific alert

POST /api/alerts              # Create alert```

PUT  /api/alerts/:id          # Update alert

DELETE /api/alerts/:id        # Delete alert### System Components

```

## Deployment

### Authority

```http**Backend Infrastructure (Node.js/Express)**HazardNet is an intelligent mobile application that detects road hazards in real-time using AI-powered computer vision. The app combines machine learning models, Google Maps integration, voice alerts, and community reporting to help drivers navigate safely and avoid accidents.![License](https://img.shields.io/badge/License-MIT-green)![License](https://img.shields.io/badge/License-MIT-green)

GET  /api/authority/dashboard     # Authority dashboard data

GET  /api/authority/alerts        # Alerts for authorityAutomatic deployment via GitHub Actions to AWS Elastic Beanstalk on push to main branch.

PUT  /api/authority/verify/:id    # Verify user

POST /api/authority/broadcast     # Broadcast message```

```

## Contributing

---

┌─────────────────┐- RESTful API server with Express.js

## 💡 How It Works

1. Fork the repository

1. **Hazard Detection**: AI model processes camera feed in real-time

2. **Alert Generation**: System creates alert with location and hazard type2. Create feature branch│  Flutter App    │ ◄── User Interface Layer

3. **Authority Notification**: Nearby authorities receive instant notification

4. **Emergency Response**: Authority can coordinate response via dashboard3. Commit changes

5. **Status Updates**: Real-time status updates to all parties

6. **Resolution**: Alert marked resolved with response summary4. Push to branch│  (Dart 3.9.2)   │- User authentication and authorization



---5. Create Pull Request



## 🧪 Testing└────────┬────────┘



### Test the Live API## License



```bash         │- Data persistence and analytics

# Health check

curl http://hazardnet-production.eba-74z3ihsf.us-east-1.elasticbeanstalk.com/healthMIT License



# Test authentication         ▼

curl -X POST http://hazardnet-production.eba-74z3ihsf.us-east-1.elasticbeanstalk.com/api/auth/login \

  -H "Content-Type: application/json" \## Contact

  -d '{"email": "test@example.com", "password": "password123"}'

```┌─────────────────┐- Real-time notification systemBuilt for the i.Mobilothon Competition, HazardNet represents a complete solution for road safety with both mobile and backend infrastructure.![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen)![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen)



### Local TestingGitHub: [@Ayush-1789](https://github.com/Ayush-1789)

│   REST API      │ ◄── Backend Services

```bash

# Run Flutter tests│  (Node.js 20)   │- Database management with PostgreSQL

flutter test

└────────┬────────┘

# Run backend tests

cd backend         │

npm test

         ▼

# Test specific endpoint

curl http://localhost:8080/health┌─────────────────┐**Cloud Services (AWS)**

```

│   PostgreSQL    │ ◄── Data Persistence

---

│   (AWS RDS)     │- Application hosting via Elastic Beanstalk---

## ⚙️ Configuration

└─────────────────┘

### Environment Variables

```- Relational database service (RDS)

**Backend (`.env`)**

```env

PORT=8080

DATABASE_URL=postgresql://user:pass@host:5432/dbname### Technology Stack- Automated CI/CD pipeline via GitHub Actions

JWT_SECRET=your_jwt_secret_key

NODE_ENV=production

```

**Frontend**- Auto-scaling and load balancing

**Flutter (`lib/core/constants/app_constants.dart`)**

```dart- Flutter 3.24.5 with Dart 3.9.2

class AppConstants {

  static const String apiUrl = 'http://your-api-url/api';- BLoC pattern for state management## Core Features**HazardNet** is an intelligent road safety application that uses **AI-powered computer vision** with **TensorFlow Lite** to detect road hazards in real-time, helping drivers avoid accidents and navigate safely.**HazardNet** is an intelligent road safety application that uses **AI-powered computer vision** with **TensorFlow Lite** to detect road hazards in real-time, helping drivers avoid accidents and navigate safely.

  static const String googleMapsKey = 'YOUR_GOOGLE_MAPS_KEY';

}- Google Maps Flutter SDK

```

- TensorFlow Lite for ML inference**Machine Learning Model**

### AWS Setup



1. Create RDS PostgreSQL instance

2. Create Elastic Beanstalk application**Backend**- TensorFlow Lite INT8 quantized model

3. Configure GitHub secrets:

   - `AWS_ACCESS_KEY_ID`- Node.js 20.x runtime

   - `AWS_SECRET_ACCESS_KEY`

4. Push to trigger deployment- Express.js web framework- Custom training on Indian road datasets



---- PostgreSQL database



## 📄 License- JWT authentication- On-device inference for minimal latency### Real-Time Hazard Detection



This project is licensed under the MIT License.



```**Infrastructure**- GPU acceleration support

MIT License

- AWS Elastic Beanstalk (Application hosting)

Copyright (c) 2025 HazardNet Team

- AWS RDS (Database management)- AI-powered detection using TensorFlow Lite model (3.2 MB INT8 quantized)

Permission is hereby granted, free of charge, to any person obtaining a copy

of this software and associated documentation files (the "Software"), to deal- GitHub Actions (CI/CD pipeline)

in the Software without restriction, including without limitation the rights

to use, copy, modify, merge, publish, distribute, sublicense, and/or sell---

copies of the Software, and to permit persons to whom the Software is

furnished to do so, subject to the following conditions:---



The above copyright notice and this permission notice shall be included in all- Identifies potholes, obstacles, speed breakers, and road hazardsBuilt for the **i.Mobilothon Competition**, this comprehensive solution combines **Machine Learning**, **Google Maps**, **Voice Alerts**, and **Community Reporting** to make roads safer for everyone.Built for the **i.Mobilothon Competition**, this comprehensive solution combines **Machine Learning**, **Google Maps**, **Voice Alerts**, and **Community Reporting** to make roads safer for everyone.

copies or substantial portions of the Software.

## Installation

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,## Technology Stack

FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE

AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER### Prerequisites

LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE- Processes video frames at 256x256 resolution

SOFTWARE.

```Ensure you have the following installed:



---- [Flutter SDK](https://flutter.dev) (3.24.5+)### Frontend Development



## 🤝 Contributing- [Node.js](https://nodejs.org) (20.x+)



Contributions are welcome! Please feel free to submit a Pull Request.- [Git](https://git-scm.com)| Technology | Version | Purpose |- Background monitoring with motion detection



1. Fork the repository- Android Studio with SDK

2. Create your feature branch (`git checkout -b feature/AmazingFeature`)

3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)|-----------|---------|---------|

4. Push to the branch (`git push origin feature/AmazingFeature`)

5. Open a Pull Request### Quick Start



---| Flutter | 3.24.5 | Cross-platform mobile framework |- GPU-accelerated inference for optimal performance



### ⭐ Star this repo if you find it helpful!1. **Clone the repository**



Made with ❤️ using Flutter, AWS, and TensorFlow Lite   ```bash| Dart | 3.9.2 | Programming language |



---   git clone https://github.com/Ayush-1789/HazardNet.git



**🚨 [Live Demo](http://hazardnet-production.eba-74z3ihsf.us-east-1.elasticbeanstalk.com)** • **📝 [Report Bug](https://github.com/Ayush-1789/HazardNet/issues)** • **💡 [Request Feature](https://github.com/Ayush-1789/HazardNet/issues)**   cd HazardNet| Google Maps | Latest | Map integration and visualization |------


   ```

| TensorFlow Lite | - | Machine learning inference |

2. **Install Flutter dependencies**

   ```bash| BLoC | 8.1.6 | State management |### Interactive Map System

   flutter pub get

   ```| HTTP/Dio | Latest | Network communication |



3. **Configure environment variables**- Full Google Maps integration with real-time location tracking

   ```bash

   cp .env.example .env### Backend Development

   # Edit .env with your API keys

   ```| Technology | Version | Purpose |- Color-coded hazard markers:



4. **Run the application**|-----------|---------|---------|

   ```bash

   flutter run| Node.js | 20.x | JavaScript runtime |  - Blue: Your own reported hazards## ✨ Key Features## ✨ Key Features

   ```

| Express.js | 5.x | Web application framework |

5. **Build release APK**

   ```bash| PostgreSQL | 12+ | Relational database |  - Orange: Community-reported hazards

   flutter build apk --release

   ```| JWT | - | Authentication tokens |



### Backend Setup| Bcrypt | 3.0+ | Password encryption |  - Green: Verified hazards by multiple users



1. **Navigate to backend directory**

   ```bash

   cd backend### Infrastructure & Deployment- Multiple map types (Normal, Satellite, Hybrid, Terrain)

   npm install

   ```| Service | Provider | Function |



2. **Configure database connection**|---------|----------|----------|- Interactive gesture controls (zoom, rotate, tilt)### 🤖 AI-Powered Hazard Detection### 🤖 AI-Powered Hazard Detection

   ```bash

   cp .env.example .env| App Hosting | AWS Elastic Beanstalk | Scalable application deployment |

   # Set DATABASE_URL and JWT_SECRET

   ```| Database | AWS RDS PostgreSQL | Managed database service |- Dark mode support



3. **Run migrations and start server**| CI/CD | GitHub Actions | Automated testing and deployment |

   ```bash

   npm run migrate| Maps API | Google Cloud | Mapping and location services |- **TensorFlow Lite Model**: `unified_hazards_int8.tflite` (3.2 MB INT8 quantized)- **TensorFlow Lite Model**: `unified_hazards_int8.tflite` (3.2 MB INT8 quantized)

   npm start

   ```| Voice API | ElevenLabs | Text-to-speech synthesis |



---### Voice Alert System



## API Documentation---



### Base URL- Natural-sounding voice warnings via ElevenLabs TTS- **Real-time Detection**: Detects potholes, obstacles, and speed breakers at 256×256 resolution- **Real-time Detection**: Detects potholes, obstacles, and speed breakers at 256×256 resolution

```

Production: http://hazardnet-production.eba-74z3ihsf.us-east-1.elasticbeanstalk.com/api## Feature Set

```

- Customizable alert distance and speaking speed

### Authentication

### Core Features

#### Register User

```http- Pre-configured messages for different hazard types- **Background Processing**: Continuous monitoring with gyroscope-based motion detection- **Background Processing**: Continuous monitoring with gyroscope-based motion detection

POST /api/auth/register

Content-Type: application/json**Real-Time Hazard Detection**



{- Automatic detection of potholes, obstacles, and speed breakers- Real-time audio notifications for approaching dangers

  "email": "user@example.com",

  "password": "secure_password",- TensorFlow Lite model processing at 256x256 resolution

  "displayName": "John Doe",

  "phoneNumber": "+1234567890",- Background monitoring with motion detection- Intelligent cooldown to prevent alert repetition- **GPU Acceleration**: Optimized with ProGuard rules for maximum performance- **GPU Acceleration**: Optimized with ProGuard rules for maximum performance

  "vehicleType": "car"

}- GPU-accelerated inference for optimal performance

```

- Confidence threshold filtering for accuracy

#### Login

```http

POST /api/auth/login

Content-Type: application/json**Map Integration**### Community & Reporting- **High Accuracy**: Latest model with improved detection capabilities- **High Accuracy**: Latest model with improved detection capabilities



{- Interactive Google Maps with real-time location tracking

  "email": "user@example.com",

  "password": "secure_password"- Color-coded hazard markers:- User authentication with JWT-based security

}

```  - Blue markers: User's own reported hazards



**Response:**  - Orange markers: Community-reported hazards- Submit hazard reports with photos and location data

```json

{  - Green markers: Verified hazards with multiple confirmations

  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",

  "user": {- Multiple map types: Normal, Satellite, Hybrid, Terrain- Community verification system with multi-signature support

    "id": 1,

    "email": "user@example.com",- Gesture-based navigation (zoom, rotate, tilt)

    "displayName": "John Doe"

  }- Real-time push notifications for nearby hazards### 🗺️ Google Maps Integration### 🗺️ Google Maps Integration

}

```**Voice Alert System**



### Hazards- ElevenLabs-powered text-to-speech synthesis- User profiles with driving statistics and damage scores



#### Get Nearby Hazards- Customizable alert distance and voice parameters

```http

GET /api/hazards/nearby?lat=28.6139&lon=77.2090&radius=500- Pre-configured hazard warning templates- **Native Google Maps**: Full integration with Google Maps Platform- **Native Google Maps**: Full integration with Google Maps Platform

```

- Real-time audio notifications

#### Report Hazard

```http- Smart alert cooldown mechanism### Advanced Analytics

POST /api/hazards/report

Authorization: Bearer <token>

Content-Type: application/json

**Community Features**- Vehicle damage tracking and wear monitoring- **Interactive Hazard Map**: Visual markers for all detected and reported hazards- **Interactive Hazard Map**: Visual markers for all detected and reported hazards

{

  "latitude": 28.6139,- User registration with email verification

  "longitude": 77.2090,

  "hazardType": "pothole",- Hazard submission with photo attachments- Complete trip history and driving pattern analysis

  "severity": "high",

  "description": "Large pothole on main road"- Community-based verification system

}

```- Real-time notifications for nearby hazards- Fleet management features for B2B applications- **Real-time Location**: Live GPS tracking with location-based alerts- **Real-time Location**: Live GPS tracking with location-based alerts



### Trips- User profile with statistics and metrics



#### Start Trip- Performance metrics and detection statistics

```http

POST /api/trips/start**Analytics and Tracking**

Authorization: Bearer <token>

Content-Type: application/json- Vehicle damage score monitoring- **Community Markers**: Color-coded pins showing hazards from all users- **Community Markers**: Color-coded pins showing hazards from all users



{- Complete trip history and playback

  "startLatitude": 28.6139,

  "startLongitude": 77.2090- Driving pattern analysis---

}

```- Fleet management capabilities (B2B)



#### End Trip- Performance metrics and reporting  - 🔵 Blue: Your reported hazards  - 🔵 Blue: Your reported hazards

```http

POST /api/trips/end

Authorization: Bearer <token>

Content-Type: application/json---## Technology Stack



{

  "endLatitude": 28.7041,

  "endLongitude": 77.1025,## Installation and Setup  - 🟠 Orange: Community-reported hazards  - 🟠 Orange: Community-reported hazards

  "tripId": 123

}

```

### System Requirements### Frontend (Mobile)

---



## Project Structure

**Mobile Development**- **Framework:** Flutter 3.24.5  - ✅ Green: Verified hazards  - ✅ Green: Verified hazards

```

HazardNet/- Flutter SDK: 3.24.5 or higher

├── lib/                      # Flutter application source

│   ├── main.dart            # Application entry point- Dart SDK: 3.9.2 or higher- **Language:** Dart 3.9.2

│   ├── bloc/                # State management (BLoC)

│   ├── screens/             # UI screens- Android Studio with Android SDK (API 28+)

│   ├── widgets/             # Reusable widgets

│   ├── data/                # Data layer (API, models)- Minimum Android Version: Android 9 (API 28)- **State Management:** BLoC Pattern- **Multiple Map Types**: Normal, Satellite, Hybrid, Terrain views- **Multiple Map Types**: Normal, Satellite, Hybrid, Terrain views

│   └── core/                # Constants and utilities

├── backend/                  # Node.js backend- Required RAM: 4GB minimum, 6GB recommended

│   ├── server.js            # Express server

│   ├── routes/              # API endpoints- **Maps:** Google Maps Flutter SDK

│   ├── middleware/          # Auth middleware

│   ├── database/            # Schema and migrations**Backend Development**

│   └── services/            # Business logic

├── android/                  # Android platform files- Node.js: 20.x or higher- **Machine Learning:** TensorFlow Lite Flutter- **Custom Styling**: Dark mode support with custom map themes- **Custom Styling**: Dark mode support with custom map themes

├── assets/                   # Images and resources

├── detection_models/         # TensorFlow Lite models- npm: 8.x or higher

└── pubspec.yaml             # Flutter dependencies

```- PostgreSQL: 12 or higher- **HTTP Client:** Dio and HTTP packages



---- Git version control



## Deployment- **Storage:** Shared Preferences, Hive- **Gesture Controls**: Zoom, rotate, tilt for 3D views- **Gesture Controls**: Zoom, rotate, tilt for 3D views



### AWS Elastic Beanstalk### Project Setup



The application is configured for automatic deployment via GitHub Actions.- **UI:** Material Design 3



**Required Environment Variables:****Step 1: Clone Repository**

```bash

DATABASE_URL=postgresql://user:pass@host:5432/db```bash

JWT_SECRET=your-secret-key-min-32-chars

NODE_ENV=productiongit clone https://github.com/Ayush-1789/HazardNet.git

PORT=8080

```cd HazardNet### Backend (Server)



**GitHub Secrets:**```

- `AWS_ACCESS_KEY_ID`

- `AWS_SECRET_ACCESS_KEY`- **Runtime:** Node.js 20### 🔊 Voice Assistant (ElevenLabs TTS)### 🔊 Voice Assistant (ElevenLabs TTS)



### CI/CD Pipeline**Step 2: Configure Flutter Application**



Push to `main` branch triggers:```bash- **Framework:** Express.js

1. Code linting and testing

2. Build application# Install dependencies

3. Deploy to AWS Elastic Beanstalk

4. Run database migrationsflutter pub get- **Database:** PostgreSQL (AWS RDS)- **AI-Powered Voice Alerts**: Natural-sounding text-to-speech warnings- **AI-Powered Voice Alerts**: Natural-sounding text-to-speech warnings

5. Health check verification



---

# Create environment file- **Authentication:** JWT (JSON Web Tokens)

## Development

cp .env.example .env

### Code Standards

- **Hosting:** AWS Elastic Beanstalk- **Real-time Notifications**: Voice alerts for approaching hazards- **Real-time Notifications**: Voice alerts for approaching hazards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines

- Use ESLint for JavaScript/Node.js code# Configure API endpoints and keys

- Write meaningful commit messages

- Add tests for new features# Edit .env:- **Environment:** Production-ready with auto-scaling



### Running Tests# API_BASE_URL=http://hazardnet-production.eba-74z3ihsf.us-east-1.elasticbeanstalk.com/api



```bash# ELEVENLABS_API_KEY=your_elevenlabs_key- **Customizable Settings**:- **Customizable Settings**:

# Flutter tests

flutter test# GOOGLE_MAPS_API_KEY=your_google_maps_key



# Backend tests```### AI & Machine Learning

cd backend && npm test

```



### Git Workflow**Step 3: Configure Backend Services**- **Model:** TensorFlow Lite INT8 quantized  - Adjust voice characteristics  - Adjust voice characteristics



1. Create feature branch: `git checkout -b feature/your-feature````bash

2. Commit changes: `git commit -m "Add your feature"`

3. Push branch: `git push origin feature/your-feature`cd backend- **Training:** Custom dataset optimized for Indian road conditions

4. Create Pull Request on GitHub

5. Wait for review and approval

6. Merge to main branch

# Install Node dependencies- **Inference:** On-device real-time processing  - Control speaking speed  - Control speaking speed

---

npm install

## Performance

- **Optimization:** GPU acceleration and background processing

- **API Response Time**: <500ms average

- **ML Inference**: <500ms per frame# Create environment configuration

- **App Size**: ~80MB (release APK)

- **Database**: Indexed queries <100mscp .env.example .env  - Set warning distance thresholds  - Set warning distance thresholds

- **Uptime**: 99.5% SLA



---

# Configure database connection### Cloud Infrastructure

## Security

# Edit .env:

- JWT tokens with 7-day expiration

- Bcrypt password hashing (10 salt rounds)# DATABASE_URL=postgresql://user:password@host:5432/database- **App Hosting:** AWS Elastic Beanstalk- **Smart Templates**: Pre-configured messages for different hazard types- **Smart Templates**: Pre-configured messages for different hazard types

- HTTPS/HTTP support with network security config

- Input validation on all endpoints# JWT_SECRET=your_secure_secret_key

- SQL injection prevention via parameterized queries

- Rate limiting on authentication endpoints# NODE_ENV=production- **Database:** AWS RDS PostgreSQL



---



## Contributing# Run database migrations- **CI/CD:** GitHub Actions automated deployment



We welcome contributions! Please follow these steps:npm run migrate



1. Fork the repository- **Maps Service:** Google Maps Platform API

2. Create a feature branch

3. Make your changes# Start backend server

4. Write/update tests

5. Submit a pull requestnpm start- **Voice Service:** ElevenLabs TTS API### 👥 Community Features### 👥 Community Features



Please read [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.```



---



## License**Step 4: Build Mobile Application**



This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.```bash---- **User Authentication**: Secure JWT-based signup/login- **User Authentication**: Secure JWT-based signup/login



---# Clean previous builds



## Teamflutter clean



Built with dedication by the HazardNet development team.



### Acknowledgments# Get updated dependencies## Installation & Setup- **Hazard Reporting**: Submit hazards with photos, location, and details- **Hazard Reporting**: Submit hazards with photos, location, and details



- i.Mobilothon Competition organizersflutter pub get

- TensorFlow and Flutter communities

- Google Maps Platform

- AWS cloud services

- ElevenLabs for voice synthesis# Build release APK



---flutter build apk --release### Requirements- **Community Verification**: Multi-signature verification system- **Community Verification**: Multi-signature verification system



## Support



- **Issues**: [GitHub Issues](https://github.com/Ayush-1789/HazardNet/issues)# Output: build/app/outputs/flutter-apk/app-release.apk- Flutter SDK 3.24.5 or later

- **Documentation**: [Wiki](https://github.com/Ayush-1789/HazardNet/wiki)

- **Email**: support@hazardnet.com```



---- Dart 3.9.2 or later- **Real-time Alerts**: Push notifications for nearby hazards- **Real-time Alerts**: Push notifications for nearby hazards



<div align="center">---



**⭐ Star this repo if you find it helpful!**- Android Studio with Android SDK



Made with ❤️ for safer roads## API Reference



[Back to Top](#hazardnet)- Git version control- **User Profiles**: Track driving statistics and damage scores- **User Profiles**: Track driving statistics and damage scores



</div>### Authentication Endpoints

- Node.js 20+ (for backend development)

| Method | Endpoint | Description | Auth Required |

|--------|----------|-------------|---|

| POST | `/api/auth/register` | User registration | No |

| POST | `/api/auth/login` | User authentication | No |### Clone Repository

| GET | `/api/auth/status` | Verify authentication | Yes |

| GET | `/api/auth/profile` | Retrieve user profile | Yes |```bash### 📊 Advanced Analytics### 📊 Advanced Analytics



### Hazard Management Endpointsgit clone https://github.com/Ayush-1789/HazardNet.git



| Method | Endpoint | Description | Auth Required |cd HazardNet- **Vehicle Damage Tracking**: Monitor vehicle wear and tear- **Vehicle Damage Tracking**: Monitor vehicle wear and tear

|--------|----------|-------------|---|

| GET | `/api/hazards` | List all hazards | No |```

| GET | `/api/hazards/nearby` | Get hazards near location | No |

| POST | `/api/hazards/report` | Submit new hazard report | Yes |- **Trip History**: Record and analyze driving patterns- **Trip History**: Record and analyze driving patterns

| PUT | `/api/hazards/:id/verify` | Verify hazard accuracy | Yes |

### Mobile App Setup

### Alert Management Endpoints

```bash- **Fleet Analytics**: B2B features for fleet management- **Fleet Analytics**: B2B features for fleet management

| Method | Endpoint | Description | Auth Required |

|--------|----------|-------------|---|# Install Flutter dependencies

| GET | `/api/alerts` | Retrieve user alerts | Yes |

| PUT | `/api/alerts/:id/read` | Mark alert as read | Yes |flutter pub get- **Performance Metrics**: Detection accuracy and response times- **Performance Metrics**: Detection accuracy and response times



### Trip Tracking Endpoints



| Method | Endpoint | Description | Auth Required |# Create environment configuration

|--------|----------|-------------|---|

| POST | `/api/trips/start` | Begin trip recording | Yes |cp .env.example .env

| POST | `/api/trips/end` | End trip recording | Yes |

| GET | `/api/trips/history` | Retrieve trip history | Yes |------



---# Edit .env file with API keys and settings



## Deployment Guide# API_BASE_URL=http://your-api-endpoint/api



### AWS Elastic Beanstalk Configuration# ELEVENLABS_API_KEY=your_api_key



**Prerequisites**# GOOGLE_MAPS_API_KEY=your_maps_key## 🛠️ Tech Stack## 🛠️ Tech Stack

- AWS account with appropriate IAM permissions

- GitHub repository access with secrets configured

- Domain name (optional but recommended)

# Run app on connected device

**Environment Variables**

```flutter run

DATABASE_URL=postgresql://username:password@rds-endpoint:5432/hazardnet

JWT_SECRET=your_secure_jwt_secret_minimum_32_characters### Frontend (Flutter)### Frontend (Flutter)

NODE_ENV=production

PORT=8080# Build release APK

```

flutter build apk --release- **Framework**: Flutter 3.24.5- **Framework**: Flutter 3.24.5

**GitHub Actions Secrets**

- `AWS_ACCESS_KEY_ID`: AWS IAM access key```

- `AWS_SECRET_ACCESS_KEY`: AWS IAM secret key

- **Language**: Dart 3.9.2- **Language**: Dart 3.9.2

**Deployment Process**

1. Push changes to `main` branch### Backend Setup (Development)

2. GitHub Actions workflow triggers automatically

3. Application builds and tests execute```bash- **State Management**: BLoC Pattern- **State Management**: BLoC Pattern

4. Deployment to Elastic Beanstalk environment

5. Database migrations run automaticallycd backend

6. Application becomes available at EB URL

- **Maps**: Google Maps Flutter- **Maps**: Google Maps Flutter

**Database Schema**

The system uses the following primary tables:# Install Node dependencies

- `users`: User accounts and authentication

- `hazards`: Reported road hazardsnpm install- **ML**: TensorFlow Lite Flutter- **ML**: TensorFlow Lite Flutter

- `alerts`: User notifications and alerts

- `trips`: Trip records and metrics

- `sensor_data`: Vehicle sensor information

- `hazard_verifications`: Community verification records# Create environment file- **Networking**: HTTP/Dio- **Networking**: HTTP/Dio



---cp .env.example .env



## Development Workflow- **Storage**: Shared Preferences, Hive- **Storage**: Shared Preferences, Hive



### Code Organization# Configure environment variables



```# DATABASE_URL=postgresql://user:password@host:5432/db- **UI**: Material Design 3- **UI**: Material Design 3

HazardNet/

├── lib/                          # Flutter application source# JWT_SECRET=your_secret_key

│   ├── main.dart                # Application entry point

│   ├── bloc/                     # BLoC state management# NODE_ENV=development

│   │   ├── auth/                # Authentication BLoC

│   │   ├── camera/              # Camera management

│   │   ├── hazard/              # Hazard detection

│   │   ├── location/            # Location tracking# Run database migrations### Backend (Node.js)### Backend (Node.js)

│   │   └── alerts/              # Alert notifications

│   ├── screens/                 # UI screensnpm run migrate

│   │   ├── auth/                # Login and registration

│   │   ├── dashboard/           # Main dashboard- **Runtime**: Node.js 20 (AWS Elastic Beanstalk)- **Runtime**: Node.js 20 (AWS Elastic Beanstalk)

│   │   ├── map/                 # Map view

│   │   └── profile/             # User profile# Start development server

│   ├── widgets/                 # Reusable UI components

│   ├── data/                     # Data layernpm start- **Framework**: Express.js- **Framework**: Express.js

│   │   ├── services/            # API and device services

│   │   └── models/              # Data models```

│   ├── core/                     # Core utilities

│   │   ├── constants/           # Application constants- **Database**: PostgreSQL (AWS RDS)- **Database**: PostgreSQL (AWS RDS)

│   │   ├── theme/               # UI theming

│   │   └── utils/               # Utility functions### Build Release APK

│   └── detection_models/        # ML model files

├── backend/                      # Node.js backend```bash- **Authentication**: JWT- **Authentication**: JWT

│   ├── server.js                # Express application

│   ├── routes/                  # API route handlersflutter clean

│   │   ├── auth.js              # Authentication routes

│   │   ├── hazards.js           # Hazard managementflutter pub get- **ORM**: Direct SQL queries- **ORM**: Direct SQL queries

│   │   ├── alerts.js            # Alert management

│   │   ├── trips.js             # Trip trackingflutter build apk --release

│   │   └── authority.js         # Authority operations

│   ├── middleware/              # Express middleware- **Deployment**: AWS Elastic Beanstalk- **Deployment**: AWS Elastic Beanstalk

│   │   └── auth.js              # JWT authentication

│   ├── services/                # Business logic# Output location: build/app/outputs/flutter-apk/app-release.apk

│   ├── database/                # Database operations

│   │   ├── schema.sql           # Database schema# Size: ~79-83 MB

│   │   └── migrations.sql       # Schema migrations

│   └── package.json             # Dependencies```

├── android/                      # Android-specific files

├── assets/                       # Images and resources### AI/ML### AI/ML

├── pubspec.yaml                 # Flutter dependencies

├── package.json                 # Backend dependencies---

└── README.md                    # This file

```- **Model**: TensorFlow Lite INT8 quantized- **Model**: TensorFlow Lite INT8 quantized



### Development Standards## Usage Guide



**Code Quality**- **Training**: Custom dataset for Indian road conditions- **Training**: Custom dataset for Indian road conditions

- Follow Dart and JavaScript style guidelines

- Implement comprehensive error handling### First Launch

- Use meaningful variable and function names

- Add inline documentation for complex logic1. Install the APK on your Android device- **Inference**: Real-time on-device processing- **Inference**: Real-time on-device processing

- Maintain consistent code formatting

2. Grant required permissions:

**Testing Requirements**

- Write unit tests for business logic   - Location (GPS access)- **Optimization**: GPU acceleration, background processing- **Optimization**: GPU acceleration, background processing

- Test API endpoints with various scenarios

- Verify ML model performance   - Camera (hazard detection)

- Test on multiple Android versions

- Conduct user acceptance testing   - Storage (image storage)



**Version Control**   - Microphone (voice features)

1. Create feature branch: `git checkout -b feature/description`

2. Implement changes with clear commits3. Create account with email and password### Cloud Services### Cloud Services

3. Push to branch: `git push origin feature/description`

4. Submit pull request with documentation4. Configure voice assistant and notification settings

5. Address code review feedback

6. Merge after approval- **Hosting**: AWS Elastic Beanstalk- **Hosting**: AWS Elastic Beanstalk



---### Driving Mode



## Performance Specifications1. Open app and allow location access- **Database**: AWS RDS PostgreSQL- **Database**: AWS RDS PostgreSQL



**Mobile Application**2. Camera automatically detects hazards in real-time

- Target Device: Android 9+ (API 28+)

- Minimum RAM: 3GB3. Receive audio warnings for approaching hazards- **CI/CD**: GitHub Actions- **CI/CD**: GitHub Actions

- Battery Impact: Optimized background processing

- Network Usage: Minimal with local caching4. View community hazards on interactive map

- Storage: ~80-90MB for APK

5. Report new hazards by tapping screen and adding details- **Maps**: Google Maps Platform- **Maps**: Google Maps Platform

**Backend Infrastructure**

- Response Time: <500ms for API requests

- Database Queries: Indexed for optimal performance

- Concurrent Users: Auto-scaling up to 100+ users### Report a Hazard- **Voice**: ElevenLabs TTS API- **Voice**: ElevenLabs TTS API

- Uptime SLA: 99.5%

- Backup: Automated daily backups1. Detection: App automatically identifies hazards via camera



**Machine Learning Model**2. Manual Report: Tap screen to report additional hazards

- Inference Time: <500ms per frame

- Accuracy: 85%+ on test datasets3. Add Details: Include photo, severity level, description

- Model Size: 3.2MB (INT8 quantized)

- Processing: GPU-accelerated when available4. Submit: Send to community for verification------



---5. Verification: Community votes to confirm accuracy



## Support and Maintenance



**Issue Reporting**---

- Use GitHub Issues for bug reports

- Provide detailed reproduction steps## 🚀 Installation## 🚀 Installation

- Include device and OS information

- Attach logs and screenshots## API Endpoints



**Security Considerations**

- JWT tokens expire after 7 days

- Passwords encrypted with bcrypt### Authentication

- HTTPS/HTTP support with proper configuration

- Input validation on all endpoints- `POST /api/auth/register` - Create new user account### Prerequisites### Prerequisites

- Rate limiting implemented

- `POST /api/auth/login` - User login with credentials

**Future Enhancements**

- iOS platform support- `GET /api/auth/status` - Check authentication status- **Flutter SDK** (3.24.5 or later)- **Flutter SDK** (3.24.5 or later)

- Advanced ML model improvements

- Real-time multiplayer features- `GET /api/auth/profile` - Retrieve user profile

- Offline mode expansion

- Advanced analytics dashboard- **Android Studio** with Android SDK- **Android Studio** with Android SDK



---### Hazards



## License- `GET /api/hazards` - Fetch all hazards- **Git**- **Git**



This project is licensed under the MIT License. For details, see LICENSE file.- `GET /api/hazards/nearby` - Get hazards near location



---- `POST /api/hazards/report` - Report new hazard- **Node.js** (for backend development)- **Node.js** (for backend development)



## Project Information- `PUT /api/hazards/:id/verify` - Verify hazard report



**Version:** 1.0.0

**Status:** Production Ready

**Last Updated:** November 13, 2025### Alerts

**Repository:** https://github.com/Ayush-1789/HazardNet

- `GET /api/alerts` - Retrieve user alerts### Clone the Repository### Clone the Repository

---

- `PUT /api/alerts/:id/read` - Mark alert as read

**HazardNet: Making Roads Safer Through Technology**
```bash```bash

### Trips

- `POST /api/trips/start` - Start trip trackinggit clone https://github.com/Ayush-1789/HazardNet.gitgit clone https://github.com/Ayush-1789/HazardNet.git

- `POST /api/trips/end` - End trip and save data

- `GET /api/trips/history` - View trip historycd HazardNetcd HazardNet



---``````



## Deployment Guide



### AWS Elastic Beanstalk Setup### Setup Flutter App### Setup Flutter App

The backend automatically deploys via GitHub Actions on push to main branch.

```bash```bash

Requirements:

- AWS account with Elastic Beanstalk and RDS access# Get dependencies# Get dependencies

- GitHub repository secrets configured

flutter pub getflutter pub get

Environment Variables:

```

DATABASE_URL=postgresql://username:password@rds-endpoint:5432/database

JWT_SECRET=your-secure-secret-key# Configure environment# Configure environment

NODE_ENV=production

```cp .env.example .envcp .env.example .env



### Database Configuration# Edit .env with your API keys# Edit .env with your API keys

Database schema includes:

- users (authentication and profiles)

- hazards (reported road hazards)

- alerts (user notifications)# Run on connected device# Run on connected device

- trips (driving sessions)

- sensor_data (vehicle metrics)flutter runflutter run

- hazard_verifications (community verification)

``````

### CI/CD Pipeline

- Trigger: Push to main branch

- Build: Compile Node.js application

- Test: Run linters and checks### Setup Backend (Development)### Setup Backend (Development)

- Deploy: Automatic Elastic Beanstalk deployment

- Database: Automated migrations on RDS```bash```bash



---cd backendcd backend



## Project Structure



```# Install dependencies# Install dependencies

HazardNet/

├── lib/                    # Flutter app source codenpm installnpm install

│   ├── main.dart          # App entry point

│   ├── bloc/              # State management logic

│   ├── screens/           # UI screens

│   ├── widgets/           # Reusable widgets# Setup environment# Setup environment

│   ├── data/              # API services and models

│   ├── models/            # Data modelscp .env.example .envcp .env.example .env

│   └── core/              # Constants and utilities

├── backend/               # Node.js backend# Edit .env with database and JWT settings# Edit .env with database and JWT settings

│   ├── server.js          # Express app

│   ├── routes/            # API routes

│   ├── middleware/        # Authentication, CORS, etc

│   ├── services/          # Business logic# Run migrations# Run migrations

│   └── database/          # Schema and migrations

├── android/               # Android-specific codenpm run migratenpm run migrate

├── assets/                # Images and animations

├── detection_models/      # TensorFlow Lite models

├── pubspec.yaml           # Flutter dependencies

├── README.md              # This file# Start server# Start server

└── package.json           # Backend dependencies

```npm startnpm start



---``````



## Development Guidelines



### Code Standards### Build APK### Build APK

- Follow Flutter best practices and style guide

- Use BLoC pattern for state management```bash```bash

- Write comprehensive documentation

- Implement error handling and logging# Build release APK# Build release APK

- Test new features before submission

flutter build apk --releaseflutter build apk --release

### Git Workflow

1. Fork the repository

2. Create feature branch: `git checkout -b feature/feature-name`

3. Commit changes: `git commit -m "Add feature description"`# APK location: build/app/outputs/flutter-apk/app-release.apk# APK location: build/app/outputs/flutter-apk/app-release.apk

4. Push to branch: `git push origin feature/feature-name`

5. Open Pull Request with detailed description``````



### Testing

- Write unit tests for business logic

- Test API endpoints with different scenarios------

- Verify ML model performance

- Test on multiple Android versions



---## 📱 Usage## 📱 Usage



## Troubleshooting



### App Won't Connect to API### First Time Setup### First Time Setup

- Verify API URL in app_constants.dart

- Check network connectivity on device1. **Install APK** on Android device1. **Install APK** on Android device

- Ensure backend is running and accessible

- Verify Android network security config2. **Grant Permissions**: Location, Camera, Storage2. **Grant Permissions**: Location, Camera, Storage



### Hazard Detection Not Working3. **Create Account**: Sign up with email and password3. **Create Account**: Sign up with email and password

- Grant camera and location permissions

- Ensure device has sufficient storage4. **Enable Features**: Voice assistant, notifications4. **Enable Features**: Voice assistant, notifications

- Check TensorFlow Lite model is loaded

- Verify GPU acceleration is enabled



### Voice Alerts Not Triggering### Driving Mode### Driving Mode

- Verify ElevenLabs API key is configured

- Check distance threshold settings1. **Start Navigation**: Open app and allow location access1. **Start Navigation**: Open app and allow location access

- Ensure audio permissions are granted

- Verify speaker volume is not muted2. **AI Detection**: Camera automatically detects hazards2. **AI Detection**: Camera automatically detects hazards



---3. **Voice Alerts**: Get audio warnings for approaching dangers3. **Voice Alerts**: Get audio warnings for approaching dangers



## Contributing4. **Report Hazards**: Tap to report new hazards with photos4. **Report Hazards**: Tap to report new hazards with photos



We welcome contributions! To contribute:5. **View Map**: See community-reported hazards in real-time5. **View Map**: See community-reported hazards in real-time



1. Fork the repository

2. Create your feature branch

3. Make your changes with clear commit messages### Hazard Reporting### Hazard Reporting

4. Ensure code follows project standards

5. Submit a pull request1. **Detect Hazard**: App automatically detects via camera1. **Detect Hazard**: App automatically detects via camera



Please ensure your code:2. **Manual Report**: Tap screen to report additional hazards2. **Manual Report**: Tap screen to report additional hazards

- Passes linting checks

- Includes appropriate documentation3. **Add Details**: Include photos, severity, description3. **Add Details**: Include photos, severity, description

- Is tested and verified

- Follows existing code patterns4. **Verification**: Community voting system for accuracy4. **Verification**: Community voting system for accuracy



---



## Performance Optimization------



The app is optimized for:

- Low-end Android devices with minimal resources

- Battery efficiency with smart background processing## 🔧 API Documentation## 🔧 API Documentation

- Network bandwidth reduction through compression

- Fast model inference with INT8 quantization

- Smooth 60 FPS UI interactions

### Authentication Endpoints### Authentication Endpoints

---

- `POST /api/auth/register` - User registration- `POST /api/auth/register` - User registration

## Security

- `POST /api/auth/login` - User login- `POST /api/auth/login` - User login

Security features implemented:

- JWT token-based authentication- `GET /api/auth/status` - Check authentication status- `GET /api/auth/status` - Check authentication status

- Encrypted password storage with bcrypt

- HTTPS/HTTP support with proper SSL configuration- `GET /api/auth/profile` - Get user profile- `GET /api/auth/profile` - Get user profile

- Input validation on all endpoints

- Rate limiting on API requests

- Secure local storage with encrypted preferences

### Hazard Endpoints### Hazard Endpoints

---

- `GET /api/hazards` - List all hazards- `GET /api/hazards` - List all hazards

## License

- `GET /api/hazards/nearby` - Get hazards near location- `GET /api/hazards/nearby` - Get hazards near location

This project is licensed under the MIT License. See LICENSE file for details.

- `POST /api/hazards/report` - Report new hazard- `POST /api/hazards/report` - Report new hazard

---

- `PUT /api/hazards/:id/verify` - Verify hazard- `PUT /api/hazards/:id/verify` - Verify hazard

## Support & Feedback



For issues, questions, or feature requests:

- Open an issue on GitHub### Alert Endpoints### Alert Endpoints

- Check existing documentation

- Review troubleshooting section- `GET /api/alerts` - Get user alerts- `GET /api/alerts` - Get user alerts

- Contact development team

- `PUT /api/alerts/:id/read` - Mark alert as read- `PUT /api/alerts/:id/read` - Mark alert as read

---



## Team & Credits

### Trip Endpoints### Trip Endpoints

Built with dedication by the HazardNet team.

- `POST /api/trips/start` - Start trip tracking- `POST /api/trips/start` - Start trip tracking

Special thanks to:

- i.Mobilothon for competition support- `POST /api/trips/end` - End trip tracking- `POST /api/trips/end` - End trip tracking

- TensorFlow team for ML framework

- Google Maps for mapping services- `GET /api/trips/history` - Get trip history- `GET /api/trips/history` - Get trip history

- ElevenLabs for voice synthesis

- Flutter community for excellent framework

- AWS for cloud infrastructure

------

---



**Making roads safer, one detection at a time.**

## 🚀 Deployment## 🚀 Deployment

Last Updated: November 13, 2025


### Backend Deployment (AWS)### Backend Deployment (AWS)

The backend is automatically deployed to AWS Elastic Beanstalk via GitHub Actions.The backend is automatically deployed to AWS Elastic Beanstalk via GitHub Actions.



**Requirements:****Requirements:**

- AWS Account with EB and RDS access- AWS Account with EB and RDS access

- GitHub repository secrets configured- GitHub repository secrets configured



**Environment Variables:****Environment Variables:**

```env```env

DATABASE_URL=postgresql://user:password@host:5432/dbDATABASE_URL=postgresql://user:password@host:5432/db

JWT_SECRET=your-secret-keyJWT_SECRET=your-secret-key

NODE_ENV=productionNODE_ENV=production

``````



### Database Setup### Database Setup

```sql```sql

-- Run migrations on RDS-- Run migrations on RDS

-- Schema includes: users, hazards, alerts, trips, etc.-- Schema includes: users, hazards, alerts, trips, etc.

``````



### CI/CD Pipeline### CI/CD Pipeline

- **Trigger**: Push to `main` branch- **Trigger**: Push to `main` branch

- **Build**: Node.js application- **Build**: Node.js application

- **Deploy**: AWS Elastic Beanstalk- **Deploy**: AWS Elastic Beanstalk

- **Database**: AWS RDS PostgreSQL- **Database**: AWS RDS PostgreSQL



------



## 🤝 Contributing## 🤝 Contributing



1. **Fork** the repository1. **Fork** the repository

2. **Create** feature branch (`git checkout -b feature/amazing-feature`)2. **Create** feature branch (`git checkout -b feature/amazing-feature`)

3. **Commit** changes (`git commit -m 'Add amazing feature'`)3. **Commit** changes (`git commit -m 'Add amazing feature'`)

4. **Push** to branch (`git push origin feature/amazing-feature`)4. **Push** to branch (`git push origin feature/amazing-feature`)

5. **Open** Pull Request5. **Open** Pull Request



### Development Guidelines### Development Guidelines

- Follow Flutter best practices- Follow Flutter best practices

- Use BLoC pattern for state management- Use BLoC pattern for state management

- Write tests for new features- Write tests for new features

- Update documentation- Update documentation

- Ensure code quality with lints- Ensure code quality with lints



------



## 📄 License## 📄 License



This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



------



## 🙏 Acknowledgments## 🙏 Acknowledgments



- **i.Mobilothon Competition** for the inspiration- **i.Mobilothon Competition** for the inspiration

- **TensorFlow Lite** team for ML framework- **TensorFlow Lite** team for ML framework

- **Google Maps Platform** for mapping services- **Google Maps Platform** for mapping services

- **ElevenLabs** for voice synthesis- **ElevenLabs** for voice synthesis

- **Flutter Community** for amazing framework- **Flutter Community** for amazing framework



------



## 📞 Support## 📞 Support



For questions or issues:For questions or issues:

- Create an issue on GitHub- Create an issue on GitHub

- Email: [your-email@example.com]- Email: [your-email@example.com]

- Documentation: [Link to docs]- Documentation: [Link to docs]



------



**Made with ❤️ for safer roads****Made with ❤️ for safer roads**



### 🗺️ Google Maps IntegrationA comprehensive solution combining **Machine Learning**, **Google Maps**, **Voice Alerts**, and **Community Reporting** to make roads safer for everyone.

- **Native Google Maps**: Full integration with Google Maps Platform

- **Interactive Hazard Map**: Visual markers for all detected and reported hazards---

- **Real-time Location**: Live GPS tracking with location-based alerts

- **Community Markers**: Color-coded pins showing hazards from all users---

  - 🔵 Blue: Your reported hazards

  - 🟠 Orange: Community-reported hazards## ≡ƒÜÇ Features

  - ✅ Green checkmark: Verified hazards

- **Multiple Map Types**: Normal, Satellite, Hybrid, Terrain views## Γ£¿ Key Features

- **Custom Styling**: Dark mode support with custom map themes

- **Gesture Controls**: Zoom, rotate, tilt for 3D views### Core Features (MVP)



### 🔊 Voice Assistant (ElevenLabs TTS)### ≡ƒñû AI-Powered Hazard Detection- Γ£à **Real-time Hazard Detection** - Camera feed with frame processing ready for ML model integration

- **AI-Powered Voice Alerts**: Natural-sounding text-to-speech warnings

- **Real-time Notifications**: Voice alerts for approaching hazards- **TensorFlow Lite Model**: `unified_hazards_int8.tflite` (3.2 MB INT8 quantized)- Γ£à **Location Tracking** - GPS-based location tracking with geolocator

- **Customizable Settings**: 

  - Adjust voice characteristics- **Real-time Detection**: Detects potholes, obstacles, and speed breakers at 256├ù256 resolution- Γ£à **Interactive Map with OSM** - OpenStreetMap integration showing hazards with color-coded pins

  - Control speaking speed

  - Set warning distance thresholds- **Background Processing**: Continuous monitoring with gyroscope-based motion detection  - ≡ƒö╡ Blue pins: Your own reported hazards

- **Smart Templates**: Pre-configured messages for different hazard types

- **GPU Acceleration**: Optimized with ProGuard rules for maximum performance  - ≡ƒƒá Orange pins: Hazards reported by other users

### 👥 Community Features

- **User Authentication**: Secure JWT-based signup/login- **High Accuracy**: Latest model with improved detection capabilities  - Γ£à Verified hazards marked with green checkmark

- **Hazard Reporting**: Submit hazards with photos, location, and details

- **Social Verification**: Community voting and hazard validation  - ≡ƒôì Real-time user location tracking

- **Leaderboard**: Earn points for contributions and climb the rankings

- **Gamification**: Achievement system to encourage participation### ≡ƒù║∩╕Å Google Maps Integration  - ≡ƒù║∩╕Å Dark mode support for maps



### 🔔 Alert System- **Interactive Hazard Map**: Visual markers for all detected and reported hazards- Γ£à **Alert System** - Real-time notifications for nearby hazards

- **Push Notifications**: Real-time alerts for nearby hazards

- **Custom Alert Radius**: Set your preferred detection distance- **Real-time Location**: Live GPS tracking with location-based alerts- Γ£à **User Authentication** - Mock auth ready for backend API integration

- **Priority Levels**: Different alert types based on severity

- **Smart Filtering**: Only relevant alerts based on your route- **Community Markers**: Color-coded pins showing hazards from all users- Γ£à **Dashboard** - Quick access to all features with stats



### 🆘 Emergency Features  - ≡ƒö╡ Blue: Your reported hazards- Γ£à **Vehicle Health Tracking** - Cumulative damage scoring system

- **One-Tap SOS**: Quick emergency contact notification

- **Location Sharing**: Automatically share your location in emergencies  - ≡ƒƒá Orange: Community-reported hazards- Γ£à **Beautiful UI** - Material 3 design with smooth animations and dark mode

- **Emergency Services**: Direct links to emergency numbers

  - Γ£à Green checkmark: Verified hazards

### 📊 Analytics & Tracking

- **Vehicle Health Score**: Track cumulative damage from hazards- **Custom Styling**: Dark mode support with custom map themes### Hazard Types Detected

- **Trip Statistics**: Monitor your driving patterns

- **Hazard History**: View all detected and reported hazards- ≡ƒò│∩╕Å Potholes

- **Personal Dashboard**: Quick overview of your stats

### ≡ƒöè Voice Assistant (ElevenLabs TTS)- ≡ƒÜº Unmarked Speed Breakers

---

- **AI-Powered Voice Alerts**: Natural-sounding text-to-speech warnings- ≡ƒÜ½ Obstacles on Road

## 🏗️ Architecture

- **Real-time Notifications**: Voice alerts for approaching hazards- ≡ƒ¢æ Closed/Blocked Roads

### Tech Stack

- **Frontend**: Flutter 3.24.5 (Stable)- **Customizable Settings**: - ≡ƒÜª Lane Blockages

- **ML Framework**: TensorFlow Lite (GPU accelerated)

- **Maps**: Google Maps Flutter Platform  - Adjust voice characteristics

- **Voice**: ElevenLabs Text-to-Speech API

- **State Management**: BLoC Pattern  - Control speaking speed## ≡ƒÅù∩╕Å Architecture

- **Backend**: Railway (Primary) + Render (Fallback)

- **Database**: PostgreSQL (Neon)  - Set warning distance thresholds

- **Authentication**: JWT tokens

- **Smart Templates**: Pre-configured messages for different hazard types```

### Project Structure

```lib/

HazardNet/

├── lib/### ≡ƒæÑ Community FeaturesΓö£ΓöÇΓöÇ core/

│   ├── core/

│   │   ├── config/- **User Authentication**: Secure JWT-based signup/loginΓöé   Γö£ΓöÇΓöÇ constants/      # App constants, API endpoints

│   │   │   └── api_config.dart          # Backend endpoints & failover

│   │   ├── constants/- **Hazard Reporting**: Submit hazards with photos, location, and detailsΓöé   Γö£ΓöÇΓöÇ theme/          # App theme, colors, typography

│   │   │   ├── app_constants.dart       # API keys & settings

│   │   │   ├── model_config.dart        # TFLite model configuration- **Social Verification**: Community voting and hazard validationΓöé   ΓööΓöÇΓöÇ utils/          # Helper utilities

│   │   │   └── voice_warning_templates.dart

│   │   ├── theme/                       # Material 3 theme- **Leaderboard**: Earn points for contributions and climb the rankingsΓö£ΓöÇΓöÇ data/

│   │   └── utils/                       # Helper utilities

│   ├── data/- **Gamification**: Achievement system to encourage participationΓöé   Γö£ΓöÇΓöÇ repositories/   # Data layer abstraction

│   │   ├── repositories/                # Data layer abstraction

│   │   └── services/Γöé   ΓööΓöÇΓöÇ services/       # API services, local storage

│   │       ├── tflite_service.dart      # TensorFlow Lite inference

│   │       ├── elevenlabs_tts_service.dart### ≡ƒöö Alert SystemΓö£ΓöÇΓöÇ models/             # Data models (User, Hazard, Alert, etc.)

│   │       └── api_service.dart

│   ├── models/                          # Data models- **Push Notifications**: Real-time alerts for nearby hazardsΓö£ΓöÇΓöÇ bloc/               # BLoC state management

│   │   ├── user.dart

│   │   ├── hazard.dart- **Custom Alert Radius**: Set your preferred detection distanceΓöé   Γö£ΓöÇΓöÇ auth/

│   │   ├── alert.dart

│   │   └── detection_result.dart- **Priority Levels**: Different alert types based on severityΓöé   Γö£ΓöÇΓöÇ camera/

│   ├── bloc/                            # BLoC state management

│   │   ├── auth/- **Smart Filtering**: Only relevant alerts based on your routeΓöé   Γö£ΓöÇΓöÇ hazard/

│   │   ├── camera/                      # Camera & detection logic

│   │   ├── hazard/Γöé   Γö£ΓöÇΓöÇ location/

│   │   ├── location/

│   │   ├── alerts/### ≡ƒåÿ Emergency FeaturesΓöé   ΓööΓöÇΓöÇ alerts/

│   │   └── voice_assistant/             # Voice alert management

│   ├── screens/                         # UI screens- **One-Tap SOS**: Quick emergency contact notificationΓö£ΓöÇΓöÇ screens/            # UI screens

│   │   ├── welcome/

│   │   ├── dashboard/- **Location Sharing**: Automatically share your location in emergenciesΓöé   Γö£ΓöÇΓöÇ welcome/

│   │   ├── camera/                      # Real-time detection screen

│   │   ├── map/                         # Google Maps view- **Emergency Services**: Direct links to emergency numbersΓöé   Γö£ΓöÇΓöÇ dashboard/

│   │   ├── alerts/

│   │   └── profile/Γöé   Γö£ΓöÇΓöÇ camera/

│   └── widgets/                         # Reusable components

├── detection_models/### ≡ƒôè Analytics & TrackingΓöé   Γö£ΓöÇΓöÇ map/

│   └── unified_hazards_int8.tflite     # ML model (3.2 MB)

├── android/- **Vehicle Health Score**: Track cumulative damage from hazardsΓöé   Γö£ΓöÇΓöÇ alerts/

│   └── app/

│       ├── proguard-rules.pro           # ProGuard config for TFLite- **Trip Statistics**: Monitor your driving patternsΓöé   ΓööΓöÇΓöÇ profile/

│       └── src/main/AndroidManifest.xml # Google Maps API key

└── .github/- **Hazard History**: View all detected and reported hazardsΓööΓöÇΓöÇ widgets/            # Reusable widgets

    └── workflows/

        └── build-apk.yml                # GitHub Actions CI/CD- **Personal Dashboard**: Quick overview of your stats```

```



---

---## ≡ƒÜª Getting Started

## 🚀 Getting Started



### Prerequisites

## ≡ƒÅù∩╕Å Architecture### Installation

- **Flutter SDK**: 3.24.5 or higher

- **Android Studio** / **VS Code** with Flutter plugin

- **Java**: Version 17 (for Android builds)

- **Google Maps API Key** (from Google Cloud Console)### Tech Stack1. **Install dependencies**

- **ElevenLabs API Key** (optional, for voice features)

- **Frontend**: Flutter 3.24.5 (Stable)   ```bash

### Installation

- **ML Framework**: TensorFlow Lite (GPU accelerated)   flutter pub get

1. **Clone the repository**

   ```bash- **Maps**: Google Maps Platform   ```

   git clone https://github.com/Ayush-1789/HazardNet.git

   cd HazardNet- **Voice**: ElevenLabs Text-to-Speech API

   ```

- **State Management**: BLoC Pattern2. **Run the app**

2. **Install Flutter dependencies**

   ```bash- **Backend**: Railway (Primary) + Render (Fallback)   ```bash

   flutter pub get

   ```- **Database**: PostgreSQL   flutter run



3. **Configure API Keys**- **Authentication**: JWT tokens   ```



   Create a `.env` file in the root directory:

   ```properties

   GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here### Project Structure## ≡ƒôí API Integration Guide

   API_BASE_URL=https://hazardnet-production.up.railway.app/api

   ELEVENLABS_API_KEY=your_elevenlabs_api_key_here```

   ```

HazardNet/### Hazard Detection API

   Or manually update:

   - Google Maps: `android/app/src/main/AndroidManifest.xml`Γö£ΓöÇΓöÇ lib/

   - App Constants: `lib/core/constants/app_constants.dart`

Γöé   Γö£ΓöÇΓöÇ core/The camera feed sends frames to the ML model API. Update `lib/bloc/camera/camera_bloc.dart` in the `_onProcessFrame` method to call your YOLOv8 API.

4. **Run the app**

   ```bashΓöé   Γöé   Γö£ΓöÇΓöÇ config/

   # On connected device

   flutter run --releaseΓöé   Γöé   Γöé   ΓööΓöÇΓöÇ api_config.dart          # Backend endpoints & failover**Expected Request:**

   

   # Or build APKΓöé   Γöé   Γö£ΓöÇΓöÇ constants/```json

   flutter build apk --release

   ```Γöé   Γöé   Γöé   Γö£ΓöÇΓöÇ app_constants.dart       # API keys & settings{



   The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`Γöé   Γöé   Γöé   Γö£ΓöÇΓöÇ model_config.dart        # TFLite model configuration  "image": "base64_encoded_image",



---Γöé   Γöé   Γöé   ΓööΓöÇΓöÇ voice_warning_templates.dart  "timestamp": "2025-11-06T10:30:00Z",



## 🔧 Configuration GuideΓöé   Γöé   Γö£ΓöÇΓöÇ theme/                       # Material 3 theme  "location": {



### Google Maps SetupΓöé   Γöé   ΓööΓöÇΓöÇ utils/                       # Helper utilities    "latitude": 28.6139,



1. **Get API Key**:Γöé   Γö£ΓöÇΓöÇ data/    "longitude": 77.2090

   - Go to [Google Cloud Console](https://console.cloud.google.com/)

   - Create project → Enable Maps SDK for AndroidΓöé   Γöé   Γö£ΓöÇΓöÇ repositories/                # Data layer abstraction  }

   - Create credentials → API Key

   - Restrict key to Android apps (package: `com.hazardnet.app`)Γöé   Γöé   ΓööΓöÇΓöÇ services/}



2. **Add to Android**:Γöé   Γöé       Γö£ΓöÇΓöÇ tflite_service.dart      # TensorFlow Lite inference```

   Open `android/app/src/main/AndroidManifest.xml`:

   ```xmlΓöé   Γöé       Γö£ΓöÇΓöÇ elevenlabs_tts_service.dart

   <meta-data

       android:name="com.google.android.geo.API_KEY"Γöé   Γöé       ΓööΓöÇΓöÇ api_service.dart**Expected Response:**

       android:value="YOUR_API_KEY_HERE" />

   ```Γöé   Γö£ΓöÇΓöÇ models/                          # Data models```json



3. **Add to Flutter**:Γöé   Γöé   Γö£ΓöÇΓöÇ user.dart{

   Open `lib/core/constants/app_constants.dart`:

   ```dartΓöé   Γöé   Γö£ΓöÇΓöÇ hazard.dart  "detections": [

   static const String googleMapsApiKey = 'YOUR_API_KEY_HERE';

   ```Γöé   Γöé   Γö£ΓöÇΓöÇ alert.dart    {



### Backend ConfigurationΓöé   Γöé   ΓööΓöÇΓöÇ detection_result.dart      "type": "pothole",



The app uses **Railway** as the primary backend with automatic failover to **Render**:Γöé   Γö£ΓöÇΓöÇ bloc/                            # BLoC state management      "confidence": 0.92,



**Backend Endpoints**:Γöé   Γöé   Γö£ΓöÇΓöÇ auth/      "severity": "high"

- **Primary**: `https://hazardnet-production.up.railway.app/api`

- **Fallback**: `https://hazardnet-9yd2.onrender.com/api`Γöé   Γöé   Γö£ΓöÇΓöÇ camera/                      # Camera & detection logic    }



To change backends, update `lib/core/config/api_config.dart`:Γöé   Γöé   Γö£ΓöÇΓöÇ hazard/  ]

```dart

static String _currentBackendUrl = railwayBackendUrl;Γöé   Γöé   Γö£ΓöÇΓöÇ location/}

static BackendType _currentBackendType = BackendType.railway;

```Γöé   Γöé   Γö£ΓöÇΓöÇ alerts/```



### Voice Assistant (Optional)Γöé   Γöé   ΓööΓöÇΓöÇ voice_assistant/             # Voice alert management



1. Get API key from [ElevenLabs](https://elevenlabs.io/)Γöé   Γö£ΓöÇΓöÇ screens/                         # UI screens## ≡ƒöº Next Steps

2. Add to `.env` file: `ELEVENLABS_API_KEY=your_key`

3. Update `lib/core/constants/app_constants.dart`Γöé   Γöé   Γö£ΓöÇΓöÇ welcome/



---Γöé   Γöé   Γö£ΓöÇΓöÇ dashboard/1. **Setup Backend API**



## 🧪 TestingΓöé   Γöé   Γö£ΓöÇΓöÇ camera/                      # Real-time detection screen   - Copy `.env.example` to `.env` and configure your backend API URL



### On Physical Device (Recommended)Γöé   Γöé   Γö£ΓöÇΓöÇ map/                         # Google Maps view   - Update `lib/core/constants/app_constants.dart` with your API endpoints



1. Enable **Developer Options** on your Android phoneΓöé   Γöé   Γö£ΓöÇΓöÇ alerts/   - Implement authentication endpoints (JWT-based recommended)

2. Enable **USB Debugging**

3. Connect via USBΓöé   Γöé   ΓööΓöÇΓöÇ profile/

4. Run: `flutter run --release`

Γöé   ΓööΓöÇΓöÇ widgets/                         # Reusable components2. **Connect ML Model**

### Testing Features

Γö£ΓöÇΓöÇ detection_models/   - Update API endpoint in `lib/core/constants/app_constants.dart`

- **Camera Detection**: Point camera at road while moving

- **Voice Alerts**: Enable in settings, test with detected hazardsΓöé   ΓööΓöÇΓöÇ unified_hazards_int8.tflite     # ML model (3.2 MB)   - Implement API call in `lib/bloc/camera/camera_bloc.dart`

- **Maps**: Check hazard markers and real-time location

- **Reporting**: Long-press on map to report new hazardΓö£ΓöÇΓöÇ android/

- **Alerts**: Check notifications for nearby hazards

Γöé   ΓööΓöÇΓöÇ app/3. **Setup Google Maps**

---

Γöé       Γö£ΓöÇΓöÇ proguard-rules.pro           # ProGuard config for TFLite   - Get API key from Google Cloud Console

## 📦 Building Release APK

Γöé       ΓööΓöÇΓöÇ src/main/AndroidManifest.xml # Google Maps API key   - Add to Android manifest and iOS AppDelegate

### Local Build

ΓööΓöÇΓöÇ .github/

```bash

# Clean previous builds    ΓööΓöÇΓöÇ workflows/4. **Setup PostgreSQL Backend**

flutter clean

        ΓööΓöÇΓöÇ build-apk.yml                # GitHub Actions CI/CD   - Create database schema for users, hazards, alerts

# Get dependencies

flutter pub get```   - Implement REST API endpoints for CRUD operations



# Build release APK   - Setup JWT authentication

flutter build apk --release

---

# APK location: build/app/outputs/flutter-apk/app-release.apk (≈77 MB)

```## ≡ƒôª Built With



### GitHub Actions (Automated)## ≡ƒÜÇ Getting Started



Push to `main` branch to automatically trigger APK build via GitHub Actions.- Flutter 3.35.7



Download artifacts from: **Actions** → Select workflow run → **Artifacts** → **HazardNet-release**### Prerequisites- BLoC for state management



---- Material 3 Design



## 🌐 API Documentation- **Flutter SDK**: 3.24.5 or higher- Camera, GPS, Sensors integration



### Authentication- **Android Studio** / **VS Code** with Flutter plugin- Backend-ready (Postgres/REST API)



**Signup**:- **Java**: Version 17 (for Android builds)- Animations with flutter_animate

```http

POST /api/auth/signup- **Google Maps API Key** (from Google Cloud Console)

Content-Type: application/json

- **ElevenLabs API Key** (optional, for voice features)---

{

  "username": "john_doe",

  "email": "john@example.com",

  "password": "secure_password123"### Installation**Built with Γ¥ñ∩╕Å for safer Indian roads**

}

```# HazardNet - Updated 2025-11-09 14:05:03



**Login**:1. **Clone the repository**

```http

POST /api/auth/login   ```bash

Content-Type: application/json   git clone https://github.com/yourusername/HazardNet_2.0.11.git

   cd HazardNet_2.0.11

{   ```

  "email": "john@example.com",

  "password": "secure_password123"2. **Install Flutter dependencies**

}   ```bash

   flutter pub get

Response: { "token": "jwt_token_here", "user": {...} }   ```

```

3. **Configure API Keys**

### Hazard Detection

   Create a `.env` file in the root directory:

The TFLite model runs **locally on-device**. Detection results are sent to backend:   ```properties

   GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here

```http   API_BASE_URL=https://hazardnet-production.up.railway.app/api

POST /api/hazards   ELEVENLABS_API_KEY=your_elevenlabs_api_key_here

Authorization: Bearer {token}   ```

Content-Type: application/json

   Or manually update:

{   - Google Maps: `android/app/src/main/AndroidManifest.xml`

  "type": "pothole",   - App Constants: `lib/core/constants/app_constants.dart`

  "location": {

    "latitude": 28.6139,4. **Run the app**

    "longitude": 77.2090   ```bash

  },   # On connected device

  "severity": "high",   flutter run --release

  "confidence": 0.92,   

  "image": "base64_encoded_image",   # Or build APK

  "timestamp": "2025-11-09T10:30:00Z"   flutter build apk --release

}   ```

```

   The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

### Alerts

---

**Get Nearby Alerts**:

```http## ≡ƒöº Configuration Guide

GET /api/alerts?lat=28.6139&lng=77.2090&radius=5000

Authorization: Bearer {token}### Google Maps Setup

```

1. **Get API Key**:

---   - Go to [Google Cloud Console](https://console.cloud.google.com/)

   - Create project ΓåÆ Enable Maps SDK for Android

## 🔐 Security   - Create credentials ΓåÆ API Key

   - Restrict key to Android apps (package: `com.hazardnet.app`)

- **JWT Authentication**: Secure token-based auth (128-char secret)

- **ProGuard/R8**: Code obfuscation enabled for release builds2. **Add to Android**:

- **API Key Protection**: Keys stored in environment variables   Open `android/app/src/main/AndroidManifest.xml`:

- **HTTPS Only**: All API communication encrypted   ```xml

- **Input Validation**: Server-side validation for all requests   <meta-data

       android:name="com.google.android.geo.API_KEY"

---       android:value="YOUR_API_KEY_HERE" />

   ```

## 🗺️ Roadmap

3. **Add to Flutter**:

### v1.1.0 (Next Release)   Open `lib/core/constants/app_constants.dart`:

- [ ] iOS support   ```dart

- [ ] Offline mode with local caching   static const String googleMapsApiKey = 'YOUR_API_KEY_HERE';

- [ ] Advanced ML model with more hazard types   ```

- [ ] Social features (friends, groups)

- [ ] Route planning with hazard avoidance### Backend Configuration



### v1.2.0 (Future)The app uses **Railway** as the primary backend with automatic failover to **Render**:

- [ ] Web dashboard

- [ ] Integration with municipal reporting systems**Backend Endpoints**:

- [ ] Crowd-sourced hazard validation- **Primary**: `https://hazardnet-production.up.railway.app/api`

- [ ] Multi-language support- **Fallback**: `https://hazardnet-9yd2.onrender.com/api`



---To change backends, update `lib/core/config/api_config.dart`:

```dart

## 🤝 Contributingstatic String _currentBackendUrl = railwayBackendUrl;

static BackendType _currentBackendType = BackendType.railway;

This project was built for the **i.Mobilothon** competition. If you'd like to contribute:```



1. Fork the repository### Voice Assistant (Optional)

2. Create a feature branch: `git checkout -b feature/amazing-feature`

3. Commit changes: `git commit -m 'Add amazing feature'`1. Get API key from [ElevenLabs](https://elevenlabs.io/)

4. Push to branch: `git push origin feature/amazing-feature`2. Add to `.env` file: `ELEVENLABS_API_KEY=your_key`

5. Open a Pull Request3. Update `lib/core/constants/app_constants.dart`



------



## 📜 License## ≡ƒº¬ Testing



This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.### On Physical Device (Recommended)



---1. Enable **Developer Options** on your Android phone

2. Enable **USB Debugging**

## 👥 Team3. Connect via USB

4. Run: `flutter run --release`

**HazardNet Team**

- Lead Developer: [Your Name]### Testing Features

- ML Engineer: [Gautam Gupta]

- Backend Developer: [Team Member]- **Camera Detection**: Point camera at road while moving

- **Voice Alerts**: Enable in settings, test with detected hazards

---- **Maps**: Check hazard markers and real-time location

- **Reporting**: Long-press on map to report new hazard

## 🙏 Acknowledgments- **Alerts**: Check notifications for nearby hazards



- **TensorFlow Lite** for efficient on-device ML inference---

- **Google Maps Platform** for mapping capabilities

- **ElevenLabs** for natural voice synthesis## ≡ƒôª Building Release APK

- **Railway** & **Render** for reliable backend hosting

- **Flutter Community** for amazing packages and support### Local Build



---```bash

# Clean previous builds

## 📞 Supportflutter clean



For questions or support:# Get dependencies

- **Email**: support@hazardnet.appflutter pub get

- **GitHub Issues**: [Create an issue](https://github.com/Ayush-1789/HazardNet/issues)

# Build release APK

---flutter build apk --release



**Built with ❤️ for safer roads in India and around the world**# APK location: build/app/outputs/flutter-apk/app-release.apk (Γëê77 MB)

```

🚗💨 Drive Safe with HazardNet!

### GitHub Actions (Automated)

---

Push to `main` branch to automatically trigger APK build via GitHub Actions.

**Version**: 1.0.0-release  

**Last Updated**: November 9, 2025  Download artifacts from: **Actions** ΓåÆ Select workflow run ΓåÆ **Artifacts** ΓåÆ **HazardNet-release**

**Status**: ✅ Production Ready  

**Competition**: i.Mobilothon 2025---


## ≡ƒîÉ API Documentation

### Authentication

**Signup**:
```http
POST /api/auth/signup
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "secure_password123"
}
```

**Login**:
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "secure_password123"
}

Response: { "token": "jwt_token_here", "user": {...} }
```

### Hazard Detection

The TFLite model runs **locally on-device**. Detection results are sent to backend:

```http
POST /api/hazards
Authorization: Bearer {token}
Content-Type: application/json

{
  "type": "pothole",
  "location": {
    "latitude": 28.6139,
    "longitude": 77.2090
  },
  "severity": "high",
  "confidence": 0.92,
  "image": "base64_encoded_image",
  "timestamp": "2025-11-09T10:30:00Z"
}
```

### Alerts

**Get Nearby Alerts**:
```http
GET /api/alerts?lat=28.6139&lng=77.2090&radius=5000
Authorization: Bearer {token}
```

---

## ≡ƒöÉ Security

- **JWT Authentication**: Secure token-based auth (128-char secret)
- **ProGuard/R8**: Code obfuscation enabled for release builds
- **API Key Protection**: Keys stored in environment variables
- **HTTPS Only**: All API communication encrypted
- **Input Validation**: Server-side validation for all requests

---

## ≡ƒÜº Known Issues

- GitHub Actions builds showing failures (under investigation)
- Android emulator connection issues (use physical device recommended)
- Render backend has 50-second cold start (Railway is primary)

---

## ≡ƒù║∩╕Å Roadmap

### v1.1.0 (Next Release)
- [ ] iOS support
- [ ] Offline mode with local caching
- [ ] Advanced ML model with more hazard types
- [ ] Social features (friends, groups)
- [ ] Route planning with hazard avoidance

### v1.2.0 (Future)
- [ ] Web dashboard
- [ ] Integration with municipal reporting systems
- [ ] Crowd-sourced hazard validation
- [ ] Multi-language support

---

## ≡ƒñ¥ Contributing

This project was built for the **i.Mobilothon** competition. If you'd like to contribute:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## ≡ƒô£ License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ≡ƒæÑ Team

**HazardNet Team**
- Lead Developer: [Your Name]
- ML Engineer: [Gautam Gupta]
- Backend Developer: [Team Member]

---

## ≡ƒÖÅ Acknowledgments

- **TensorFlow Lite** for efficient on-device ML inference
- **Google Maps Platform** for mapping capabilities
- **ElevenLabs** for natural voice synthesis
- **Railway** & **Render** for reliable backend hosting
- **Flutter Community** for amazing packages and support

---

## ≡ƒô₧ Support

For questions or support:
- **Email**: support@hazardnet.app
- **GitHub Issues**: [Create an issue](https://github.com/yourusername/HazardNet_2.0.11/issues)

---

**Built with Γ¥ñ∩╕Å for safer roads in India and around the world**

≡ƒÜù≡ƒÆ¿ Drive Safe with HazardNet!

---

## ≡ƒô╕ Screenshots

[Add screenshots of your app here]

---

## ≡ƒÄÑ Demo Video

[Link to demo video]

---

**Version**: 1.0.0-release  
**Last Updated**: November 9, 2025  
**Status**: Γ£à Production Ready
