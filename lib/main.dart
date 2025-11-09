import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:event_safety_app/core/theme/app_theme.dart';
import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:event_safety_app/bloc/auth/auth_bloc.dart';
import 'package:event_safety_app/bloc/auth/auth_event.dart';
import 'package:event_safety_app/bloc/location/location_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_safety_app/bloc/voice_assistant/voice_assistant_bloc.dart';
import 'package:event_safety_app/bloc/voice_assistant/voice_assistant_event.dart';
import 'package:event_safety_app/data/services/elevenlabs_tts_service.dart';
// mock service removed
import 'package:event_safety_app/bloc/hazard/hazard_bloc.dart';
import 'package:event_safety_app/bloc/camera/camera_bloc.dart';
import 'package:event_safety_app/bloc/alerts/alerts_bloc.dart';
import 'package:event_safety_app/screens/welcome/welcome_screen.dart';
import 'package:event_safety_app/screens/auth/login_screen.dart';
import 'package:event_safety_app/screens/auth/signup_screen.dart';
import 'package:event_safety_app/screens/dashboard/dashboard_screen.dart';
// dev test screen removed
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
  
  // Load environment variables (e.g. API keys). The .env file is ignored by git.
  await dotenv.load(fileName: '.env');

  // Initialize cameras
  final cameras = await availableCameras();

  // Initialize SharedPreferences (used by voice assistant)
  final prefs = await SharedPreferences.getInstance();

  // Choose TTS service: construct ElevenLabs service (apiKey may be empty in dev)
  final apiKey = AppConstants.elevenLabsApiKey;
  final ttsService = ElevenLabsTTSService(apiKey: apiKey);

  // TODO: Initialize Hive for local storage
  // await Hive.initFlutter();

  runApp(HazardNetApp(cameras: cameras, prefs: prefs, ttsService: ttsService));
}

class HazardNetApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  final SharedPreferences prefs;
  final ElevenLabsTTSService ttsService;

  const HazardNetApp({super.key, required this.cameras, required this.prefs, required this.ttsService});

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
        // Provide VoiceAssistantBloc so the test screen and app can use it
        BlocProvider(
          create: (context) => VoiceAssistantBloc(
            ttsService: ttsService,
            prefs: prefs,
          )..add(InitializeVoiceAssistant(languageCode: AppConstants.defaultVoiceLanguage)),
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
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
        home: const WelcomeScreen(),
      ),
    );
  }
}
