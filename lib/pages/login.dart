import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true; // إخفاء وإظهار كلمة المرور

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDEED5), // لون الخلفية الأساسي
      body: Center(
        child: Container(
          width: 380, //  تصغير عرض الكارد
          padding: const EdgeInsets.all(10), //  تقليل البادينج لتصغير الحجم
          child: Card(
            elevation: 6, //  تقليل الظل قليلاً
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white, // لون الكارد
            child: Padding(
              padding: const EdgeInsets.all(16.0), //  تقليل التباعد الداخلي
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/cic_logo2.png',
                    width: 150, //  تصغير حجم اللوجو
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Campus Portal",
                    style: TextStyle(
                      fontSize: 20, //  تقليل حجم النص قليلاً
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // حقل اسم المستخدم
                  _buildTextField("User Name", Icons.person, false),
                  const SizedBox(height: 20),

                  // حقل كلمة المرور
                  _buildTextField("Password", Icons.lock, true),
                  const SizedBox(height: 8),

                  // زر نسيان كلمة المرور
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        // إضافة أكشن عند نسيان كلمة المرور
                      },
                      child: const Text(
                        "Forget Password?",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // زر تسجيل الدخول
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8B0000), // لون الزر
                      foregroundColor: Colors.white, // لون النص
                      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10), // ✅ تقليل التباعد في الزر
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      // الأكشن عند الضغط على تسجيل الدخول
                    },
                    child: const Text("Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // عنصر إدخال نصي مشترك
  Widget _buildTextField(String hintText, IconData icon, bool isPassword) {
    return TextField(
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color:  Color(0xFF8B0000),),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF8B0000),),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF8B0000),),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF8B0000),),
        ),
      ),
    );
  }
}