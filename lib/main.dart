import 'package:electric_home/screens/add_device_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/payment_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/announcement_screen.dart';
import 'screens/review_screen.dart';
import 'screens/calculate_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/location_screen.dart';
import 'screens/add_electrical_water_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/tracking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => PaymentProvider(),
      child: const ElectricHomeApp(),
    ),
  );
}

class ElectricHomeApp extends StatelessWidget {
  const ElectricHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electric Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF87),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/loading': (context) => const LoadingScreen(),
        '/home': (context) => const HomeScreen(),
        '/announcement': (context) => const AnnouncementScreen(),
        '/review': (context) => const ReviewScreen(),
        '/calculate': (context) => const CalculateScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/location': (context) => const LocationScreen(),
        '/add_electrical_water': (context) => const AddElectricalWaterScreen(),
        '/add_device': (context) => const AddDeviceScreen(),
        '/timer': (context) => const TimerScreen(),
        '/tracking': (context) => const TrackingScreen(),
      },
    );
  }
}