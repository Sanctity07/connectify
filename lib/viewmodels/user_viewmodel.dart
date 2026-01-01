import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/models/user_model.dart';

class UserViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Load the current user from Firestore
  Future<void> loadCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot snapshot =
          await _firestore.collection("users").doc(firebaseUser.uid).get();

      if (snapshot.exists) {
        _currentUser = UserModel.fromMap(
          snapshot.id,
          snapshot.data() as Map<String, dynamic>,
        );
        notifyListeners();
      }
    }
  }

  /// Update user profile fields
  Future<void> updateProfile({String? username, String? address}) async {
    if (_currentUser == null) return;

    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (address != null) updates['address'] = address;

    await _firestore.collection("users").doc(_currentUser!.id).update(updates);

    // Refresh local model
    await loadCurrentUser();
  }

  /// Clear user on logout
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}