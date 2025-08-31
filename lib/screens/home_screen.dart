import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await auth.logout();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              })
        ],
      ),
      body: const Center(
        child: Text('Welcome to Habiture!'),
      ),
    );
  }
}
