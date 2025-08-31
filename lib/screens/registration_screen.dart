import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  String? _gender;
  bool _agree = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must agree to Terms & Conditions')));
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final error = await auth.register(User(
      username: _username.text.trim(),
      password: _password.text,
      gender: _gender,
      dob: _dob.text,
    ));

    if (error == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: auth.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _username,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _password,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (val.length < 6) return 'Min 6 characters';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _dob,
                      decoration: const InputDecoration(labelText: 'DOB (optional)'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (val) => setState(() => _gender = val),
                      decoration: const InputDecoration(labelText: 'Gender (optional)'),
                    ),
                    CheckboxListTile(
                      title: const Text('Agree to Terms & Conditions'),
                      value: _agree,
                      onChanged: (val) => setState(() => _agree = val!),
                    ),
                    ElevatedButton(
                      onPressed: _register,
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
