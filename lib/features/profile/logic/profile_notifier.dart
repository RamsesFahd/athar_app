import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/features/profile/logic/profile_repository.dart';
import '../../auth/logic/auth_notifier.dart';

part 'profile_notifier.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  String? _verificationId;
  int? _resendToken;

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> updateProfileName(String newName) async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final error = await ref.read(profileRepositoryProvider).updateUserData(
        user.uId,
        {'fullName': newName},
      );
      if (error != null) throw Exception(error);
      ref.invalidate(authNotifierProvider);
    });
  }

  // Step 1: Send OTP — calls onCodeSent() when SMS is dispatched, onError(msg) on failure.
  void sendPhoneOtp({
    required String phoneNumber,
    required void Function() onCodeSent,
    required void Function(String error) onError,
  }) {
    state = const AsyncLoading();

    ref.read(profileRepositoryProvider).sendPhoneOtp(
      phoneNumber: phoneNumber,
      resendToken: _resendToken,
      onCodeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        state = const AsyncData(null);
        onCodeSent();
      },
      onError: (error) {
        state = AsyncError(error, StackTrace.current);
        onError(error);
      },
      // Android auto-verification: credential is already complete — pass it directly.
      onAutoVerified: (credential) => _applyCredential(credential, phoneNumber),
    );
  }

  // Step 2: Verify the OTP code the user typed.
  Future<void> verifyPhoneOtp({
    required String smsCode,
    required String phoneNumber,
  }) async {
    if (_verificationId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final error = await ref.read(profileRepositoryProvider).confirmPhoneOtp(
        uId: ref.read(authNotifierProvider).value!.uId,
        verificationId: _verificationId!,
        smsCode: smsCode,
        phoneNumber: phoneNumber,
      );
      if (error != null) throw Exception(error);
      ref.invalidate(authNotifierProvider);
    });
  }

  // Android auto-verification: uses the credential object directly, not verificationId/smsCode.
  Future<void> _applyCredential(
      PhoneAuthCredential credential, String phoneNumber) async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final error = await ref
          .read(profileRepositoryProvider)
          .applyAutoVerifiedCredential(
            uId: user.uId,
            credential: credential,
            phoneNumber: phoneNumber,
          );
      if (error != null) throw Exception(error);
      ref.invalidate(authNotifierProvider);
    });
  }
}