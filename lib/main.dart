import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentineleye/screens/landing_page.dart';
import 'package:sentineleye/screens/camera_screen.dart';
import 'package:sentineleye/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SentinelEye',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const SafetyApp(),
      );
}

class SafetyApp extends StatefulWidget {
  const SafetyApp({super.key});

  @override
  State<SafetyApp> createState() => _SafetyAppState();
}

class _SafetyAppState extends State<SafetyApp> {
  bool _showCamera = false;

  void _startDetection() {
    setState(() => _showCamera = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_showCamera) {
      return const CameraScreen();
    }
    return LandingPage(onStartDetection: _startDetection);
  }
}
