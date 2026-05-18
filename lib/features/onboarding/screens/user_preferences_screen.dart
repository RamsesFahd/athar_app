// ============================================================================
// Athar — User Preferences Screen (Refactored)
// ----------------------------------------------------------------------------
// Location: lib/features/onboarding/view/user_preferences_screen.dart
//
// What changed from the previous version:
//   ❌ Removed: hardcoded `const _interests = [...]` list
//   ❌ Removed: storing Arabic labels as IDs (broke i18n + recommendations)
//   ❌ Removed: direct Image.network calls (no caching, no fallback)
//
//   ✅ Added: reads interests from Firestore via taxonomyProvider
//   ✅ Added: uses InterestImage widget (Firebase Storage + cache)
//   ✅ Added: stores English IDs (e.g., 'heritage_sites') in Firestore
//   ✅ Added: bilingual labels (Arabic by default, English when locale is en)
//   ✅ Added: uses PreferencesNotifier for state management
//   ✅ Added: graceful loading and error states
//   ✅ Added: isEditMode param for editing interests from profile screen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/navigation/app_routes.dart';
import 'package:athar_app/core/utils/taxonomy_repository.dart';
import 'package:athar_app/core/widgets/interest_image_widget.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/onboarding/logic/preferences_notifier.dart';

class UserPreferencesScreen extends ConsumerStatefulWidget {
  /// When true, the screen operates in edit mode:
  /// pre-fills selection, shows "حفظ التغييرات", and pops on success.
  final bool isEditMode;

  /// The user's current interests — used to pre-fill selection in edit mode.
  final List<String> initialInterests;

  const UserPreferencesScreen({
    super.key,
    this.isEditMode = false,
    this.initialInterests = const [],
  });

  @override
  ConsumerState<UserPreferencesScreen> createState() =>
      _UserPreferencesScreenState();
}

class _UserPreferencesScreenState
    extends ConsumerState<UserPreferencesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.isEditMode && widget.initialInterests.isNotEmpty) {
      // Pre-fill the selection after the first frame so the provider is ready.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(preferencesNotifierProvider.notifier)
            .initializeWith(widget.initialInterests);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taxonomyAsync = ref.watch(taxonomyProvider);
    final prefsState = ref.watch(preferencesNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _Header(selectedCount: prefsState.selectedIds.length),
                Expanded(
                  child: taxonomyAsync.when(
                    data: (interests) => _InterestsGrid(interests: interests),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => _ErrorView(
                      message: 'تعذر تحميل الاهتمامات',
                      onRetry: () => ref.invalidate(taxonomyProvider),
                    ),
                  ),
                ),
              ],
            ),
            // Show error snackbar reactively when notifier emits one
            if (prefsState.errorMessage != null)
              Positioned(
                left: 22,
                right: 22,
                bottom: 90,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      prefsState.errorMessage!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 20,
              child: _ContinueButton(
                isEditMode: widget.isEditMode,
                onPressed: () => _handleSave(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    final user = await ref.read(authNotifierProvider.future);
    if (user == null) return;

    final success = await ref
        .read(preferencesNotifierProvider.notifier)
        .save(user.uId);

    if (!context.mounted) return;

    if (success) {
      ref.invalidate(authNotifierProvider);

      if (widget.isEditMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ اهتماماتك بنجاح'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }
}

// ============================================================================
// Header
// ============================================================================

class _Header extends StatelessWidget {
  final int selectedCount;
  const _Header({required this.selectedCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.interests, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'اختيار الاهتمامات',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Text(
              '$selectedCount',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Grid
// ============================================================================

class _InterestsGrid extends ConsumerWidget {
  final List<TaxonomyInterest> interests;
  const _InterestsGrid({required this.interests});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(preferencesNotifierProvider).selectedIds;
    final locale = Localizations.localeOf(context).languageCode;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 112),
      itemCount: interests.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 13,
        mainAxisSpacing: 18,
        childAspectRatio: 0.70,
      ),
      itemBuilder: (context, index) {
        final interest = interests[index];
        final isSelected = selectedIds.contains(interest.id);

        return _InterestTile(
          interest: interest,
          isSelected: isSelected,
          locale: locale,
          onTap: () => ref
              .read(preferencesNotifierProvider.notifier)
              .toggle(interest.id),
        );
      },
    );
  }
}

// ============================================================================
// Tile
// ============================================================================

class _InterestTile extends StatelessWidget {
  final TaxonomyInterest interest;
  final bool isSelected;
  final String locale;
  final VoidCallback onTap;

  const _InterestTile({
    required this.interest,
    required this.isSelected,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  InterestImage(
                    storagePath: interest.imageUrl,
                    borderRadius: BorderRadius.zero,
                  ),
                  if (isSelected)
                    Container(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            interest.label(locale),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Continue / Save Button
// ============================================================================

class _ContinueButton extends ConsumerWidget {
  final bool isEditMode;
  final VoidCallback onPressed;

  const _ContinueButton({
    required this.isEditMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefsState = ref.watch(preferencesNotifierProvider);

    String label;
    if (prefsState.selectedIds.isEmpty) {
      label = 'اختر اهتمام';
    } else if (isEditMode) {
      label = 'حفظ التغييرات';
    } else {
      label = 'متابعة';
    }

    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: prefsState.canContinue ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: prefsState.isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

// ============================================================================
// Error View
// ============================================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
