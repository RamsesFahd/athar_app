// ============================================================================
// Athar — Preferences Notifier (Refactored)
// ----------------------------------------------------------------------------
// Location: lib/features/onboarding/logic/preferences_notifier.dart
//
// Responsibility: Manages the state of interest selection during onboarding,
// and persists the selected interest IDs to the user's Firestore document.
//
// Why a real Notifier (not just a function):
//   - Matches the Riverpod pattern used elsewhere in the project (authNotifier)
//   - Centralizes the saving + loading + invalidation logic in one place
//   - Easier to test (mockable Notifier vs static function)
//   - Lets the UI react to saving/error states reactively
//
// Stored shape in Firestore: users/{uid} → { culturalInterests: [<id>, <id>, ...] }
//   Note: IDs are English (e.g., 'heritage_sites'), NOT Arabic labels.
//   This decouples the database from the UI language.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// State
// ============================================================================

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

// ============================================================================
// Notifier
// ============================================================================

class PreferencesNotifier extends Notifier<PreferencesState> {
  static const String _fieldName = 'culturalInterests';

  @override
  PreferencesState build() => const PreferencesState();

  /// Toggles an interest on/off in the local selection.
  /// This does NOT save to Firestore — saving happens on _save().
  void toggle(String interestId) {
    final next = Set<String>.from(state.selectedIds);
    if (next.contains(interestId)) {
      next.remove(interestId);
    } else {
      next.add(interestId);
    }
    state = state.copyWith(selectedIds: next, clearError: true);
  }

  /// Pre-loads previously saved interests (for the "edit interests" flow
  /// in the profile screen).
  void initializeWith(List<String> existingIds) {
    state = state.copyWith(selectedIds: existingIds.toSet());
  }

  /// Persists the selected interest IDs to the user's Firestore document.
  /// Returns true on success, false on failure.
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

// ============================================================================
// Provider
// ============================================================================

final preferencesNotifierProvider =
    NotifierProvider<PreferencesNotifier, PreferencesState>(
  PreferencesNotifier.new,
);
