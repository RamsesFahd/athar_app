import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository.g.dart';

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository(firestore: FirebaseFirestore.instance);
}

class ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Method to update user data in Firestore
  Future<String?> updateUserData(String uId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uId).update(data);
      return null; // success
    } catch (e) {
      return e.toString(); // return error message
    }
  }
}