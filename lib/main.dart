import 'package:electric_home/screens/add_device_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ElectricHomeApp());
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
      // แก้ตรงนี้: ใช้ home แทน initialRoute เพื่อเช็คสถานะ Auth
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. ถ้ากำลังเชื่อมต่อ Firebase (ช่วงเสี้ยววินาทีแรก)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen(); 
          }
          // 2. ถ้าล็อกอินแล้ว ส่งไปหน้า Home
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          // 3. ถ้ายังไม่ได้ล็อกอิน ส่งไปหน้า Login
          return const LoginScreen();
        },
      ),
      routes: {
        // ลบ initialRoute ออก แล้วใช้ routes สำหรับการกด Navigator.pushNamed แทน
        '/login':        (context) => const LoginScreen(),
        '/home':         (context) => const HomeScreen(),
        '/announcement': (context) => const AnnouncementScreen(),
        '/review':       (context) => const ReviewScreen(),
        '/calculate':    (context) => const CalculateScreen(),
        '/profile':      (context) => const ProfileScreen(),
        '/location':     (context) => const LocationScreen(),
        '/add_electrical_water': (context) => const AddElectricalWaterScreen(),
        '/add_device':   (context) => const AddDeviceScreen(),
        '/timer':        (context) => const TimerScreen(),
      },
    );
  }
}