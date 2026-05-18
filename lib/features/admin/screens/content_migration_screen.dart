// ============================================================================
// NEW SCREEN: Add to lib/features/admin/screens/content_migration_screen.dart
// ----------------------------------------------------------------------------
// One-time admin screen to migrate all existing content (98 docs) to have
// interestIds + embeddings. Run it once after deploying the new Cloud Function.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:convert';

class ContentMigrationScreen extends ConsumerStatefulWidget {
  const ContentMigrationScreen({super.key});

  @override
  ConsumerState<ContentMigrationScreen> createState() =>
      _ContentMigrationScreenState();
}

class _ContentMigrationScreenState
    extends ConsumerState<ContentMigrationScreen> {
  bool _isMigrating = false;
  bool _isEmbedding = false;
  Map<String, int>? _results;
  String? _error;

  Future<void> _runMigration() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Migrate All Content'),
        content: const Text(
          'This will classify all attractions, trips, events, and cultural items '
          'using Gemini AI. Takes 3-7 minutes. Make sure you have a stable internet '
          'connection. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Run Migration'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;


    setState(() {
      _isMigrating = true;
      _error = null;
      _results = null;
    });

    try {
      final results = await ref
          .read(adminRepositoryProvider)
          .migrateAllContent(collection: 'all');

      if (mounted) {
        setState(() => _results = results);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isMigrating = false);
    }
  }

  Future<void> _runEmbedMissing() async {
  setState(() => _isEmbedding = true);
  try {
    final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
        .httpsCallable(
      'embedMissingDocuments',
      options: HttpsCallableOptions(
        timeout: const Duration(minutes: 10), // ✅ زيادة المهلة لـ 10 دقائق
      ),
    );
    final result = await callable.call();
    
    final converted = _convertResponse(result.data) as Map<String, dynamic>;
    final stats = converted['stats'] as Map<String, dynamic>;

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('اكتملت العملية ✨'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stats.entries.map((e) {
              final s = e.value as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${e.key}: تم ${s['processed']} | متخطى ${s['skipped']} | فشل ${s['failed']}',
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) setState(() => _isEmbedding = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Migration'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.auto_awesome,
                size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'AI Content Classification',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Generates interestIds and embedding vectors for all '
              'attractions, trips, events, and cultural items.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isMigrating ? null : _runMigration,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              icon: _isMigrating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(
                _isMigrating
                    ? 'Migrating... (3-7 minutes)'
                    : 'Run Migration',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isEmbedding ? null : _runEmbedMissing,
              icon: _isEmbedding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _isEmbedding ? 'جاري توليد الـ Embeddings...' : 'توليد الـ Embeddings الناقصة',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 16),
            OutlinedButton.icon(
  onPressed: () async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('inspectDocumentShapes');
      final result = await callable.call();
      
      // ✅ التحويل الآمن
      final converted = _convertResponse(result.data);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Document Shapes'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(converted),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  },
  icon: const Icon(Icons.bug_report_outlined),
  label: const Text('فحص شكل البيانات'),
),

            // Results
            if (_results != null) _buildResults(theme),
            if (_error != null) _buildError(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Migration Complete',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._results!.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: theme.textTheme.bodyMedium),
                  Text(
                    '${e.value}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Migration Failed',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_error!, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Recursively converts Firebase Functions response (Map<Object?, Object?>)
/// to standard Dart types (Map<String, dynamic>)
dynamic _convertResponse(dynamic data) {
  if (data is Map) {
    return Map<String, dynamic>.fromEntries(
      data.entries.map(
        (e) => MapEntry(e.key.toString(), _convertResponse(e.value)),
      ),
    );
  }
  if (data is List) {
    return data.map(_convertResponse).toList();
  }
  return data;
}