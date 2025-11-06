# HazardNet - Project Structure Guide

## 📂 Complete File Structure

```
f:\Codes\HazardNet\
│
├── android/                    # Android-specific code
├── ios/                        # iOS-specific code
├── web/                        # Web-specific code
├── windows/                    # Windows-specific code
│
├── assets/                     # App assets
│   ├── animations/             # General animations
│   ├── images/                 # Images and logos
│   ├── icons/                  # Custom icons
│   ├── lottie/                 # Lottie JSON files
│   ├── fonts/                  # Custom fonts (Poppins)
│   └── README.md               # Assets guide
│
├── lib/                        # Main Flutter code
│   │
│   ├── core/                   # Core app functionality
│   │   ├── constants/
│   │   │   └── app_constants.dart      # App-wide constants
│   │   ├── theme/
│   │   │   ├── app_colors.dart         # Color palette
│   │   │   └── app_theme.dart          # Theme configuration
│   │   └── utils/                      # Helper utilities
│   │
│   ├── data/                   # Data layer
│   │   ├── repositories/       # Repository pattern
│   │   └── services/           # API services, local storage
│   │
│   ├── models/                 # Data models
│   │   ├── hazard_model.dart           # Hazard data model
│   │   ├── alert_model.dart            # Alert data model
│   │   ├── user_model.dart             # User data model
│   │   ├── location_model.dart         # Location data model
│   │   └── sensor_data_model.dart      # Sensor data model
│   │
│   ├── bloc/                   # State Management (BLoC)
│   │   ├── auth/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── camera/
│   │   │   ├── camera_bloc.dart        # Camera control
│   │   │   ├── camera_event.dart
│   │   │   └── camera_state.dart
│   │   ├── hazard/
│   │   │   ├── hazard_bloc.dart        # Hazard detection & management
│   │   │   ├── hazard_event.dart
│   │   │   └── hazard_state.dart
│   │   ├── location/
│   │   │   ├── location_bloc.dart      # GPS tracking
│   │   │   ├── location_event.dart
│   │   │   └── location_state.dart
│   │   └── alerts/
│   │       ├── alerts_bloc.dart        # Notification management
│   │       ├── alerts_event.dart
│   │       └── alerts_state.dart
│   │
│   ├── screens/                # UI Screens
│   │   ├── welcome/
│   │   │   └── welcome_screen.dart     # Onboarding (4 slides)
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart   # Main hub with navigation
│   │   ├── camera/
│   │   │   └── camera_screen.dart      # Live detection screen
│   │   ├── map/
│   │   │   └── map_screen.dart         # Map view with hazards
│   │   ├── alerts/
│   │   │   └── alerts_screen.dart      # Notifications feed
│   │   └── profile/
│   │       └── profile_screen.dart     # User profile & settings
│   │
│   ├── widgets/                # Reusable widgets
│   │   └── common/             # Common widgets
│   │
│   └── main.dart               # App entry point
│
├── test/                       # Unit and widget tests
│
├── pubspec.yaml                # Dependencies configuration
├── README.md                   # Project documentation
├── SETUP_GUIDE.md              # Quick setup instructions
└── .gitignore                  # Git ignore rules

```

## 🎯 Key Files Explained

### Entry Point
- **`lib/main.dart`** - App initialization, BLoC providers, theme setup

### Core
- **`app_constants.dart`** - API URLs, thresholds, settings
- **`app_colors.dart`** - Color palette for the entire app
- **`app_theme.dart`** - Light & dark theme configuration

### Models
All data models with:
- Properties
- JSON serialization
- Equatable for value comparison
- Helper methods

### BLoCs
State management using BLoC pattern:
- **Events** - User actions (e.g., StartDetection)
- **States** - UI states (e.g., CameraReady)
- **Bloc** - Business logic and state transitions

### Screens

| Screen | Purpose | Features |
|--------|---------|----------|
| Welcome | Onboarding | 4-slide introduction with animations |
| Dashboard | Home | Quick actions, stats, vehicle health |
| Camera | Detection | Live camera feed, start/stop detection |
| Map | Visualization | Hazards on map, nearby list |
| Alerts | Notifications | Alert feed, swipe actions |
| Profile | Settings | User info, stats, preferences |

## 🔄 Data Flow

```
User Action
    ↓
Event (e.g., StartDetection)
    ↓
BLoC processes event
    ↓
API Call / Local Processing
    ↓
New State emitted
    ↓
UI rebuilds with new state
```

## 🎨 Styling

- Material 3 Design System
- Custom color palette (safety-focused)
- Responsive layouts
- Smooth animations with flutter_animate
- Dark mode support

## 🔧 Configuration Files

### `pubspec.yaml`
- Dependencies
- Assets declaration
- Font configuration

### Platform-Specific
- **Android**: `android/app/build.gradle`, `AndroidManifest.xml`
- **iOS**: `ios/Runner/Info.plist`, `AppDelegate.swift`

## 📦 Important Packages

### State Management
- `flutter_bloc` - BLoC pattern
- `equatable` - Value equality

### UI/UX
- `flutter_animate` - Animations
- `lottie` - Lottie animations
- `animations` - Page transitions

### Hardware
- `camera` - Camera access
- `geolocator` - GPS tracking
- `sensors_plus` - Gyro, accelerometer

### Backend Ready
- `http` / `dio` - REST API calls
- `hive` - Local database
- `shared_preferences` - Key-value storage

## 🚀 How to Navigate the Code

### 1. Start with `main.dart`
Understand app initialization and routing

### 2. Check `app_constants.dart`
See all configurable values

### 3. Explore Models
Understand data structures

### 4. Study BLoCs
Learn business logic

### 5. Review Screens
See how UI is built

## 🎓 Learning Path

1. **Beginner**: Focus on screens and widgets
2. **Intermediate**: Understand BLoC pattern and state management
3. **Advanced**: API integration, optimization, advanced features

## 📝 Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE`

## 🔍 Finding Specific Features

| Feature | Location |
|---------|----------|
| Camera detection | `lib/bloc/camera/camera_bloc.dart` |
| Hazard management | `lib/bloc/hazard/hazard_bloc.dart` |
| GPS tracking | `lib/bloc/location/location_bloc.dart` |
| Alert system | `lib/bloc/alerts/alerts_bloc.dart` |
| User auth | `lib/bloc/auth/auth_bloc.dart` |
| Theme/colors | `lib/core/theme/` |
| API config | `lib/core/constants/app_constants.dart` |

## 💡 Best Practices Followed

✅ Clean Architecture  
✅ BLoC State Management  
✅ Separation of Concerns  
✅ Reusable Components  
✅ Type Safety  
✅ Error Handling  
✅ Comments on complex logic  
✅ Responsive Design  

## 🔜 What to Add Next

1. **API Services** in `lib/data/services/`
2. **Repositories** in `lib/data/repositories/`
3. **Custom Widgets** in `lib/widgets/common/`
4. **Utilities** in `lib/core/utils/`
5. **Tests** in `test/`

---

**Happy Coding! 🚀**
