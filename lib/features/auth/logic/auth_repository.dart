import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/user/user_model.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
}

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _users => _firestore.collection('users');

  User? get currentUser => _auth.currentUser;

  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    TutorType? tutorType,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uId = cred.user!.uid;

      UserModel newUser;
      final consentTimestamp = DateTime.now();
      if (role == UserRole.tutor) {
        newUser = TutorModel(
          uId: uId,
          fullName: fullName,
          email: email,
          createdAt: consentTimestamp,
          accessibilitySettings: AccessibilitySettings(),
          verificationStatus: VerificationStatus.unverified,
          tutorType: tutorType ?? TutorType.individual,
          privacyPolicyAcceptedAt: consentTimestamp,
        );
      } else {
        newUser = TouristModel(
          uId: uId,
          fullName: fullName,
          email: email,
          createdAt: consentTimestamp,
          accessibilitySettings: AccessibilitySettings(),
          privacyPolicyAcceptedAt: consentTimestamp,
        );
      }

      // Write Firestore doc and send verification email atomically from the
      // caller's perspective: if either step fails, roll back both so the user
      // can re-register without orphaned Auth/Firestore records.
      try {
        await _users.doc(uId).set(newUser.toMap());
        await sendEmailVerification();
        return null;
      } catch (e) {
        await _users.doc(uId).delete().catchError((_) {});
        await _auth.currentUser?.delete().catchError((_) {});
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  Future<void> logOut() async {
    await _auth.signOut();
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return 'errorGoogleSignInCancelled';

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } catch (e) {
      return 'errorUnexpected';
    }
  }

  Future<String?> createGoogleUser({
    required UserRole role,
    TutorType? tutorType,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'errorUnexpected';

      final consentTimestamp = DateTime.now();
      UserModel newUser;
      if (role == UserRole.tutor) {
        newUser = TutorModel(
          uId: user.uid,
          fullName: user.displayName ?? 'User',
          email: user.email ?? '',
          createdAt: consentTimestamp,
          accessibilitySettings: AccessibilitySettings(),
          verificationStatus: VerificationStatus.unverified,
          tutorType: tutorType ?? TutorType.individual,
          privacyPolicyAcceptedAt: consentTimestamp,
        );
      } else {
        newUser = TouristModel(
          uId: user.uid,
          fullName: user.displayName ?? 'User',
          email: user.email ?? '',
          createdAt: consentTimestamp,
          accessibilitySettings: AccessibilitySettings(),
          privacyPolicyAcceptedAt: consentTimestamp,
        );
      }

      await _users.doc(user.uid).set(newUser.toMap());
      return null;
    } catch (e) {
      return 'errorUnexpected';
    }
  }

  // Allows unauthenticated users to explore the app without committing to an account.
  Future<String?> guestLogin() async {
    try {
      // Reuse an existing anonymous session to avoid orphaned Auth accounts
      // accumulating on repeated taps of "Continue as Guest".
      if (_auth.currentUser != null && _auth.currentUser!.isAnonymous) {
        return null;
      }
      UserCredential cred = await _auth.signInAnonymously();
      final String uId = cred.user!.uid;

      final guestUser = TouristModel(
        uId: uId,
        fullName: "Guest User",
        email: "",
        role: UserRole.guest,
        accessibilitySettings: AccessibilitySettings(),
        createdAt: DateTime.now(),
      );

      await _users.doc(uId).set(guestUser.toMap());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  // Injects emailVerified from Firebase Auth (not stored in Firestore) before parsing.
  UserModel? _parseUserDoc(DocumentSnapshot doc) {
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    data['emailVerified'] = _auth.currentUser?.emailVerified ?? false;
    return UserModel.fromMap(data);
  }

  Future<UserModel?> getUserData(String uId) async {
    try {
      // Cache-first: returns instantly on repeat launches (Firestore offline persistence).
      // Falls back to network on first launch or cache miss.
      try {
        final cached = await _users
            .doc(uId)
            .get(const GetOptions(source: Source.cache));
        final user = _parseUserDoc(cached);
        if (user != null) return user;
      } catch (_) {
        // Cache miss — fall through to network.
      }
      final doc = await _users.doc(uId).get();
      return _parseUserDoc(doc);
    } catch (e) {
      return null;
    }
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      try {
        return _parseUserDoc(doc);
      } catch (_) {
        return null;
      }
    });
  }

  Future<String?> deleteAccount(String uId) async {
    try {
      // Delete the Auth account first so a requires-recent-login error
      // leaves the Firestore profile untouched and the account stays consistent.
      await _auth.currentUser?.delete();
      await _firestore.collection('users').doc(uId).delete();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } catch (e) {
      return e.toString();
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) => mapFirebaseError(e);

  @visibleForTesting
  String mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "errorEmailAlreadyInUse";
      case 'invalid-email':
        return "errorInvalidEmail";
      case 'user-not-found':
        return "errorUserNotFound";
      case 'wrong-password':
        return "errorWrongPassword";
      case 'weak-password':
        return "errorWeakPassword";
      default:
        return "errorUnexpected";
    }
  }

  Future<String?> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return _auth.currentUser!.emailVerified;
    }
    return false;
  }

  Future<void> updateEmailVerificationInFirestore(String uId) async {
    try {
      await _users.doc(uId).update({'emailVerified': true});
    } catch (e) {
      // Non-critical: emailVerified flag update failed; auth state remains valid.
      rethrow;
    }
  }
}
