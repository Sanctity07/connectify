import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile photo → returns download URL
  /// Stored at: profile_photos/{uid}.jpg
  Future<String> uploadProfilePhoto({
    required String uid,
    required File file,
  }) async {
    final ref = _storage.ref().child('profile_photos/$uid.jpg');
    final snapshot = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await snapshot.ref.getDownloadURL();
  }

  /// Upload a portfolio photo → returns download URL
  /// Stored at: portfolio_photos/{uid}/{index}.jpg
  Future<String> uploadPortfolioPhoto({
    required String uid,
    required File file,
    required int index,
  }) async {
    final ref =
        _storage.ref().child('portfolio_photos/$uid/$index.jpg');
    final snapshot = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await snapshot.ref.getDownloadURL();
  }
}