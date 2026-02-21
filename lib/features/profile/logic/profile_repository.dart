import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_storage/firebase_storage.dart';
part 'profile_repository.g.dart';

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance
    );
}

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;


    // Method to upload profile image and update Firestore with the new URL
  Future<String> uploadProfileImage(String uId, File imageFile) async {
    // Create a reference to the location in Firebase Storage
    Reference ref = _storage.ref().child('profile_pics').child('$uId.jpg');
    // Upload the file to Firebase Storage
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;

    // Get the download URL of the uploaded image
    String downloadUrl = await snapshot.ref.getDownloadURL();
    
    await _firestore.collection('users').doc(uId).update({
      'profileImage': downloadUrl,
    });

    return downloadUrl;
  }

  // Method to update user data in Firestore
  Future<String?> updateUserData(String uId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uId).update(data);
      return null; // success
    } catch (e) {
      return e.toString(); // return error message
    }
  }

  Future<void> updateTutorLicence({
  required String uId,
  required String licenceNumber, 
  }) async {
      await _firestore.collection('users').doc(uId).update({
        'licenceNumber': licenceNumber, 
        'verificationStatus': 'pending', 
      });
    }


}

