import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hidePassword = true;

  bool _validatePasswordStructure(String value) {
    return RegExp(r'[A-Z]').hasMatch(value) &&
        RegExp(r'[a-z]').hasMatch(value) &&
        RegExp(r'[0-9]').hasMatch(value) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
  }

  void _processLoginAuthentication() async {
    if (!_formKey.currentState!.validate()) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('local_username') ?? "";
    final storedPass = prefs.getString('local_password') ?? "";

    if (_usernameController.text.trim() == storedUser && _passwordController.text == storedPass) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MainStorefrontScreen(username: storedUser),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Authentication Failed. Invalid Maison Credentials."),
          backgroundColor: Color(0xFF6B2D5C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A0B),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Fixed typo here
              children: [
                const Center(
                  child: Text(
                    "M A I S O N  V A L E N T I N E",
                    style: TextStyle(fontFamily: 'Serif', fontSize: 13, color: Color(0xFFD4AF37), letterSpacing: 4),
                  ),
                ),
                const SizedBox(height: 60),
                const Text(
                  "Sign In",
                  style: TextStyle(fontFamily: 'Serif', fontSize: 32, fontWeight: FontWeight.w300, color: Colors.white, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Access your personalized premium vanity profile dashboard.",
                  style: TextStyle(fontSize: 13, color: Colors.white38),
                ),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  cursorColor: const Color(0xFFD4AF37),
                  decoration: _buildLuxuryInputDecoration("Username Identity", Icons.portrait_outlined),
                  validator: (v) => (v == null || v.trim().length < 8) ? "Identity signature must be ≥ 8 chars" : null,
                ),
                const SizedBox(height: 28),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  cursorColor: const Color(0xFFD4AF37),
                  decoration: _buildLuxuryInputDecoration("Secret Passphrase", Icons.vpn_key_outlined).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38, size: 20),
                      onPressed: () => setState(() => _hidePassword = !_hidePassword),
                    ),
                  ),
                  validator: (v) => (v == null || !_validatePasswordStructure(v)) ? "Complexity standards unmet" : null,
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C1A1A),
                    side: const BorderSide(color: Color(0xFFD4AF37), width: 0.8),
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: _processLoginAuthentication,
                  child: const Text(
                    "AUTHENTICATE PROFILE",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3),
                  ),
                ),
                const SizedBox(height: 24),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                    child: const Text(
                      "Create New Maison Membership Account",
                      style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, letterSpacing: 0.5, decoration: TextDecoration.underline, decorationColor: Color(0xFFD4AF37)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildLuxuryInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 1),
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37), width: 1.2)),
      errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
    );
  }
}