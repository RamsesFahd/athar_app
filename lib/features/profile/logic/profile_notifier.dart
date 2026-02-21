import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/features/profile/logic/profile_repository.dart';
import '../../auth/logic/auth_notifier.dart';

part 'profile_notifier.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  // add phone number method
  Future<void> addPhoneNumber(String phoneNumber) async {
    // 1. Bring the current user data from AuthNotifier
    final authState = ref.read(authNotifierProvider);
    final user = authState.value;
    
    if (user == null) return;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      
      // 2. Update the user data in Firestore with the new phone number
      final error = await repo.updateUserData(user.uId, {
        'phoneNumber': phoneNumber,
      });

      if (error != null) throw error;

      // 3. Invalidate the AuthNotifier to refresh the user data across the app
      ref.invalidate(authNotifierProvider);
    });
  }
  // update profile name method
  Future<void> updateProfileName(String newName) async {
    // 1. Bring the current user data from AuthNotifier
    final authState = ref.read(authNotifierProvider);
    final user = authState.value;
    
    if (user == null) return;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      
      // 2. Update the user data in Firestore with the new full name
      final error = await repo.updateUserData(user.uId, {
        'fullName': newName,
      });

      if (error != null) throw error;

      // 3. Invalidate the AuthNotifier to refresh the user data across the app
      ref.invalidate(authNotifierProvider);
    });
  }
}