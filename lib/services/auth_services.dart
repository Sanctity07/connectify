import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/user_model.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = userCredential.user;
      if (user == null) return null;

      await user.updateDisplayName(username);

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }

      final UserModel newUser = UserModel(
        id: user.uid,
        username: username,
        email: email,
        role: "customer",
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection("users")
          .doc(user.uid)
          .set(newUser.toMap());

      return newUser;
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: _signupErrorMessage(e),
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      return null;
    } catch (_) {
      Fluttertoast.showToast(
        msg: "Signup failed. Please try again.",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      return null;
    }
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = userCredential.user;
      if (user == null) return null;

      if (!user.emailVerified) {
        Fluttertoast.showToast(
          msg: "Please verify your email before logging in.",
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
        await _auth.signOut();
        return null;
      }

      final DocumentSnapshot snapshot =
          await _firestore.collection("users").doc(user.uid).get();

      if (!snapshot.exists) {
        Fluttertoast.showToast(
          msg: "User profile not found.",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
        return null;
      }

      final UserModel loggedInUser = UserModel.fromMap(
        snapshot.id,
        snapshot.data() as Map<String, dynamic>,
      );

      return loggedInUser;
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: _loginErrorMessage(e),
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      return null;
    } catch (_) {
      Fluttertoast.showToast(
        msg: "Network error. Check your internet connection.",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      Fluttertoast.showToast(
        msg: "Password reset email sent!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: e.message ?? "Failed to send reset email.",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  String _signupErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case "email-already-in-use":
        return "This email is already registered.";
      case "weak-password":
        return "Password must be at least 6 characters.";
      case "invalid-email":
        return "Invalid email address.";
      default:
        return e.message ?? "Signup failed.";
    }
  }

  String _loginErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case "user-not-found":
        return "No account found for this email.";
      case "wrong-password":
        return "Incorrect password.";
      case "invalid-email":
        return "Invalid email address.";
      default:
        return e.message ?? "Login failed.";
    }
  }
}
      