import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/favorites/favorite_item_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/profile/logic/favorites_repository.dart';

part 'favorites_notifier.g.dart';

/// Live stream of the current user's saved items. Returns [] for guests.
@riverpod
Stream<List<FavoriteItemModel>> favoritesStream(Ref ref) {
  final user = ref.watch(authNotifierProvider).value;
  if (user == null || user.role == UserRole.guest) {
    return Stream.value([]);
  }
  return ref.watch(favoritesRepositoryProvider).watchFavorites(user.uId);
}

/// Family provider: is a specific itemId currently saved by the current user?
@riverpod
Future<bool> isFavorite(Ref ref, String itemId) async {
  final user = ref.watch(authNotifierProvider).value;
  if (user == null || user.role == UserRole.guest) return false;
  return ref.watch(favoritesRepositoryProvider).isFavorite(user.uId, itemId);
}

/// Toggle a favorite item (add or remove). Guards against unauthenticated users.
@riverpod
class FavoritesNotifier extends _$FavoritesNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> toggle(FavoriteItemModel item) async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null || user.role == UserRole.guest) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(favoritesRepositoryProvider)
          .toggleFavorite(user.uId, item);
      ref.invalidate(isFavoriteProvider(item.itemId));
    });
  }
}
