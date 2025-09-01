import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';// !

// AuthProvider manages Firebase Authentication and user data in Firestore
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // ! Firestore instance

  // Current logged-in user
  User? get currentUser => _auth.currentUser;

  //create a new User
  Future<String?> registerUser({
    required String email,
    required String password,
    required String displayName,
    String? gender,
    Map<String, dynamic>? otherDetails,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        String userId = user.uid;

        // Set display name in Firebase Auth profile
        await user.updateDisplayName(displayName);

        // Create user document in Firestore
        await _firestore.collection('users').doc(userId).set({
          'uid': userId,
          'displayName': displayName,
          'email': email,
          'gender': gender ?? '', // store gender if provided
          'otherDetails': (otherDetails != null &&
                  otherDetails is Map<String, dynamic>)
              ? otherDetails
              : {}, // optional extra fields
          'createdAt': FieldValue.serverTimestamp(), // creation timestamp
        });

        notifyListeners(); // notify UI of auth changes
        return null; // success
      }

      // Fallback error if user is null
      return "Unknown error: User is null";

    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuth error: ${e.message}");
      return e.message; // return Firebase auth error message
    } catch (e) {
      debugPrint("Unknown register: $e");
      return "Error occurred: $e"; // return generic error
    }
  }

  // 🔹 Login User
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners(); // notify UI of auth changes
      return null; // success
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuth error: ${e.message}");
      return e.message; // return Firebase auth error
    } catch (e) {
      debugPrint("Unknown login: $e");
      return "Error occurred: $e"; // generic error
    }
  }

  // 🔹 Logout
  Future<void> logout() async {
    await _auth.signOut(); // Sign out user
    notifyListeners(); // notify UI
  }

  // 🔹 Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
