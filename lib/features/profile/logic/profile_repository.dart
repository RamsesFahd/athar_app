import 'dart:io';

import 'package:athar_app/core/models/user/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_storage/firebase_storage.dart';
part 'profile_repository.g.dart';

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
    auth: FirebaseAuth.instance,
  );
}

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  ProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance;


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
        'verificationStatus': VerificationStatus.pending.name,
      });
    }

  void sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    int? resendToken,
  }) {
    _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken,
      verificationCompleted: onAutoVerified,
      verificationFailed: (e) => onError(e.message ?? 'فشل التحقق'),
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<String?> confirmPhoneOtp({
    required String uId,
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _applyPhoneCredential(uId: uId, credential: credential, phoneNumber: phoneNumber);
  }

  // Used for Android auto-verification where the credential is already complete.
  Future<String?> applyAutoVerifiedCredential({
    required String uId,
    required PhoneAuthCredential credential,
    required String phoneNumber,
  }) =>
      _applyPhoneCredential(uId: uId, credential: credential, phoneNumber: phoneNumber);

  Future<String?> _applyPhoneCredential({
    required String uId,
    required PhoneAuthCredential credential,
    required String phoneNumber,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'المستخدم غير مسجّل الدخول';

      try {
        await user.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use' ||
            e.code == 'provider-already-linked') {
          await user.updatePhoneNumber(credential);
        } else {
          return e.message ?? 'رمز التحقق غير صحيح';
        }
      }

      await _firestore.collection('users').doc(uId).update({
        'phoneNumber': phoneNumber,
        'phoneVerified': true,
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'رمز التحقق غير صحيح';
    } catch (e) {
      return e.toString();
    }
  }
}

