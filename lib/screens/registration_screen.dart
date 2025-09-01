import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String? _selectedGender;
  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept the terms & conditions'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoading = true);

    String? error = await authProvider.registerUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      displayName: _nameController.text.trim(),
      gender: _selectedGender,
    );

    setState(() => _isLoading = false);

    if (error == null && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Registration failed. Please try again'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  InputDecoration inputDecoration({
    required String label,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.purple[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      helperText: helperText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurple;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "Welcome To Habiture",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Name Field
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: inputDecoration(
                        label: "Full Name*",
                        prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: inputDecoration(
                        label: "Email*",
                        prefixIcon: const Icon(Icons.email, color: Colors.deepPurple),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: inputDecoration(
                        label: "Password*",
                        prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        helperText: 'Min 8 chars, include upper/lowercase & numbers',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$')
                            .hasMatch(value)) {
                          return 'Must include uppercase, lowercase & numbers';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender Dropdown
                  SizedBox(
                    width: 350,
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: inputDecoration(
                        label: "Gender",
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.deepPurple),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Row(
                            children: const [
                              Icon(Icons.help_outline, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('Select Gender (Optional)'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Male',
                          child: Row(
                            children: const [
                              Icon(Icons.male, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Male'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Row(
                            children: const [
                              Icon(Icons.female, color: Colors.pink),
                              SizedBox(width: 8),
                              Text('Female'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Terms & Conditions - Centered
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            onChanged: (value) {
                              setState(() {
                                _termsAccepted = value ?? false;
                              });
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to terms & conditions
                            },
                            child: Text.rich(
                              TextSpan(
                                text: 'I agree to the ',
                                children: [
                                  TextSpan(
                                    text: 'Terms & Conditions*',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  SizedBox(
                    width: 350,
                    height: 55,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Login Link
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
