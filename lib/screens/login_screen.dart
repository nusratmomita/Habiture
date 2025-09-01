import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoading = true);

    String? error = await authProvider.loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome back text
                Text(
                  "Welcome back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4CAF50), // Green color
                  ),
                ),
                const SizedBox(height: 20),

                // Larger Application Logo
                // const CircleAvatar(
                //   radius: 80, // Increased from 60
                //   backgroundColor: Colors.transparent,
                //   backgroundImage: AssetImage('assets/logo.png'),
                // ),
                const SizedBox(height: 40),

                // Larger Email Input Field
                SizedBox(
                  width: 350, // Increased from 300
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), // Slightly more rounded
                      ),
                      prefixIcon: const Icon(Icons.email, size: 24), // Larger icon
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 18), // Increased padding
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 18), // Larger text
                  ),
                ),
                const SizedBox(height: 24),

                // Larger Password Input Field
                SizedBox(
                  width: 350, // Increased from 300
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock, size: 24), // Larger icon
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 18),
                    ),
                    obscureText: true,
                    style: const TextStyle(fontSize: 18), // Larger text
                  ),
                ),
                const SizedBox(height: 32),

                // Larger Login Button
                SizedBox(
                  width: 350, // Increased from 300
                  height: 60, // Increased from 50
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4CAF50)),
                    ),
                  )
                      : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Green color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(
                        fontSize: 18, // Larger text
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Register Option
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 16), // Slightly larger
                      children: [
                        TextSpan(
                          text: "Register",
                          style: TextStyle(
                            color: const Color(0xFF4CAF50), // Green color
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
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
}