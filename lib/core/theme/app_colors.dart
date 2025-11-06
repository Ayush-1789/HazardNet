import 'package:flutter/material.dart';

/// Application color palette - Modern premium design system
class AppColors {
  // Primary Brand Colors - Deep Indigo
  static const Color primaryBlue = Color(0xFF5B6CF2);
  static const Color primaryBlueDark = Color(0xFF4350D8);
  static const Color primaryBlueLight = Color(0xFF7C8BF5);
  
  // Secondary Colors - Vibrant Teal
  static const Color secondaryGreen = Color(0xFF00D9C0);
  static const Color secondaryGreenDark = Color(0xFF00BFA9);
  static const Color secondaryGreenLight = Color(0xFF33E3CE);
  
  // Accent Colors - Modern Palette
  static const Color accentOrange = Color(0xFFFF6B3D);
  static const Color accentPurple = Color(0xFF9B5DE5);
  
  // Status Colors - Enhanced
  static const Color success = Color(0xFF00D9C0);
  static const Color warning = Color(0xFFFBB040);
  static const Color error = Color(0xFFFF5C5C);
  static const Color info = Color(0xFF5B6CF2);
  
  // Severity Colors (for hazard indication)
  static const Color severityLow = Color(0xFF00D9C0);
  static const Color severityMedium = Color(0xFFFBB040);
  static const Color severityHigh = Color(0xFFFF6B3D);
  static const Color severityCritical = Color(0xFFFF5C5C);
  
  // Neutral Colors - Premium Light Theme
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFBFC);
  static const Color grey100 = Color(0xFFF4F6F8);
  static const Color grey200 = Color(0xFFE8ECF1);
  static const Color grey300 = Color(0xFFD1D8E0);
  static const Color grey400 = Color(0xFFA8B2C1);
  static const Color grey500 = Color(0xFF7C8BA1);
  static const Color grey600 = Color(0xFF5A6B82);
  static const Color grey700 = Color(0xFF3E4E63);
  static const Color grey800 = Color(0xFF2D3748);
  static const Color grey900 = Color(0xFF1A202C);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F0F1E);
  static const Color darkSurface = Color(0xFF1A1B2E);
  static const Color darkCard = Color(0xFF252641);
  
  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5B6CF2), Color(0xFF9B5DE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient safetyGradient = LinearGradient(
    colors: [Color(0xFF00D9C0), Color(0xFF00BFA9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF6B3D), Color(0xFFFF5C5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFBB040), Color(0xFFFF6B3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Hero Gradient
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF5B6CF2), Color(0xFF4350D8), Color(0xFF9B5DE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Hazard Type Colors - Modern
  static const Color potholeColor = Color(0xFF8B5A3C);
  static const Color speedBreakerColor = Color(0xFFFBB040);
  static const Color obstacleColor = Color(0xFFFF6B3D);
  static const Color closedRoadColor = Color(0xFFFF5C5C);
  static const Color laneBlockedColor = Color(0xFFFF8A50);
  
  // Map Colors
  static const Color mapMarkerSafe = secondaryGreen;
  static const Color mapMarkerWarning = warning;
  static const Color mapMarkerDanger = error;
  static const Color userLocationMarker = primaryBlue;
  
  // Transparent Overlays
  static const Color overlayLight = Color(0x33000000); // 20% black
  static const Color overlayMedium = Color(0x66000000); // 40% black
  static const Color overlayDark = Color(0x99000000); // 60% black
  
  // Camera Overlay
  static const Color cameraOverlay = Color(0x80000000); // 50% black
  static const Color detectionBox = Color(0xFFFFFF00); // Yellow
}
