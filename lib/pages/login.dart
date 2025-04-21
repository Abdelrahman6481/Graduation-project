import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cic_hub/pages/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, //? تأكيد أن الخلفية بيضاء
      body: Stack(
        children: [
          // Background Design
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white, //? تأكيد أن خلفية الـ Container بيضاء
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.red.shade900.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.red.shade900.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    // Logo
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 10,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset('assets/cic_logo2.png', height: 80),
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Welcome Text
                    Center(
                      child: Text(
                        "Welcome back",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Student ID Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextFormField(
                        controller: _idController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: "Student ID",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.red.shade900,
                          ),
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Please enter your ID' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: "Password",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.red.shade900,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Please enter your password'
                                    : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Login Button
                    Container(
                      width: double.infinity,
                      height: 60, //? ارتفاع ثابت للزر
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade900, Colors.red.shade800],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade900.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            color: Colors.white, //? تغيير لون النص إلى الأبيض
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Help Center
                    Center(
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.help_outline,
                          color: Colors.red.shade900,
                        ),
                        label: Text(
                          "Need Help?",
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
