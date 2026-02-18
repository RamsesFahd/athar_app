import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart'; 
import 'package:athar_app/core/models/user/user_model.dart';

// This line link this file to the generated file Riverpod will create
part 'auth_repository.g.dart'; 

// This is the provider that will give us an instance of AuthRepository (authRepositoryProvider) is the name of the provider we will use in our app to access the AuthRepository
// We use @riverpod to generate the provider code for us
// AuthRepositoryRef ref is a reference that allows us to read other providers if needed
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
}

// This is the actual repository class that contains all the logic for authentication
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore,})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // This getter gives us easy access to the 'users' collection in Firestore
  CollectionReference get _users => _firestore.collection('users');

  // This getter allows us to easily check if there's a currently authenticated user
  User? get currentUser => _auth.currentUser;

  // sign up method that takes email, password, and full name to create a new user account
Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role, // so the user can choose if they are a tutor or a tourist during sign up, and we can create the appropriate user document in Firestore based on their role
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final String uId = cred.user!.uid;
      await sendEmailVerification();
      
      UserModel newUser;
      // in case the user is a tutor, we create a TutorModel with the provided information, and if they are a tourist, we create a TouristModel. Both models extend UserModel, so we can store them in the same 'users' collection in Firestore.
      if (role == UserRole.tutor) {
        newUser = TutorModel(
          uId: uId,
          fullName: fullName,
          email: email,
          createdAt: DateTime.now(),
          accessibilitySettings: AccessibilitySettings(),
        
        );
      } else {
        newUser = TouristModel(
          uId: uId,
          fullName: fullName,
          email: email,
          createdAt: DateTime.now(),
          accessibilitySettings: AccessibilitySettings(),
          
        );
      }
      
      await _users.doc(uId).set(newUser.toMap());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  // sign in method that takes email and password to authenticate the user
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

  // logout method to sign out the user
  Future<void> logOut() async {
    await _auth.signOut();
  }

  // reset password method that takes an email and sends a password reset email to the user
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

// guest login method that allows users to sign in anonymously without creating an account. This is useful for users who want to try the app without committing to creating an account, and we can still track them in our database as guest users.
Future<String?> guestLogin() async {
    try {
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


  // This method checks the authentication status of the user by first checking if there's a currently authenticated user in Firebase Authentication, and if there is, it then fetches the corresponding user data from Firestore to return a UserModel instance. This is useful for determining if the user is logged in and getting their details when the app starts.
  Future<UserModel?> getUserData(String uId) async {
    try {
      final doc = await _firestore.collection('users').doc(uId).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
// This private method maps FirebaseAuthException codes to user-friendly error messages that can be displayed in the UI. It helps to provide better feedback to the user when authentication errors occur.
  String _mapFirebaseError(FirebaseAuthException e) {
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

  // send email verification method that sends a verification email to the currently authenticated user
  Future<String?> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
      return null; // return null to indicate that the email was sent successfully
    } catch (e) {
      return e.toString(); // return the error message if sending the email failed
    }
  }

  // check email verification status method that checks if the currently authenticated user's email is verified
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      // reload the user to get the latest email verification status from Firebase Authentication, then return whether the email is verified or not
      await user.reload(); 
      return _auth.currentUser!.emailVerified;
    }
    return false;
  }

}