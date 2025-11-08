import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:event_safety_app/core/theme/app_theme.dart';
import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:event_safety_app/bloc/auth/auth_bloc.dart';
import 'package:event_safety_app/bloc/auth/auth_event.dart';
import 'package:event_safety_app/bloc/location/location_bloc.dart';
import 'package:event_safety_app/bloc/hazard/hazard_bloc.dart';
import 'package:event_safety_app/bloc/camera/camera_bloc.dart';
import 'package:event_safety_app/bloc/alerts/alerts_bloc.dart';
import 'package:event_safety_app/screens/welcome/welcome_screen.dart';
import 'package:event_safety_app/data/services/tflite_service.dart';
import 'package:event_safety_app/data/services/captured_hazard_store.dart';
import 'package:event_safety_app/data/services/gyro_monitor_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations (portrait only for MVP)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize cameras
  final cameras = await availableCameras();
  
  // TODO: Initialize Hive for local storage
  // await Hive.initFlutter();
  
  runApp(HazardNetApp(cameras: cameras));
}

class HazardNetApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const HazardNetApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc()..add(CheckAuthStatus()),
        ),
        BlocProvider(
          create: (context) => LocationBloc(),
        ),
        BlocProvider(
          create: (context) => HazardBloc(),
        ),
        BlocProvider(
          create: (context) => CameraBloc(
            tfliteService: TFLiteService(),
            hazardStore: CapturedHazardStore(),
            locationBloc: context.read<LocationBloc>(),
            gyroMonitor: GyroMonitorService(),
            availableCameras: cameras,
          ),
        ),
        BlocProvider(
          create: (context) => AlertsBloc(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Follow system theme
        home: const WelcomeScreen(),
      ),
    );
  }
}
