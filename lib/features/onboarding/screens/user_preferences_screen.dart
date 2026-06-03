import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/navigation/app_routes.dart';
import 'package:athar_app/core/utils/taxonomy_repository.dart';
import 'package:athar_app/core/widgets/interest_image_widget.dart';
import 'package:athar_app/core/models/user/user_model.dart';
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
    final authState = ref.watch(authNotifierProvider);
    final user = authState.valueOrNull;
    final taxonomyAsync = ref.watch(taxonomyProvider);
    final prefsState = ref.watch(preferencesNotifierProvider);
    final theme = Theme.of(context);
    final isAr = Directionality.of(context) == TextDirection.rtl;

    if (authState.isLoading && user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null || user.role == UserRole.guest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(
          context,
          user == null ? AppRoutes.signIn : AppRoutes.home,
        );
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (widget.isEditMode)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 12),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                _Header(selectedCount: prefsState.selectedIds.length),
                Expanded(
                  child: taxonomyAsync.when(
                    data: (interests) => _InterestsGrid(interests: interests),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => _ErrorView(
                      message: isAr
                          ? 'تعذّر تحميل الاهتمامات. يرجى المحاولة مرة أخرى.'
                          : 'We couldn’t load your interests. Please try again.',
                      onRetry: () => ref.invalidate(taxonomyProvider),
                    ),
                  ),
                ),
              ],
            ),
            // Inline error banner shown when the Firestore save call fails.
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
      // The AuthNotifier stream picks up the Firestore change automatically.
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
              child: Icon(Icons.interests, color: theme.colorScheme.onPrimary),
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  width: isSelected ? 3 : 1.5,
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.35)
                        : Colors.transparent,
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isSelected
                          ? Icon(
                              Icons.check_circle,
                              key: const ValueKey('checked'),
                              color: Colors.white,
                              size: 24,
                              shadows: const [
                                Shadow(color: Colors.black54, blurRadius: 6),
                              ],
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('unchecked'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium?.color,
            ),
            child: Text(
              interest.label(locale),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

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
            ? CircularProgressIndicator(color: theme.colorScheme.onPrimary)
            : Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }
}

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
          Icon(Icons.error_outline,
              size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
