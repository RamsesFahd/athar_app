import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:athar_app/core/models/user_model.dart';

// AuthRepository is responsible for performing authentication operations (Sign Up, Sign In, logout, password reset) 
// and deals directly with FirebaseAuth and Firestore.
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // This constructor allows us to pass FirebaseAuth and Firestore
  // From the outside (Dependency Injection) — very important for Riverpod and testing
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // User Collection Reference
  CollectionReference get _users => _firestore.collection('users');


  // SIGN UP
  // Creates a new Firebase Auth account and then stores its data in Firestore
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Create user in FirebaseAuth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the uID that Firebase assigns to each new user
      final String uId = cred.user!.uid;

      // Create a UserModel object to store in Firestore
      final newUser = UserModel(
        uId: uId,
        fullName: fullName,
        email: email,
        accessibilitySettings: AccessibilitySettings(), // default
        createdAt: DateTime.now(),
        role: UserRole.tourist, // defult value
        points: 0,
      );

      // Store user data in Firestore
      await _users.doc(uId).set(newUser.toMap());

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } catch (e) {
      return "Unexpected error: $e";
    }
  }


  // SIGN IN
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


  // RESET PASSWORD
  // Sends password reset email
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


  // LOGIN AS GUEST
  Future<String?> guestLogin() async {
    try {
      UserCredential cred = await _auth.signInAnonymously();

      final String uId = cred.user!.uid;

      final guestUser = UserModel(
        uId: uId,
        fullName: "Guest User",
        email: "",
        accessibilitySettings: AccessibilitySettings(),
        createdAt: DateTime.now(),
        role: UserRole.guest,
      );

      await _users.doc(uId).set(guestUser.toMap());

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } catch (e) {
      return "Unexpected error: $e";
    }
  }


  // ERROR HANDLER
  // Converts FirebaseAuth errors into understandable messages for the user
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Email is already registered.";
      case 'invalid-email':
        return "Invalid email format.";
      case 'user-not-found':
        return "No account found with this email.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'weak-password':
        return "Password must be at least 6 characters.";
      default:
        return "Authentication error: ${e.message}";
    }
  }


  // GET USER DATA (Firestore)
  Future<UserModel?> getUserData(String uId) async {
    try {
      final doc = await _firestore.collection('users').doc(uId).get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }


  // RIVERPOD PROVIDER
  final authRepositoryProvider = Provider<AuthRepository>((ref) {
    return AuthRepository(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
  });
}