# HazardNet - AI-Powered Road Hazard Detection System# 🚗 HazardNet - AI-Powered Road Hazard Detection System# 🚗 HazardNet - AI-Powered Road Hazard Detection System



Real-time road hazard detection using machine learning and computer vision to make driving safer for everyone.



**Version:** 1.0.0  ![Flutter](https://img.shields.io/badge/Flutter-3.24.5-blue)![Flutter](https://img.shields.io/badge/Flutter-3.24.5-blue)

**License:** MIT  

**Platform:** Android (Flutter)![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)



---![TensorFlow Lite](https://img.shields.io/badge/TensorFlow-Lite-orange)![TensorFlow Lite](https://img.shields.io/badge/TensorFlow-Lite-orange)



## Overview![Platform](https://img.shields.io/badge/Platform-Android-green)![Platform](https://img.shields.io/badge/Platform-Android-green)



HazardNet is an intelligent mobile application that detects road hazards in real-time using AI-powered computer vision. The app combines machine learning models, Google Maps integration, voice alerts, and community reporting to help drivers navigate safely and avoid accidents.![License](https://img.shields.io/badge/License-MIT-green)![License](https://img.shields.io/badge/License-MIT-green)



Built for the i.Mobilothon Competition, HazardNet represents a complete solution for road safety with both mobile and backend infrastructure.![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen)![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen)



---



## Core Features**HazardNet** is an intelligent road safety application that uses **AI-powered computer vision** with **TensorFlow Lite** to detect road hazards in real-time, helping drivers avoid accidents and navigate safely.**HazardNet** is an intelligent road safety application that uses **AI-powered computer vision** with **TensorFlow Lite** to detect road hazards in real-time, helping drivers avoid accidents and navigate safely.



### Real-Time Hazard Detection

- AI-powered detection using TensorFlow Lite model (3.2 MB INT8 quantized)

- Identifies potholes, obstacles, speed breakers, and road hazardsBuilt for the **i.Mobilothon Competition**, this comprehensive solution combines **Machine Learning**, **Google Maps**, **Voice Alerts**, and **Community Reporting** to make roads safer for everyone.Built for the **i.Mobilothon Competition**, this comprehensive solution combines **Machine Learning**, **Google Maps**, **Voice Alerts**, and **Community Reporting** to make roads safer for everyone.

- Processes video frames at 256x256 resolution

- Background monitoring with motion detection

- GPU-accelerated inference for optimal performance

------

### Interactive Map System

- Full Google Maps integration with real-time location tracking

- Color-coded hazard markers:

  - Blue: Your own reported hazards## ✨ Key Features## ✨ Key Features

  - Orange: Community-reported hazards

  - Green: Verified hazards by multiple users

- Multiple map types (Normal, Satellite, Hybrid, Terrain)

- Interactive gesture controls (zoom, rotate, tilt)### 🤖 AI-Powered Hazard Detection### 🤖 AI-Powered Hazard Detection

- Dark mode support

- **TensorFlow Lite Model**: `unified_hazards_int8.tflite` (3.2 MB INT8 quantized)- **TensorFlow Lite Model**: `unified_hazards_int8.tflite` (3.2 MB INT8 quantized)

### Voice Alert System

- Natural-sounding voice warnings via ElevenLabs TTS- **Real-time Detection**: Detects potholes, obstacles, and speed breakers at 256×256 resolution- **Real-time Detection**: Detects potholes, obstacles, and speed breakers at 256×256 resolution

- Customizable alert distance and speaking speed

- Pre-configured messages for different hazard types- **Background Processing**: Continuous monitoring with gyroscope-based motion detection- **Background Processing**: Continuous monitoring with gyroscope-based motion detection

- Real-time audio notifications for approaching dangers

- Intelligent cooldown to prevent alert repetition- **GPU Acceleration**: Optimized with ProGuard rules for maximum performance- **GPU Acceleration**: Optimized with ProGuard rules for maximum performance



### Community & Reporting- **High Accuracy**: Latest model with improved detection capabilities- **High Accuracy**: Latest model with improved detection capabilities

- User authentication with JWT-based security

- Submit hazard reports with photos and location data

- Community verification system with multi-signature support

- Real-time push notifications for nearby hazards### 🗺️ Google Maps Integration### 🗺️ Google Maps Integration

- User profiles with driving statistics and damage scores

- **Native Google Maps**: Full integration with Google Maps Platform- **Native Google Maps**: Full integration with Google Maps Platform

### Advanced Analytics

- Vehicle damage tracking and wear monitoring- **Interactive Hazard Map**: Visual markers for all detected and reported hazards- **Interactive Hazard Map**: Visual markers for all detected and reported hazards

- Complete trip history and driving pattern analysis

- Fleet management features for B2B applications- **Real-time Location**: Live GPS tracking with location-based alerts- **Real-time Location**: Live GPS tracking with location-based alerts

- Performance metrics and detection statistics

- **Community Markers**: Color-coded pins showing hazards from all users- **Community Markers**: Color-coded pins showing hazards from all users

---

  - 🔵 Blue: Your reported hazards  - 🔵 Blue: Your reported hazards

## Technology Stack

  - 🟠 Orange: Community-reported hazards  - 🟠 Orange: Community-reported hazards

### Frontend (Mobile)

- **Framework:** Flutter 3.24.5  - ✅ Green: Verified hazards  - ✅ Green: Verified hazards

- **Language:** Dart 3.9.2

- **State Management:** BLoC Pattern- **Multiple Map Types**: Normal, Satellite, Hybrid, Terrain views- **Multiple Map Types**: Normal, Satellite, Hybrid, Terrain views

- **Maps:** Google Maps Flutter SDK

- **Machine Learning:** TensorFlow Lite Flutter- **Custom Styling**: Dark mode support with custom map themes- **Custom Styling**: Dark mode support with custom map themes

- **HTTP Client:** Dio and HTTP packages

- **Storage:** Shared Preferences, Hive- **Gesture Controls**: Zoom, rotate, tilt for 3D views- **Gesture Controls**: Zoom, rotate, tilt for 3D views

- **UI:** Material Design 3



### Backend (Server)

- **Runtime:** Node.js 20### 🔊 Voice Assistant (ElevenLabs TTS)### 🔊 Voice Assistant (ElevenLabs TTS)

- **Framework:** Express.js

- **Database:** PostgreSQL (AWS RDS)- **AI-Powered Voice Alerts**: Natural-sounding text-to-speech warnings- **AI-Powered Voice Alerts**: Natural-sounding text-to-speech warnings

- **Authentication:** JWT (JSON Web Tokens)

- **Hosting:** AWS Elastic Beanstalk- **Real-time Notifications**: Voice alerts for approaching hazards- **Real-time Notifications**: Voice alerts for approaching hazards

- **Environment:** Production-ready with auto-scaling

- **Customizable Settings**:- **Customizable Settings**:

### AI & Machine Learning

- **Model:** TensorFlow Lite INT8 quantized  - Adjust voice characteristics  - Adjust voice characteristics

- **Training:** Custom dataset optimized for Indian road conditions

- **Inference:** On-device real-time processing  - Control speaking speed  - Control speaking speed

- **Optimization:** GPU acceleration and background processing

  - Set warning distance thresholds  - Set warning distance thresholds

### Cloud Infrastructure

- **App Hosting:** AWS Elastic Beanstalk- **Smart Templates**: Pre-configured messages for different hazard types- **Smart Templates**: Pre-configured messages for different hazard types

- **Database:** AWS RDS PostgreSQL

- **CI/CD:** GitHub Actions automated deployment

- **Maps Service:** Google Maps Platform API

- **Voice Service:** ElevenLabs TTS API### 👥 Community Features### 👥 Community Features



---- **User Authentication**: Secure JWT-based signup/login- **User Authentication**: Secure JWT-based signup/login



## Installation & Setup- **Hazard Reporting**: Submit hazards with photos, location, and details- **Hazard Reporting**: Submit hazards with photos, location, and details



### Requirements- **Community Verification**: Multi-signature verification system- **Community Verification**: Multi-signature verification system

- Flutter SDK 3.24.5 or later

- Dart 3.9.2 or later- **Real-time Alerts**: Push notifications for nearby hazards- **Real-time Alerts**: Push notifications for nearby hazards

- Android Studio with Android SDK

- Git version control- **User Profiles**: Track driving statistics and damage scores- **User Profiles**: Track driving statistics and damage scores

- Node.js 20+ (for backend development)



### Clone Repository

```bash### 📊 Advanced Analytics### 📊 Advanced Analytics

git clone https://github.com/Ayush-1789/HazardNet.git

cd HazardNet- **Vehicle Damage Tracking**: Monitor vehicle wear and tear- **Vehicle Damage Tracking**: Monitor vehicle wear and tear

```

- **Trip History**: Record and analyze driving patterns- **Trip History**: Record and analyze driving patterns

### Mobile App Setup

```bash- **Fleet Analytics**: B2B features for fleet management- **Fleet Analytics**: B2B features for fleet management

# Install Flutter dependencies

flutter pub get- **Performance Metrics**: Detection accuracy and response times- **Performance Metrics**: Detection accuracy and response times



# Create environment configuration

cp .env.example .env

------

# Edit .env file with API keys and settings

# API_BASE_URL=http://your-api-endpoint/api

# ELEVENLABS_API_KEY=your_api_key

# GOOGLE_MAPS_API_KEY=your_maps_key## 🛠️ Tech Stack## 🛠️ Tech Stack



# Run app on connected device

flutter run

### Frontend (Flutter)### Frontend (Flutter)

# Build release APK

flutter build apk --release- **Framework**: Flutter 3.24.5- **Framework**: Flutter 3.24.5

```

- **Language**: Dart 3.9.2- **Language**: Dart 3.9.2

### Backend Setup (Development)

```bash- **State Management**: BLoC Pattern- **State Management**: BLoC Pattern

cd backend

- **Maps**: Google Maps Flutter- **Maps**: Google Maps Flutter

# Install Node dependencies

npm install- **ML**: TensorFlow Lite Flutter- **ML**: TensorFlow Lite Flutter



# Create environment file- **Networking**: HTTP/Dio- **Networking**: HTTP/Dio

cp .env.example .env

- **Storage**: Shared Preferences, Hive- **Storage**: Shared Preferences, Hive

# Configure environment variables

# DATABASE_URL=postgresql://user:password@host:5432/db- **UI**: Material Design 3- **UI**: Material Design 3

# JWT_SECRET=your_secret_key

# NODE_ENV=development



# Run database migrations### Backend (Node.js)### Backend (Node.js)

npm run migrate

- **Runtime**: Node.js 20 (AWS Elastic Beanstalk)- **Runtime**: Node.js 20 (AWS Elastic Beanstalk)

# Start development server

npm start- **Framework**: Express.js- **Framework**: Express.js

```

- **Database**: PostgreSQL (AWS RDS)- **Database**: PostgreSQL (AWS RDS)

### Build Release APK

```bash- **Authentication**: JWT- **Authentication**: JWT

flutter clean

flutter pub get- **ORM**: Direct SQL queries- **ORM**: Direct SQL queries

flutter build apk --release

- **Deployment**: AWS Elastic Beanstalk- **Deployment**: AWS Elastic Beanstalk

# Output location: build/app/outputs/flutter-apk/app-release.apk

# Size: ~79-83 MB

```

### AI/ML### AI/ML

---

- **Model**: TensorFlow Lite INT8 quantized- **Model**: TensorFlow Lite INT8 quantized

## Usage Guide

- **Training**: Custom dataset for Indian road conditions- **Training**: Custom dataset for Indian road conditions

### First Launch

1. Install the APK on your Android device- **Inference**: Real-time on-device processing- **Inference**: Real-time on-device processing

2. Grant required permissions:

   - Location (GPS access)- **Optimization**: GPU acceleration, background processing- **Optimization**: GPU acceleration, background processing

   - Camera (hazard detection)

   - Storage (image storage)

   - Microphone (voice features)

3. Create account with email and password### Cloud Services### Cloud Services

4. Configure voice assistant and notification settings

- **Hosting**: AWS Elastic Beanstalk- **Hosting**: AWS Elastic Beanstalk

### Driving Mode

1. Open app and allow location access- **Database**: AWS RDS PostgreSQL- **Database**: AWS RDS PostgreSQL

2. Camera automatically detects hazards in real-time

3. Receive audio warnings for approaching hazards- **CI/CD**: GitHub Actions- **CI/CD**: GitHub Actions

4. View community hazards on interactive map

5. Report new hazards by tapping screen and adding details- **Maps**: Google Maps Platform- **Maps**: Google Maps Platform



### Report a Hazard- **Voice**: ElevenLabs TTS API- **Voice**: ElevenLabs TTS API

1. Detection: App automatically identifies hazards via camera

2. Manual Report: Tap screen to report additional hazards

3. Add Details: Include photo, severity level, description

4. Submit: Send to community for verification------

5. Verification: Community votes to confirm accuracy



---

## 🚀 Installation## 🚀 Installation

## API Endpoints



### Authentication

- `POST /api/auth/register` - Create new user account### Prerequisites### Prerequisites

- `POST /api/auth/login` - User login with credentials

- `GET /api/auth/status` - Check authentication status- **Flutter SDK** (3.24.5 or later)- **Flutter SDK** (3.24.5 or later)

- `GET /api/auth/profile` - Retrieve user profile

- **Android Studio** with Android SDK- **Android Studio** with Android SDK

### Hazards

- `GET /api/hazards` - Fetch all hazards- **Git**- **Git**

- `GET /api/hazards/nearby` - Get hazards near location

- `POST /api/hazards/report` - Report new hazard- **Node.js** (for backend development)- **Node.js** (for backend development)

- `PUT /api/hazards/:id/verify` - Verify hazard report



### Alerts

- `GET /api/alerts` - Retrieve user alerts### Clone the Repository### Clone the Repository

- `PUT /api/alerts/:id/read` - Mark alert as read

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
