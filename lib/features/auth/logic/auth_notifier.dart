import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/features/auth/logic/auth_repository.dart';
import 'package:athar_app/core/models/user_model.dart';

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
    final repo = ref.read(authRepositoryProvider);//get the auth repository instance
    final firebaseUser = repo.currentUser; // is there a currently authenticated user in Firebase Authentication?

    if (firebaseUser == null) return null; //return null if there's no authenticated user

    
    return await repo.getUserData(firebaseUser.uid);// get the user data from Firestore and return it as a UserModel instance
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

  // Sign up method that takes email, password, and full name to create a new user account
  Future<void> signUp({
    required String email, 
    required String password, 
    required String fullName
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final error = await repo.signUp(
        email: email, 
        password: password, 
        fullName: fullName
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
}