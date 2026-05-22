import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';
import 'package:athar_app/features/admin/screens/add_attraction_screen.dart';
import 'package:athar_app/features/attractions/logic/attractions_repository.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class AttractionsAdminScreen extends ConsumerStatefulWidget {
  const AttractionsAdminScreen({super.key});

  @override
  ConsumerState<AttractionsAdminScreen> createState() =>
      _AttractionsAdminScreenState();
}

class _AttractionsAdminScreenState
    extends ConsumerState<AttractionsAdminScreen> {


  @override
  Widget build(BuildContext context) {
    final attractionsAsync = ref.watch(attractionsStreamProvider);
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        attractionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l10n.commonErrorWithMessage(''))),
          data: (attractions) {
            if (attractions.isEmpty) {
              return Center(child: Text(l10n.adminNoAttractions));
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: attractions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _AttractionAdminTile(attraction: attractions[index]),
            );
          },
        ),

        Positioned(
          bottom: 24,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'add_attraction',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddAttractionScreen()),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: Text(l10n.adminAddAttraction),
          ),
        ),
      ],
    );
  }
}

class _AttractionAdminTile extends ConsumerWidget {
  final AttractionModel attraction;
  const _AttractionAdminTile({required this.attraction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(14)),
            child: Image.network(
              attraction.mainImage,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attraction.getName(false),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${attraction.category} • ${attraction.getCity(false)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined,
                    size: 20, color: theme.colorScheme.primary),
                tooltip: l10n.adminEdit,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddAttractionScreen(editAttraction: attraction),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.red),
                tooltip: l10n.adminDelete,
                onPressed: () => _confirmDelete(context, ref, attraction),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, AttractionModel attraction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).adminDeleteAttraction),
        content: Text(AppLocalizations.of(context)
            .adminDeleteAttractionConfirm(attraction.getName(false))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context).adminCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context).adminDelete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(adminRepositoryProvider)
            .deleteAttraction(attraction.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context).adminAttractionDeleted),
                backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).commonErrorWithMessage(''))),
          );
        }
      }
    }
  }
}
