import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/core/navigation/app_routes.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/onboarding/logic/preferences_notifier.dart';

class _Interest {
  final String tag;
  final String imageUrl;
  const _Interest(this.tag, this.imageUrl);
}

const _interests = [
  _Interest('قصور', 'https://images.pexels.com/photos/3889742/pexels-photo-3889742.jpeg'),
  _Interest('أحياء تاريخية', 'https://images.pexels.com/photos/3225531/pexels-photo-3225531.jpeg'),
  _Interest('مدائن', 'https://images.pexels.com/photos/5007432/pexels-photo-5007432.jpeg'),
  _Interest('بحر', 'https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg'),
  _Interest('جبال', 'https://images.pexels.com/photos/1001435/pexels-photo-1001435.jpeg'),
  _Interest('صحراء', 'https://images.pexels.com/photos/1270184/pexels-photo-1270184.jpeg'),
  _Interest('غابة', 'https://images.pexels.com/photos/158251/forest-the-dark-woods-tree-158251.jpeg'),
  _Interest('أودية', 'https://images.pexels.com/photos/1166209/pexels-photo-1166209.jpeg'),
  _Interest('متاحف', 'https://images.pexels.com/photos/2034335/pexels-photo-2034335.jpeg'),
  _Interest('معارض', 'https://images.pexels.com/photos/1839919/pexels-photo-1839919.jpeg'),
  _Interest('أبراج', 'https://images.pexels.com/photos/325185/pexels-photo-325185.jpeg'),
  _Interest('معالم معمارية', 'https://images.pexels.com/photos/1209978/pexels-photo-1209978.jpeg'),
  _Interest('وجهات ترفيهية', 'https://images.pexels.com/photos/3184419/pexels-photo-3184419.jpeg'),
];

class UserPreferencesScreen extends ConsumerStatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  ConsumerState<UserPreferencesScreen> createState() =>
      _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends ConsumerState<UserPreferencesScreen> {
  final Set<String> _selected = {};
  bool _isSaving = false;

  Future<void> _save() async {
    if (_selected.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      // .future waits for the provider to finish loading instead of returning null
      final user = await ref.read(authNotifierProvider.future);
      if (user == null) {
        if (mounted) setState(() => _isSaving = false);
        return;
      }

      await saveUserInterests(user.uId, _selected.toList());

      if (mounted) {
        // Navigate first, then refresh auth so home gets updated interests
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        ref.invalidate(authNotifierProvider);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canContinue = _selected.isNotEmpty && !_isSaving;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ما هي اهتماماتك؟',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اختر ما يثير اهتمامك لنقترح لك أفضل الوجهات',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final item = _interests[index];
                  final isSelected = _selected.contains(item.tag);
                  return _InterestCard(
                    interest: item,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selected.remove(item.tag);
                        } else {
                          _selected.add(item.tag);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: canContinue ? _save : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text(
                          'متابعة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InterestCard extends StatelessWidget {
  final _Interest interest;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestCard({
    required this.interest,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              interest.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported_outlined,
                    color: Colors.grey),
              ),
            ),
            // bottom gradient + label
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                interest.tag,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(blurRadius: 4, color: Colors.black54),
                  ],
                ),
              ),
            ),
            // selected checkmark
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check,
                      size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
