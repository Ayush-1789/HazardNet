# HazardNet Assets

This folder contains app assets like images, icons, animations, and fonts.

## 📁 Structure

```
assets/
├── animations/     # General animations
├── images/         # App images, logos
├── icons/          # Custom icons
├── lottie/         # Lottie JSON animations
└── fonts/          # Custom fonts (Poppins)
```

## 🎨 Lottie Animations

Download free Lottie animations from:
- [LottieFiles](https://lottiefiles.com/)
- [lottielab](https://www.lottielab.com/)

### Recommended Animations to Add:

1. **Loading Animation** (`loading.json`)
   - For: Splash screen, data loading
   - Search: "loading spinner", "road animation"

2. **Success Animation** (`success.json`)
   - For: Successful hazard report
   - Search: "success checkmark", "celebration"

3. **Error Animation** (`error.json`)
   - For: Error states
   - Search: "error", "warning"

4. **Empty State** (`empty.json`)
   - For: No alerts, no hazards
   - Search: "empty box", "no data"

5. **Car Animation** (`car.json`)
   - For: Welcome screen
   - Search: "car driving", "vehicle"

6. **Map Animation** (`map.json`)
   - For: Map loading
   - Search: "map marker", "location"

## 🖼️ Images to Add

### App Icon
- Size: 1024x1024 px
- Format: PNG
- Name: `app_icon.png`
- Design: Shield or road-safety themed

### Logo
- Size: 512x512 px (transparent background)
- Format: PNG
- Name: `logo.png`

### Splash Screen
- Size: Various (adaptive)
- Format: PNG
- Name: `splash.png`

## 🔤 Fonts

Download **Poppins** font from [Google Fonts](https://fonts.google.com/specimen/Poppins):

Required weights:
- Poppins-Regular.ttf (400)
- Poppins-Medium.ttf (500)
- Poppins-SemiBold.ttf (600)
- Poppins-Bold.ttf (700)

Place all `.ttf` files in `assets/fonts/` directory.

## 📥 Quick Download Links

### Fonts
- [Poppins Font](https://fonts.google.com/specimen/Poppins) - Download and extract

### Placeholder until you add real assets
The app will work without these assets, but adding them will enhance the UI significantly.

## 🎯 Usage in Code

```dart
// Lottie
import 'package:lottie/lottie.dart';

Lottie.asset('assets/lottie/loading.json')

// Images
Image.asset('assets/images/logo.png')

// Fonts (already configured in pubspec.yaml)
Text(
  'HazardNet',
  style: TextStyle(fontFamily: 'Poppins'),
)
```

---

**Note:** The app currently works without these assets. Add them to enhance the visual experience.
