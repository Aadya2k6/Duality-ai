import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    home: const CameraScreen(),
  );
}
