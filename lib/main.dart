import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ?مكتبة التحكم في النظام
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/splash_screen.dart'; // ? استدعاء شاشة السبللاش // استدعاء صفحة الملف الشخصي
import 'pages/login.dart';
import 'pages/prelogin.dart';
import 'pages/home.dart';
import 'pages/instructor_login.dart';
import 'pages/instructor_home.dart';
import 'pages/admin_home.dart';
import 'services/firestore_service.dart';

// These functions are kept for reference but not called on startup anymore
Future<void> createNewAdmin() async {
  try {
    // Generate a unique admin ID - you can change this
    final String adminId = 'admin_${DateTime.now().millisecondsSinceEpoch}';

    // Create admin directly in Firestore
    await FirebaseFirestore.instance.collection('admins').doc(adminId).set({
      'id': adminId,
      'name': 'New Direct Admin',
      'email': 'directadmin@example.com',
      'password': 'admin123',
      'phone': '9876543210',
      'address': 'Main Office',
      'lastLogin': FieldValue.serverTimestamp(),
    });

    print('NEW ADMIN CREATED: $adminId');
    print('Email: directadmin@example.com');
    print('Password: admin123');
  } catch (e) {
    print('Error creating new admin: $e');
  }
}

Future<void> testFirebaseConnection() async {
  try {
    // Log a test event to Firebase Analytics
    await FirebaseAnalytics.instance.logEvent(
      name: 'app_opened',
      parameters: {'test_time': DateTime.now().toString()},
    );
    print('Firebase connection test successful!');
  } catch (e) {
    print('Firebase connection test failed: $e');
  }
}

Future<void> addSpecificStudent() async {
  try {
    final firestoreService = FirestoreService();
    await firestoreService.addSpecificStudent(
      id: 'j0HXdDCO80VcAuiFC9sJJ9cOfZN2',
      name: 'Test Student',
      email: 'test@example.com',
      password: 'test123',
      phone: '1234567890',
      address: 'Test Address',
      level: 1,
      credits: 0,
      collegeName: 'CIC',
      major: 'Computer Science',
      gpa: 0.0,
    );
    print('Specific student added successfully');
  } catch (e) {
    print('Error adding specific student: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Only test the Firebase connection
  await testFirebaseConnection();

  // The following functions are removed from auto-execution on startup
  // await addSpecificStudent();
  // await createNewAdmin();

  // إخفاء شريط الحالة (Status Bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // ? جعل شريط الحالة شفاف
      statusBarIconBrightness: Brightness.dark, // ? لون الأيقونات
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Create an instance of FirebaseAnalytics
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ?إخفاء شريط التصحيح
      navigatorObservers: [observer], // Add the observer
      title: 'CIC Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade900),
        useMaterial3: true,
      ),
      // Define routes
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/prelogin': (context) => const PreLoginPage(),
        '/instructor-login': (context) => const InstructorLoginPage(),
        '/home':
            (context) => const HomePage(
              userType: 'student',
              user: {'name': 'Guest Student'},
            ),
        '/admin-home':
            (context) => const AdminHomePage(admin: {'name': 'Admin'}),
        // Add other routes as needed
      },
      // Remove the home property since we're using initialRoute
      // home: Stack(...)
    );
  }
}
