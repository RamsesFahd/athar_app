import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/core/models/favorites/favorite_item_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/bookings/logic/booking_repository.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_repository.dart';
import 'package:athar_app/features/cultural_archive/widgets/cultural_item_details.dart';
import 'package:athar_app/features/guide_market/logic/trips_repository.dart';
import 'package:athar_app/features/guide_market/screens/trip_details_screen.dart';
import 'package:athar_app/features/profile/logic/favorites_notifier.dart';
import 'package:athar_app/features/profile/logic/profile_notifier.dart';
import 'package:athar_app/features/profile/widgets/guest_profile_view.dart';
import 'package:athar_app/features/profile/widgets/profile_booking_item.dart';
import 'package:athar_app/features/profile/widgets/profile_settings_tab.dart';
import 'package:athar_app/features/profile/widgets/saved_card.dart';
import 'package:athar_app/features/profile/widgets/tourist_profile.dart';
import 'package:athar_app/features/profile/widgets/tutor_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).value;
      if (user is TutorModel) {
        ref
            .read(profileNotifierProvider.notifier)
            .checkAndExpireCredentials(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (user) {
        if (user == null || user.role == UserRole.guest) {
          return const GuestProfileView();
        }
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(user),
                _buildNavigationTabs(theme, l10n, user),
                Expanded(
                  child: _buildDynamicContentArea(theme, l10n, user),
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text(l10n.commonErrorWithMessage('')))),
    );
  }

  Widget _buildHeader(UserModel user) {
    if (user is TouristModel) return TouristHeader(user: user);
    if (user is TutorModel) return TutorHeader(user: user);
    return const SizedBox.shrink();
  }

  Widget _buildNavigationTabs(
      ThemeData theme, AppLocalizations l10n, UserModel user) {
    final isTutor = user is TutorModel;
    return Container(
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          _tabItem(l10n.profileTabSettings, 0, theme),
          if (!isTutor) _tabItem(l10n.profileTabBooking, 1, theme),
          _tabItem(l10n.profileTabSaved, isTutor ? 1 : 2, theme),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index, ThemeData theme) {
    final isSelected = _activeTabIndex == index;
    final isHighContrast = ref.watch(settingsProvider).highContrast;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTabIndex = index),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : isHighContrast
                          ? theme.colorScheme.onSurface
                          : theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.5),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 2,
              width: isSelected ? 40 : 0,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicContentArea(
      ThemeData theme, AppLocalizations l10n, UserModel user) {
    final isTutor = user is TutorModel;
    final savedTabIndex = isTutor ? 1 : 2;

    if (_activeTabIndex == savedTabIndex) {
      return _buildSavedTab(theme, l10n);
    }

    switch (_activeTabIndex) {
      case 0:
        return ProfileSettingsTab(user: user);
      case 1:
        return _buildBookingTab(theme, l10n, user);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSavedTab(ThemeData theme, AppLocalizations l10n) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final favAsync = ref.watch(favoritesStreamProvider);
    return favAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.commonErrorWithMessage(''))),
      data: (favorites) {
        if (favorites.isEmpty) {
          return Center(
            child: Text(
              l10n.profileNoSavedItems,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final item = favorites[index];
            final optimisticSaved =
                ref.watch(optimisticFavoriteStateProvider(item.itemId));
            final typeText = item.itemType == FavoriteItemType.cultural
                ? l10n.profileFavoriteTypeCultural
                : l10n.trip;
            return SavedCard(
              title: isAr ? item.titleAr : item.titleEn,
              location: isAr ? item.locationAr : item.locationEn,
              typeText: typeText,
              image: item.imageUrl,
              isSaved: optimisticSaved ?? true,
              onToggleSave: () =>
                  ref.read(favoritesNotifierProvider.notifier).toggle(item),
              onTap: () => _openFavoriteItem(context, item),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingTab(
      ThemeData theme, AppLocalizations l10n, UserModel user) {
    return StreamBuilder<List<BookingModel>>(
      stream: ref
          .read(bookingRepositoryProvider)
          .fetchUserBookings(user.uId, user.role),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(l10n.commonErrorWithMessage('')));
        }
        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return Center(
            child: Text(
              l10n.profileNoBookingsYet,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          );
        }
        final sorted = List<BookingModel>.from(bookings);
        if (user is TutorModel) {
          sorted.sort((a, b) {
            if (a.status == b.status) return 0;
            if (a.status == BookingStatus.pending) return -1;
            if (b.status == BookingStatus.pending) return 1;
            return 0;
          });
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: sorted.length,
          itemBuilder: (context, index) =>
              ProfileBookingItem(booking: sorted[index], user: user),
        );
      },
    );
  }

  Future<void> _openFavoriteItem(
      BuildContext context, FavoriteItemModel item) async {
    if (item.itemType == FavoriteItemType.cultural) {
      final cultural = await ref
          .read(culturalRepositoryProvider)
          .fetchItemDetails(item.itemId);
      if (cultural == null || !context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CulturalItemDetails(item: cultural)),
      );
    } else {
      final trip =
          await ref.read(tripsRepositoryProvider).fetchTripById(item.itemId);
      if (trip == null || !context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TripDetailsScreen(trip: trip)),
      );
    }
  }
}
