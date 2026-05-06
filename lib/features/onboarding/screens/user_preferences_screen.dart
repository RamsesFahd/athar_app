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
  _Interest(
    'قصور',
    'https://images.pexels.com/photos/2161467/pexels-photo-2161467.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _Interest(
    'أحياء تاريخية',
    'https://images.pexels.com/photos/356830/pexels-photo-356830.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _Interest(
    'مدائن',
    'https://images.pexels.com/photos/337909/pexels-photo-337909.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _Interest(
    'بحر',
    'https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _Interest(
    'جبال',
    'https://images.pexels.com/photos/417173/pexels-photo-417173.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _Interest(
    'صحراء',
    'https://images.pexels.com/photos/847402/pexels-photo-847402.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _Interest(
    'غابة',
    'https://images.pexels.com/photos/4827/nature-forest-trees-fog.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _Interest(
    'أودية',
    'https://images.pexels.com/photos/210186/pexels-photo-210186.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _Interest(
    'متاحف',
    'https://images.pexels.com/photos/2372978/pexels-photo-2372978.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _Interest(
    'معارض',
    'https://images.pexels.com/photos/1839919/pexels-photo-1839919.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _Interest(
    'أبراج',
    'https://images.pexels.com/photos/466685/pexels-photo-466685.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _Interest(
    'معالم معمارية',
    'https://images.pexels.com/photos/2082103/pexels-photo-2082103.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _Interest(
    'وجهات ترفيهية',
    'https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
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
      final user = await ref.read(authNotifierProvider.future);

      if (user == null) {
        if (mounted) setState(() => _isSaving = false);
        return;
      }

      await saveUserInterests(user.uId, _selected.toList());

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        ref.invalidate(authNotifierProvider);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selected.isNotEmpty && !_isSaving;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _Header(selectedCount: _selected.length),

                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 112),
                    itemCount: _interests.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 13,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.70,
                    ),
                    itemBuilder: (context, index) {
                      final item = _interests[index];
                      final isSelected = _selected.contains(item.tag);

                      return _InterestTile(
                        interest: item,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            isSelected
                                ? _selected.remove(item.tag)
                                : _selected.add(item.tag);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            Positioned(
              left: 22,
              right: 22,
              bottom: 20,
              child: _ContinueButton(
                canContinue: canContinue,
                isSaving: _isSaving,
                selectedCount: _selected.length,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
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

class _InterestTile extends StatelessWidget {
  final _Interest interest;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestTile({
    required this.interest,
    required this.isSelected,
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
                children: [
                  Image.network(
                    interest.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  if (isSelected)
                    Container(
                      color:
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            interest.tag,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final bool canContinue;
  final bool isSaving;
  final int selectedCount;
  final VoidCallback onPressed;

  const _ContinueButton({
    required this.canContinue,
    required this.isSaving,
    required this.selectedCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: canContinue ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                selectedCount == 0 ? 'اختر اهتمام' : 'متابعة',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}