import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/screens/add_event_screen.dart';
import 'package:athar_app/features/admin/screens/attractions_admin_screen.dart';
import 'package:athar_app/features/events/logic/events_repository.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

/// 0 = Events (فعاليات), 1 = Attractions (معالم)
final eventsAttractionsTabIndexProvider = StateProvider<int>((ref) => 0);

class EventsAttractionsAdminScreen extends ConsumerWidget {
  const EventsAttractionsAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 1,
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              dividerColor: Colors.transparent,
              onTap: (i) =>
                  ref.read(eventsAttractionsTabIndexProvider.notifier).state =
                      i,
              tabs: [
                Tab(text: l10n.homeEventsSectionTitle),
                Tab(text: l10n.attractionsTitle),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _EventsAdminTab(),
                AttractionsAdminScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsAdminTab extends ConsumerWidget {
  const _EventsAdminTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final eventsAsync = ref.watch(eventsStreamProvider);

    return Stack(
      children: [
        eventsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text(l10n.commonErrorWithMessage(e.toString()))),
          data: (events) {
            if (events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration_outlined,
                        size: 72,
                        color: AppColors.primary.withValues(alpha: 0.15)),
                    const SizedBox(height: 12),
                    Text(
                      l10n.adminNoEvents,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _EventAdminTile(event: events[index]),
            );
          },
        ),
        Positioned(
          bottom: 24,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'add_event',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEventScreen()),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: Text(l10n.adminAddEvent),
          ),
        ),
      ],
    );
  }
}

class _EventAdminTile extends StatelessWidget {
  final EventModel event;
  const _EventAdminTile({required this.event});

  void _confirmDelete(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final name = isAr ? event.titleAr : event.titleEn;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(isAr ? 'حذف الفعالية' : 'Delete Event'),
        content: Text(
          isAr
              ? 'هل أنت متأكد من حذف "$name"؟ لا يمكن التراجع عن هذا الإجراء.'
              : 'Delete "$name"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              // Capture messenger before async gap in case the tile unmounts.
              final messenger = ScaffoldMessenger.of(context);
              try {
                await deleteEvent(event.id);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(isAr ? 'تم حذف الفعالية' : 'Event deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(isAr ? 'خطأ: $e' : 'Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(isAr ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditEventSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final dateFormat = DateFormat('yyyy-MM-dd');
    final startDate = dateFormat.format(event.eventDate);
    final endDate =
        event.endDate != null ? dateFormat.format(event.endDate!) : null;
    final dateText = endDate == null ? startDate : '$startDate - $endDate';
    final timeText = event.getTime(isAr);
    final regionText = event.getRegion(isAr);
    final typeText = isAr ? event.eventType.labelAr : event.eventType.labelEn;

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
              event.imageUrl,
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
                  event.getTitle(isAr),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '$typeText • $regionText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeText.isEmpty ? dateText : '$dateText • $timeText',
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
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onSelected: (value) {
              if (value == 'edit') _showEditSheet(context);
              if (value == 'delete') _confirmDelete(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 20),
                    const SizedBox(width: 10),
                    Text(isAr ? 'تعديل' : 'Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline,
                        size: 20, color: Colors.red),
                    const SizedBox(width: 10),
                    Text(
                      isAr ? 'حذف' : 'Delete',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditEventSheet extends StatefulWidget {
  final EventModel event;
  const _EditEventSheet({required this.event});

  @override
  State<_EditEventSheet> createState() => _EditEventSheetState();
}

class _EditEventSheetState extends State<_EditEventSheet> {
  late final TextEditingController _titleArCtrl;
  late final TextEditingController _titleEnCtrl;
  late final TextEditingController _descArCtrl;
  late final TextEditingController _descEnCtrl;
  DateTime? _endDate;
  late bool _isFree;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleArCtrl = TextEditingController(text: widget.event.titleAr);
    _titleEnCtrl = TextEditingController(text: widget.event.titleEn);
    _descArCtrl = TextEditingController(text: widget.event.descriptionAr);
    _descEnCtrl = TextEditingController(text: widget.event.descriptionEn);
    _endDate = widget.event.endDate;
    _isFree = widget.event.isFree;
  }

  @override
  void dispose() {
    _titleArCtrl.dispose();
    _titleEnCtrl.dispose();
    _descArCtrl.dispose();
    _descEnCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? widget.event.eventDate,
      firstDate: widget.event.eventDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _save() async {
    if (_titleArCtrl.text.trim().isEmpty || _titleEnCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('العنوان مطلوب / Title is required')),
      );
      return;
    }

    setState(() => _isLoading = true);
    // Capture before async gaps so they remain valid after pop/unmount.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await updateEventFields(widget.event.id, {
        'titleAr': _titleArCtrl.text.trim(),
        'titleEn': _titleEnCtrl.text.trim(),
        'descriptionAr': _descArCtrl.text.trim(),
        'descriptionEn': _descEnCtrl.text.trim(),
        'endDate':
            _endDate != null ? Timestamp.fromDate(_endDate!) : null,
        'isFree': _isFree,
      });
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('تم التحديث / Updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('خطأ / Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final dateFormat = DateFormat('yyyy-MM-dd');

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    isAr ? 'تعديل الفعالية' : 'Edit Event',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 32,
                ),
                children: [
                  _label(context, isAr ? 'العنوان بالعربية' : 'Title (Arabic)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleArCtrl,
                    textAlign: TextAlign.right,
                    decoration: _deco(context, 'مثال: مهرجان الصيف'),
                  ),
                  const SizedBox(height: 16),
                  _label(context, isAr ? 'العنوان بالإنجليزية' : 'Title (English)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleEnCtrl,
                    decoration: _deco(context, 'e.g. Summer Festival'),
                  ),
                  const SizedBox(height: 16),
                  _label(context,
                      isAr ? 'الوصف بالعربية' : 'Description (Arabic)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descArCtrl,
                    maxLines: 3,
                    textAlign: TextAlign.right,
                    decoration: _deco(context, ''),
                  ),
                  const SizedBox(height: 16),
                  _label(context,
                      isAr ? 'الوصف بالإنجليزية' : 'Description (English)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descEnCtrl,
                    maxLines: 3,
                    decoration: _deco(context, ''),
                  ),
                  const SizedBox(height: 20),
                  _label(context,
                      isAr ? 'تاريخ الانتهاء' : 'End Date'),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _pickEndDate,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(
                            _endDate != null
                                ? dateFormat.format(_endDate!)
                                : (isAr ? 'اختر تاريخاً' : 'Choose a date'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _endDate != null
                                  ? null
                                  : theme.hintColor,
                            ),
                          ),
                          if (_endDate != null) ...[
                            const Spacer(),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _endDate = null),
                              child: Icon(Icons.clear,
                                  size: 18, color: theme.hintColor),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAr ? 'دخول مجاني' : 'Free Entry',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Switch(
                        value: _isFree,
                        activeThumbColor: AppColors.primary,
                        onChanged: (v) => setState(() => _isFree = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isAr ? 'حفظ التغييرات' : 'Save Changes',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(fontWeight: FontWeight.w600),
      );

  InputDecoration _deco(BuildContext context, String hint) => InputDecoration(
        hintText: hint.isEmpty ? null : hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
}
