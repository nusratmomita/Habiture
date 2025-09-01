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
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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
          SnackBar(
            content: Text(error),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurple;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome back text
                Text(
                  "Welcome back!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Logo (optional: uncomment if needed)
                // const CircleAvatar(
                //   radius: 80,
                //   backgroundColor: Colors.transparent,
                //   backgroundImage: AssetImage('assets/logo.png'),
                // ),
                const SizedBox(height: 40),

                // Email Field
                SizedBox(
                  width: 350,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: Icon(Icons.email, size: 26, color: primaryColor),
                      filled: true,
                      fillColor: Colors.purple[50],
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 24),

                // Password Field
                SizedBox(
                  width: 350,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: Icon(Icons.lock, size: 26, color: primaryColor),
                      filled: true,
                      fillColor: Colors.purple[50],
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                    ),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: 350,
                  height: 60,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                        ))
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            elevation: 6,
                            shadowColor: primaryColor.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: 18,
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
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                      children: [
                        TextSpan(
                          text: "Register",
                          style: TextStyle(
                            color: primaryColor,
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
