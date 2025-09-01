import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>(); // For form validation
  final _nameController = TextEditingController(); // Controller for name input
  String? _gender; // Stores selected gender
  bool _isLoading = false; // Tracks loading state for save button

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load existing user data from Firestore on screen open
  }

  // Fetch user data from Firestore and populate fields
  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _nameController.text = doc['displayName'] ?? ''; // Prefill name
          _gender = doc['gender'] ?? ''; // Prefill gender
        });
      }
    }
  }

  // Save updated profile info to Firestore
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return; // Stop if invalid

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    try {
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'displayName': _nameController.text.trim(),
          'gender': _gender ?? '',
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Your profile updated successfully"),
            backgroundColor: Color.fromARGB(255, 73, 24, 123),
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update information. Please try again"),
          backgroundColor: Color.fromARGB(255, 179, 16, 114),
        ),
      );
    }

    setState(() => _isLoading = false); // Stop loading
  }

  // Log the user out and navigate back to login screen
  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context,
          '/login', // go back to login screen
          (route) => false // clear navigation stack
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose(); // Clean up controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser; // Get current logged-in user

    return Scaffold(
      appBar: AppBar(), // Simple app bar
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: user == null
            ? const Center(child: Text("No user data available")) // If no user
            : SingleChildScrollView(
          child: Form(
            key: _formKey, // Attach form validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header with icon
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color.fromARGB(255, 205, 114, 244),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Color.fromARGB(255, 130, 4, 111),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Edit your profile",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 92, 2, 74),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Editable Display Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Display User Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Kindly put a name"; // Require name
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Non-editable Email field
                TextFormField(
                  initialValue: user.email ?? '',
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 20),

                // Gender dropdown selection
                DropdownButtonFormField<String>(
                  value: _gender,
                  items: const [
                    DropdownMenuItem(
                      value: "Male",
                      child: Text("Male"),
                    ),
                    DropdownMenuItem(
                      value: "Female",
                      child: Text("Female"),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.transgender),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),
                const SizedBox(height: 30),

                // Save Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 231, 189, 229),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading ? null : _updateProfile, // disable when loading
                    child: _isLoading
                        ? const CircularProgressIndicator( // show loader while saving
                      color: Colors.white,
                    )
                        : const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Logout Button
                SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _logout,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 123, 1, 91),
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
