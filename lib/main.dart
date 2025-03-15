import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // مكتبة التحكم في النظام
import 'pages/prelogin.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // تهيئة التطبيق

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // جعل شريط الحالة شفاف
    statusBarIconBrightness: Brightness.dark, // يجعل الأيقونات سوداء (حسب لون الخلفية)
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PreLoginPage(), // تشغيل الصفحة الرئيسية
    );
  }
}
