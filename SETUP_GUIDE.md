# HazardNet - Quick Setup Guide

## ✅ What's Already Done

Your Flutter app is **fully functional** with:

1. ✅ **Complete UI/UX** - Welcome screen, Dashboard, Camera, Map, Alerts, Profile
2. ✅ **State Management** - All BLoCs (Auth, Camera, Hazard, Location, Alerts)
3. ✅ **Navigation** - Bottom navigation with 5 screens
4. ✅ **Animations** - Smooth transitions using flutter_animate
5. ✅ **Models** - Data models for User, Hazard, Alert, Location, Sensor data
6. ✅ **Mock Data** - Sample hazards and alerts for testing
7. ✅ **Theme** - Beautiful Material 3 design with dark mode support
8. ✅ **Camera Integration** - Ready to capture frames and send to ML API
9. ✅ **Location Services** - GPS tracking implemented
10. ✅ **Permissions** - Camera and location permission handlers

## 🎯 Test the App Now

```bash
cd f:\Codes\HazardNet
flutter run
```

You'll see:
1. **Welcome Screen** - Onboarding with 4 slides
2. **Dashboard** - Home with quick actions and vehicle health
3. **Camera Screen** - Live camera feed with detection UI
4. **Map Screen** - Hazard list view (Google Maps coming next)
5. **Alerts Screen** - Notification feed with swipe actions
6. **Profile Screen** - User stats and settings

## 🔌 Connect Your ML Model (Next Step)

### 1. Update API Endpoint

Edit `lib/core/constants/app_constants.dart`:

```dart
static const String baseApiUrl = 'YOUR_API_URL';
static const String hazardDetectionEndpoint = '/detect/hazard';
```

### 2. Implement Detection API Call

Edit `lib/bloc/camera/camera_bloc.dart`, find `_onProcessFrame` method:

```dart
void _onProcessFrame(ProcessFrame event, Emitter<CameraState> emit) async {
  // Convert CameraImage to bytes
  final imageBytes = convertCameraImageToBytes(event.imageData);
  
  // Send to your API
  final response = await http.post(
    Uri.parse('${AppConstants.baseApiUrl}${AppConstants.hazardDetectionEndpoint}'),
    body: {
      'image': base64Encode(imageBytes),
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
  
  // Parse response and dispatch hazard detection event
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Create hazard from detection
    context.read<HazardBloc>().add(DetectHazard(...));
  }
}
```

## ️ Google Maps Setup

### 1. Get API Key
- [Google Cloud Console](https://console.cloud.google.com)
- Enable Maps SDK for Android/iOS
- Copy API key

### 2. Add to Android

`android/app/src/main/AndroidManifest.xml`:
```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY_HERE"/>
</application>
```

### 3. Add to iOS

`ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

### 4. Implement Map View

Edit `lib/screens/map/map_screen.dart`, replace placeholder with:
```dart
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 15,
  ),
  markers: _buildMarkers(),
  onMapCreated: (controller) => _mapController = controller,
)
```

## 🗄️ Database Setup (Neon PostgreSQL)

### 1. Create Neon Account
- Sign up at [neon.tech](https://neon.tech)
- Create new project: "hazardnet"

### 2. Schema (Example)

```sql
CREATE TABLE hazards (
    id UUID PRIMARY KEY,
    type VARCHAR(50),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    severity VARCHAR(20),
    confidence DECIMAL(4, 3),
    detected_at TIMESTAMP,
    image_url TEXT,
    is_verified BOOLEAN,
    verification_count INTEGER
);

CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    display_name VARCHAR(100),
    vehicle_type VARCHAR(50),
    cumulative_damage_score INTEGER,
    created_at TIMESTAMP
);
```

### 3. Create API Backend
Create REST API endpoints:
- `POST /api/hazards` - Submit new hazard
- `GET /api/hazards?lat=X&lng=Y&radius=Z` - Get nearby hazards
- `POST /api/hazards/:id/verify` - Verify hazard
- `GET /api/user/:id` - Get user profile
- `PATCH /api/user/:id/damage-score` - Update damage score

## 📱 Permissions Setup

### Android
Already added in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS
Already added permission descriptions needed in `ios/Runner/Info.plist`

## 🎨 Customize App

### Change App Name
- `android/app/src/main/AndroidManifest.xml` - Update `android:label`
- `ios/Runner/Info.plist` - Update `CFBundleName`

### Change App Icon
```bash
# Install package
flutter pub add flutter_launcher_icons --dev

# Add to pubspec.yaml:
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"

# Generate
flutter pub run flutter_launcher_icons
```

### Add Lottie Animations
1. Download from [LottieFiles](https://lottiefiles.com)
2. Place in `assets/lottie/`
3. Use in code:
```dart
Lottie.asset('assets/lottie/loading.json')
```

## 🧪 Test Features

### Camera Detection
1. Go to Camera screen
2. Click play button
3. Point at road
4. See detection stats (FPS, frames processed)

### Location Tracking
1. Enable GPS
2. App will track your location
3. View on Map screen

### Alerts
1. Go to Alerts screen
2. Swipe right to mark as read
3. Swipe left to delete

### Vehicle Health
1. Dashboard shows damage score
2. Score updates when hitting hazards
3. Alert when score > 850

## 📊 Current Mock Data

The app includes:
- 3 mock hazards (pothole, speed breaker, obstacle)
- 4 mock alerts (proximity, maintenance, etc.)
- Anonymous user authentication

Replace with real data from your backend API.

## 🚀 Build for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🐛 Troubleshooting

### Camera not working
- Check permissions granted
- Android: Check minSdkVersion >= 21
- iOS: Check Info.plist has NSCameraUsageDescription

### Location not working
- Enable GPS on device
- Grant location permission
- Check internet connection for geocoding

### Build errors
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

## 📝 TODO List

- [ ] Connect YOLOv8 ML model API
- [ ] Setup Firebase
- [ ] Implement Google Maps
- [ ] Create backend API
- [ ] Setup Neon PostgreSQL
- [ ] Add face/license plate blurring
- [ ] Implement sensor fusion (gyro + accelerometer)
- [ ] Add voice assistant
- [ ] Create admin dashboard
- [ ] Deploy to app stores

## 💡 Tips

1. **Test on real device** for camera and GPS
2. **Setup backend API** with PostgreSQL for production-ready storage
3. **Start with basic detection** before adding advanced features
4. **Monitor performance** when processing camera frames
5. **Implement caching** for offline functionality

---

**You're all set! Run `flutter run` and start testing! 🎉**
