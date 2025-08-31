import 'package:flutter/material.dart';
import 'package:habiture/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  String? _gender;
  bool _agree = false;

  bool _obscurePassword = true; // 👈 For password toggle

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _username.dispose();
    _password.dispose();
    _dob.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to Terms & Conditions')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final error = await auth.register(
      User(
        username: _username.text.trim(),
        password: _password.text,
        gender: _gender,
        dob: _dob.text,
      ),
    );

    if (error == null) {
        Fluttertoast.showToast(
          msg: "Registration Successful 🎉",
          backgroundColor: Colors.green,
        );
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Fluttertoast.showToast(
          msg: error,
          backgroundColor: Colors.red,
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 184, 191, 237),Color.fromARGB(255, 215, 172, 248)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: auth.loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Center(
                child: SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 25),
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_add,
                                  size: 80, color: Color(0xFF6D0EB5)),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _username,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) =>
                                    val == null || val.isEmpty
                                        ? 'Required'
                                        : null,
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _password,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Required';
                                  }
                                  if (val.length < 6) {
                                    return 'Min 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _dob,
                                decoration: const InputDecoration(
                                  labelText: 'DOB (optional)',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 15),
                              DropdownButtonFormField<String>(
                                value: _gender,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Male',
                                      child: Row(
                                        children: [
                                          Icon(Icons.male, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Text('Male')
                                        ],
                                      )),
                                  DropdownMenuItem(
                                      value: 'Female',
                                      child: Row(
                                        children: [
                                          Icon(Icons.female,
                                              color: Colors.pink),
                                          SizedBox(width: 8),
                                          Text('Female')
                                        ],
                                      )),
                                  DropdownMenuItem(
                                      value: 'Other',
                                      child: Row(
                                        children: [
                                          Icon(Icons.person_outline,
                                              color: Colors.purple),
                                          SizedBox(width: 8),
                                          Text('Other')
                                        ],
                                      )),
                                ],
                                onChanged: (val) =>
                                    setState(() => _gender = val),
                                decoration: const InputDecoration(
                                  labelText: 'Gender (optional)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              CheckboxListTile(
                                title: const Text(
                                  'Agree to Terms & Conditions',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                value: _agree,
                                onChanged: (val) =>
                                    setState(() => _agree = val!),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 218, 198, 233),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: const Text('Register'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Already have an account? Login',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 115, 127, 209),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
