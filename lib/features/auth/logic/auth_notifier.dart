import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/core/services/notification_service.dart';
import 'package:athar_app/features/profile/logic/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/features/auth/logic/auth_repository.dart';
import 'package:athar_app/core/models/user/user_model.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  StreamSubscription<UserModel?>? _userSub;

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
  // Called from build() and every sign-in path so the stream stays active for
  // the current session. Previous subscription is cancelled first to prevent
  // stale updates after logout / re-login with a different account.
  void _startUserStream(String uId) {
    _userSub?.cancel();
    _userSub = ref
        .read(authRepositoryProvider)
        .getUserStream(uId)
        .listen(
          (updated) {
            if (updated != null && state.value?.uId == updated.uId) {
              state = AsyncData(updated);
              _applyAccessibilitySettings(updated.accessibilitySettings);
            }
          },
          onError: (e, st) {
            // Stream may fail during offline or permission changes — do not overwrite auth state.
          },
        );
  }

  Future<UserModel?> _checkAuthStatus() async {
    final repo = ref.read(authRepositoryProvider);
    final firebaseUser = repo.currentUser;
    if (firebaseUser == null) return null;
    final user = await repo.getUserData(firebaseUser.uid);
    if (user != null) _applyAccessibilitySettings(user.accessibilitySettings);
    return user;
  }

  void _applyAccessibilitySettings(AccessibilitySettings s) {
    ref.read(settingsProvider.notifier).loadFrom(
      highContrast: s.highContrast,
      isTtsEnabled: s.textReaderEnabled,
      localeCode: s.languagePreference,
      fontSizeString: s.fontSize,
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
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
    // Cancel the stream before Firebase calls to prevent a final emit from
    // restoring the logged-out user's state.
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
      final error =
          await repo.createGoogleUser(role: role, tutorType: tutorType);
      if (error != null) throw error;
      final user = await _checkAuthStatus();
      if (user != null && user.role != UserRole.guest) {
        _startUserStream(user.uId);
      }
      return user;
    });
  }

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

  Future<void> sendVerificationLink() async {
    await ref.read(authRepositoryProvider).sendEmailVerification();
  }

  Future<void> checkEmailVerificationStatus() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final isVerified = await repo.isEmailVerified();
      if (isVerified) {
        final uId = repo.currentUser?.uid;
        if (uId != null) {
          await repo.updateEmailVerificationInFirestore(uId);
        }
        return await _checkAuthStatus();
      } else {
        throw 'errorEmailNotVerified';
      }
    });
  }

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

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final currentUserId = state.value?.uId;
      if (currentUserId != null) {
        final error = await ref
            .read(authRepositoryProvider)
            .deleteAccount(currentUserId);
        if (error != null) throw Exception(error);
      }
      return null;
    });
  }

  Future<void> updateProfilePicture() async {
    final picker = ImagePicker();
    File? imageFile;

    // Recover any image that was selected before an app interruption (e.g. OS
    // killed the app mid-pick). If nothing was lost, proceed with a fresh pick.
    final LostDataResponse response = await picker.retrieveLostData();
    if (response.file != null) {
      imageFile = File(response.file!.path);
    } else {
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
          await ref
              .read(profileRepositoryProvider)
              .uploadProfileImage(uId, imageFile!);
        }
        return await _checkAuthStatus();
      });
    }
  }
}
