import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ?مكتبة التحكم في النظام
import 'pages/splash_screen.dart'; // ? استدعاء شاشة السبللاش // استدعاء صفحة الملف الشخصي

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // ?إخفاء شريط التصحيح
      home: SplashScreen(), // ? تشغيل شاشة السبللاش أولاً
    );
  }
}
