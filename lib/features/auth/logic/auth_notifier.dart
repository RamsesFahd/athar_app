import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/features/auth/logic/auth_repository.dart';
import 'package:athar_app/core/models/user/user_model.dart';

// This line link this file to the generated file Riverpod will create
part 'auth_notifier.g.dart'; 

@riverpod
class AuthNotifier extends _$AuthNotifier {
  
  // this method is called when the provider is first created, we use it to check the authentication status of the user and return their data if they are logged in or null if they are not logged in. The AsyncValue type allows us to represent the loading, error, and data states of this asynchronous operation in a way that can be easily consumed by the UI.
  @override
  FutureOr<UserModel?> build() async {
    return _checkAuthStatus();
  }

  // This private method checks the authentication status of the user by first checking if there's a currently authenticated user in Firebase Authentication, and if there is, it then fetches the corresponding user data from Firestore to return a UserModel instance. This is useful for determining if the user is logged in and getting their details when the app starts.

  Future<UserModel?> _checkAuthStatus() async {
    final repo = ref.read(authRepositoryProvider);
    final firebaseUser = repo.currentUser;

    if (firebaseUser == null) return null;

    // ✨ التعديل: نجلب البيانات دائماً ولا نرجع null هنا
    // الواجهة هي من ستفحص user.emailVerified وتقرر المسار
    return await repo.getUserData(firebaseUser.uid);
  }

  // sign in methode that takes email and password to authenticate the user
  Future<void> signIn({required String email, required String password}) async {
    // we set the state to AsyncLoading
    state = const AsyncLoading();

    // AsyncValue.guard is a helper method that runs the provided asynchronous function and automatically updates the state to AsyncData if it succeeds or AsyncError if it throws an error. This way we don't have to manually catch errors and set the state in both success and error cases.
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final error = await repo.signIn(email: email, password: password);
      
      if (error != null) throw error; // throw the error if sign in failed

      return await _checkAuthStatus(); // return the user data if sign in is successful
    });
  }

  // Sign up method that takes email, password, full name, and role to create a new user account. It sets the state to loading while the sign up process is happening, and then uses AsyncValue.guard to handle the asynchronous operation and update the state accordingly based on whether the sign up was successful or if it threw an error.
  Future<void> signUp({
    required String email, 
    required String password, 
    required String fullName,
    required UserRole role,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      

      final error = await repo.signUp(
        email: email, 
        password: password, 
        fullName: fullName,
        role: role, 
      );

      if (error != null) throw error;

      return await _checkAuthStatus(); 
    });
  }
  // Logout method that signs the user out and sets the state to null (not authenticated)
  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).logOut();
      return null; // return null to indicate that the user is now logged out and there's no authenticated user data
    });
  }

  // Guest login method that allows users to continue without creating an account. It creates a temporary anonymous user in Firebase Authentication and returns their data as a UserModel instance. This is useful for allowing users to explore the app without the friction of signing up, while still providing them with a unique identifier and some level of personalization.
  Future<void> guestLogin() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final error = await repo.guestLogin();

      if (error != null) throw error;

      return await _checkAuthStatus();
    });
  }

  // reset password method that takes an email address and sends a password reset email to the user. This allows users who have forgotten their password to regain access to their account by following the instructions in the email.
  Future<void> resetPassword({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final error = await repo.resetPassword(email);

      if (error != null) throw error;

      return state.value; // return the current user data without changing it, since resetting the password doesn't affect the authentication status
    });
  }

  // send verfication link method
  Future<void> sendVerificationLink() async {
    // we don't need to change the state here because sending the verification email doesn't affect the authentication status
    final repo = ref.read(authRepositoryProvider);
    await repo.sendEmailVerification();
  }

  // checking email verification status method that checks if the user's email is verified. If it is, it refreshes the user data to reflect any changes. If it's not, it throws an error that can be caught and displayed in the UI
  Future<void> checkEmailVerificationStatus() async {
    state = const AsyncLoading(); // we set the state to loading while we check the verification status
    
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final isVerified = await repo.isEmailVerified();

      if (isVerified) {
        // if the email is verified, we refresh the user data to reflect any changes
        return await _checkAuthStatus();
      } else {
        // if the email is not verified, we throw an error that can be caught and displayed in the UI
        throw 'errorEmailNotVerified';
      }
    });
  }
}