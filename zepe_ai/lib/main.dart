import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/home_screen.dart';
import 'providers/voice_provider.dart';
import 'providers/zepe_brain_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request microphone permission on startup
  await Permission.microphone.request();
  
  runApp(const ZepeAIApp());
}

class ZepeAIApp extends StatelessWidget {
  const ZepeAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VoiceProvider()),
        ChangeNotifierProvider(create: (_) => ZepeBrainProvider()),
      ],
      child: MaterialApp(
        title: 'ZEPE AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
