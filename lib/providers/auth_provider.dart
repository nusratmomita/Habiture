import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Update display name and notify listeners
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name); // Update in Firebase Auth
      await user.reload(); // Refresh user info
      notifyListeners(); // Notify UI
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

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
        await user.updateDisplayName(displayName);

        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'displayName': displayName,
          'email': email,
          'gender': gender ?? '',
          'otherDetails': otherDetails ?? {},
          'createdAt': FieldValue.serverTimestamp(),
        });

        notifyListeners();
        return null;
      }

      return "Unknown error: User is null";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
