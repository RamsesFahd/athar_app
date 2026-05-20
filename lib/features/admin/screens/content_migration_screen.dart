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
import 'package:athar_app/generated/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminMigrateAllTitle),
        content: Text(l10n.adminMigrateAllBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.adminCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.adminRunMigration),
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
  final l10n = AppLocalizations.of(context);
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
          title: Text(l10n.adminOperationComplete),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stats.entries.map((e) {
              final s = e.value as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  l10n.adminEmbeddingStatsLine(
                    e.key,
                    (s['processed'] ?? 0).toString(),
                    (s['skipped'] ?? 0).toString(),
                    (s['failed'] ?? 0).toString(),
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonOk),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commonErrorWithMessage(e.toString())), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) setState(() => _isEmbedding = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminMigrationTitle),
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
              l10n.adminMigrationHeading,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.adminMigrationDescription,
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
                    ? l10n.adminMigratingProgress
                    : l10n.adminRunMigration,
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
                _isEmbedding ? l10n.adminEmbeddingProgress : l10n.adminGenerateMissingEmbeddings,
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
            title: Text(l10n.adminDocumentShapes),
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
                child: Text(l10n.commonOk),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonErrorWithMessage(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  },
  icon: const Icon(Icons.bug_report_outlined),
  label: Text(l10n.adminInspectDataShape),
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
                AppLocalizations.of(context).adminMigrationComplete,
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
                AppLocalizations.of(context).adminMigrationFailed,
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
