import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the screen state during interest selection.
class PreferencesState {
  final Set<String> selectedIds;
  final bool isSaving;
  final String? errorMessage;

  const PreferencesState({
    this.selectedIds = const {},
    this.isSaving = false,
    this.errorMessage,
  });

  PreferencesState copyWith({
    Set<String>? selectedIds,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PreferencesState(
      selectedIds: selectedIds ?? this.selectedIds,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get canContinue => selectedIds.isNotEmpty && !isSaving;
}

class PreferencesNotifier extends Notifier<PreferencesState> {
  // Constant to avoid typos across all Firestore reads and writes.
  static const String _fieldName = 'culturalInterests';

  @override
  PreferencesState build() => const PreferencesState();

  /// Toggles an interest on/off in local state.
  /// Saving is deferred to [save] so the user can adjust freely before committing.
  void toggle(String interestId) {
    final next = Set<String>.from(state.selectedIds);
    if (next.contains(interestId)) {
      next.remove(interestId);
    } else {
      next.add(interestId);
    }
    state = state.copyWith(selectedIds: next, clearError: true);
  }

  /// Pre-fills the selection when entering edit mode from the profile screen.
  void initializeWith(List<String> existingIds) {
    state = state.copyWith(selectedIds: existingIds.toSet());
  }

  /// Persists selected interest IDs (English keys, not labels) to Firestore.
  /// Returns true on success so the caller can navigate away.
  Future<bool> save(String uid) async {
    if (state.selectedIds.isEmpty || state.isSaving) return false;

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({_fieldName: state.selectedIds.toList()});

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'تعذّر حفظ اهتماماتك. يرجى المحاولة مرة أخرى.',
      );
      return false;
    }
  }
}

final preferencesNotifierProvider =
    NotifierProvider<PreferencesNotifier, PreferencesState>(
  PreferencesNotifier.new,
);
