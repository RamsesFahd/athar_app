import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';
import 'package:athar_app/features/admin/screens/add_cultural_content_screen.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

final _allCulturalItemsProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getAllCulturalItems();
});

class CulturalArchiveAdminScreen extends ConsumerWidget {
  const CulturalArchiveAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(_allCulturalItemsProvider);
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        itemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l10n.commonErrorWithMessage(e.toString()))),
          data: (rawItems) {
            final items = rawItems
                .map((m) => CulturalItemModel.fromMap(m, m['id'] as String))
                .toList();

            if (items.isEmpty) {
              return Center(
                child: Text(l10n.adminNoCulturalItems),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _ArchiveItemTile(item: items[index]),
            );
          },
        ),
        Positioned(
          bottom: 24,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddCulturalContentScreen()),
            ).then((_) => ref.invalidate(_allCulturalItemsProvider)),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: Text(l10n.adminAddItem),
          ),
        ),
      ],
    );
  }
}

class _ArchiveItemTile extends ConsumerWidget {
  final CulturalItemModel item;
  const _ArchiveItemTile({required this.item});

  String _categoryLabel(String categoryId, AppLocalizations l10n) {
    switch (categoryId) {
      case 'food':
      case 'traditional_food':
        return l10n.cat_food;
      case 'craft':
      case 'handicraft':
        return l10n.cat_craft;
      case 'dance':
        return l10n.cat_dance;
      case 'architecture':
        return l10n.cat_architecture;
      case 'music':
        return l10n.cat_music;
      case 'clothing':
      case 'traditional_clothing':
        return l10n.cat_clothing;
      default:
        return categoryId;
    }
  }

  String _arabicTitle(CulturalItemModel item) {
    return item.titleAr.trim().isNotEmpty ? item.titleAr : item.titleEn;
  }

  String _arabicRegion(CulturalItemModel item) {
    return item.regionAr.trim().isNotEmpty ? item.regionAr : item.regionEn;
  }

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
              item.imageUrl,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _arabicTitle(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (item.isContribution)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.people_alt_outlined,
                            size: 14,
                            color: theme.colorScheme.tertiary),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_categoryLabel(item.categoryId, l10n)} • ${_arabicRegion(item)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.6)),
                ),
                if (item.isContribution && item.contributorName != null)
                  Text(
                    l10n.adminByContributor(item.contributorName!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
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
                        AddCulturalContentScreen(editItem: item),
                  ),
                ).then((_) =>
                    ref.invalidate(_allCulturalItemsProvider)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.red),
                tooltip: l10n.adminDelete,
                onPressed: () =>
                    _confirmDelete(context, ref, item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, CulturalItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).adminDeleteItem),
        content: Text(AppLocalizations.of(context)
            .adminDeleteItemConfirm(_arabicTitle(item))),
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
            .deleteCulturalItem(item.id, item.imageUrl);
        ref.invalidate(_allCulturalItemsProvider);
        ref.invalidate(culturalNotifierProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context).adminItemDeleted),
                backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).commonErrorWithMessage(e.toString()))),
          );
        }
      }
    }
  }
}
