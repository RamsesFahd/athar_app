import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:athar_app/core/services/notification_service.dart';
import 'package:athar_app/features/profile/logic/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/features/auth/logic/auth_repository.dart';
import 'package:athar_app/core/models/user/user_model.dart';

// This line link this file to the generated file Riverpod will create
part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {

  StreamSubscription<UserModel?>? _userSub;

  // this method is called when the provider is first created, we use it to check the authentication status of the user and return their data if they are logged in or null if they are not logged in. The AsyncValue type allows us to represent the loading, error, and data states of this asynchronous operation in a way that can be easily consumed by the UI.
  @override
  FutureOr<UserModel?> build() async {
    ref.onDispose(() => _userSub?.cancel());
    final user = await _checkAuthStatus();
    if (user != null && user.role != UserRole.guest) {
      _startUserStream(user.uId);
    }
    return user;
  }

  // Starts (or replaces) the Firestore real-time listener for the given user.
  // Called from build() for persisted sessions and from every sign-in / sign-up
  // path so the stream is active for users who authenticate during the current
  // app session. Previous subscription is cancelled before creating a new one.
  void _startUserStream(String uId) {
    _userSub?.cancel();
    _userSub = ref
        .read(authRepositoryProvider)
        .getUserStream(uId)
        .listen(
          (updated) {
            debugPrint('[AuthNotifier STREAM] fired: phoneNumber=${updated?.phoneNumber}, phoneVerified=${updated?.phoneVerified}, stateUid=${state.value?.uId}, updatedUid=${updated?.uId}');
            // uId guard: prevents stale updates after logout / re-login with a different account.
            if (updated != null && state.value?.uId == updated.uId) {
              state = AsyncData(updated);
              debugPrint('[AuthNotifier STREAM] state updated');
            } else {
              debugPrint('[AuthNotifier STREAM] guard blocked — stateUid=${state.value?.uId}, updatedUid=${updated?.uId}');
            }
          },
          onError: (e, st) {
            // Log silently — stream may fail during offline or permission changes.
            // Do NOT crash or overwrite auth state here.
            debugPrint('[AuthNotifier] getUserStream error: $e');
          },
        );
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
      if (error != null) throw error;

      final user = await _checkAuthStatus();
      if (user != null) {
        await NotificationService.instance.registerToken(user.uId);
        if (user.role != UserRole.guest) _startUserStream(user.uId);
      }
      return user;
    });
  }

  // Sign up method that takes email, password, full name, and role to create a new user account. It sets the state to loading while the sign up process is happening, and then uses AsyncValue.guard to handle the asynchronous operation and update the state accordingly based on whether the sign up was successful or if it threw an error.
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    TutorType? tutorType,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);

      final error = await repo.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        tutorType: tutorType,
      );

      if (error != null) throw error;

      final user = await _checkAuthStatus();
      if (user != null && user.role != UserRole.guest) {
        _startUserStream(user.uId);
      }
      return user;
    });
  }

  Future<void> logout() async {
    // Capture userId before state changes, cancel stream before any Firebase
    // calls to prevent a final stream emit from restoring the logged-out user.
    final userId = state.value?.uId;
    _userSub?.cancel();
    _userSub = null;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (userId != null) {
        await NotificationService.instance.removeToken(userId);
      }
      await ref.read(authRepositoryProvider).logOut();
      return null;
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final error = await repo.signInWithGoogle();
      if (error != null) throw error;

      final user = await _checkAuthStatus();
      if (user == null && repo.currentUser != null) throw 'needsRoleSelection';
      if (user != null) {
        await NotificationService.instance.registerToken(user.uId);
        if (user.role != UserRole.guest) _startUserStream(user.uId);
      }
      return user;
    });
  }

  Future<void> createGoogleUser({
    required UserRole role,
    TutorType? tutorType,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final error = await repo.createGoogleUser(role: role, tutorType: tutorType);
      if (error != null) throw error;
      final user = await _checkAuthStatus();
      if (user != null && user.role != UserRole.guest) {
        _startUserStream(user.uId);
      }
      return user;
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

  Future<bool> resetPassword({required String email}) async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final error = await repo.resetPassword(email);
      return error == null;
    } catch (_) {
      return false;
    }
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
        final uId = repo.currentUser?.uid;

        if (uId != null) {
          // Before returning the updated user data, we call the method to update the email verification status in Firestore. This ensures that the user's document in Firestore reflects that their email has been verified, which can be important for controlling access to certain features or content in the app based on email verification status.
          await repo.updateEmailVerificationInFirestore(uId);
        }

        //
        return await _checkAuthStatus();
      } else {
        throw 'errorEmailNotVerified';
      }
    });
  }


  // This method allows a tutor to submit their verification information (specifically their license number) to the system. It updates the user's document in Firestore with the provided license number and sets their verification status to "pending". After updating the Firestore document, it refreshes the authentication status to reflect any changes in the user's data, such as their verification status. This is useful for tutors who need to verify their credentials before gaining access to certain features or being listed as verified tutors in the app.
  Future<void> submitTutorVerification(String licence) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {

      final currentUserId = state.value?.uId;

      if (currentUserId != null) {
        await ref.read(profileRepositoryProvider).submitTutorCredentials(
          uId: currentUserId,
          credentialData: {'licenceNumber': licence},
        );
      }
      return await _checkAuthStatus();
    });
  }

// This method allows the user to update their profile picture by selecting a new image from their device's gallery. It uses the image_picker package to let the user choose an image, and then uploads that image to Firebase Storage using the ProfileRepository. After successfully uploading the new profile picture and updating the user's document in Firestore with the new profile image URL, it refreshes the authentication status to get the updated user data, which will include the new profile picture URL. This ensures that the UI will reflect the new profile picture immediately after it's uploaded and updated in Firestore.

Future<void> deleteAccount() async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    final currentUserId = state.value?.uId;
    if (currentUserId != null) {
      final error =
          await ref.read(authRepositoryProvider).deleteAccount(currentUserId);
      if (error != null) throw Exception(error);
    }
    return null;
  });
}

Future<void> updateProfilePicture() async {
  final picker = ImagePicker();
  File? imageFile;

  // 1. first we check if there's any lost data from a previous image picking operation that might have been interrupted (e.g., the app was killed while the user was picking an image). If there is lost data, we try to retrieve it and use it as the selected image. This helps to prevent losing the user's selected image in case of an interruption.
  final LostDataResponse response = await picker.retrieveLostData();
  if (response.file != null) {
    imageFile = File(response.file!.path);
  } else {
    // 2. if there's no lost data, we proceed with the normal image picking process, allowing the user to select a new image from their gallery. We also set the image quality to 50 to reduce the file size and help prevent memory issues that can occur with large images.
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
    }
  }

  if (imageFile != null) {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final uId = state.value?.uId;
      if (uId != null) {
        // 3. uploaf to Firebase Storage and update Firestore
        await ref.read(profileRepositoryProvider).uploadProfileImage(uId, imageFile!);
      }
      return await _checkAuthStatus();
    });
  }
}
}
