import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // مكتبة التحكم في النظام
import 'dart:async'; // لإضافة التأخير
import 'prelogin.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textFadeAnimation;

  bool showText = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // تأثير الظهور التدريجي للوجو مع التكبير قليلاً
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // تشغيل الأنيميشن
    _logoController.forward();

    // بعد انتهاء الأنيميشن، إظهار النص بعد تأخير بسيط
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showText = true;
      });
    });

    // الانتقال إلى الصفحة الرئيسية بعد 4.5 ثوانٍ
    Timer(const Duration(milliseconds: 4500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PreLoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: showText
            ? FadeTransition(
          opacity: AlwaysStoppedAnimation(1.0),
          child: Text(
            'CIC-Hub',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
        )
            : ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/cic_logo2.png',
              width: 200,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }
}