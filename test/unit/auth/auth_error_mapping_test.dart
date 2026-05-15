// Tests for AuthRepository._mapFirebaseError error-code mapping.
// UT-15 through UT-17.
//
// SOURCE MODIFICATION NOTE:
//   The private _mapFirebaseError method in auth_repository.dart was exposed
//   as a @visibleForTesting public mapFirebaseError method so tests can invoke
//   it without triggering real Firebase calls. The private method now delegates
//   to the public one, preserving all existing call sites unchanged.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:athar_app/features/auth/logic/auth_repository.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

FirebaseAuthException _exc(String code) => FirebaseAuthException(code: code);

void main() {
  late AuthRepository repo;

  setUp(() {
    // Inject mocks so Firebase.initializeApp() is never required.
    repo = AuthRepository(
      auth: MockFirebaseAuth(),
      firestore: MockFirebaseFirestore(),
    );
  });

  group('AuthRepository.mapFirebaseError', () {
    // UT-15 ----------------------------------------------------------------
    test('UT-15: code "user-not-found" → returns "errorUserNotFound"', () {
      expect(repo.mapFirebaseError(_exc('user-not-found')), 'errorUserNotFound');
    });

    // UT-16 ----------------------------------------------------------------
    test('UT-16: code "wrong-password" → returns "errorWrongPassword"', () {
      expect(repo.mapFirebaseError(_exc('wrong-password')), 'errorWrongPassword');
    });

    // UT-17 ----------------------------------------------------------------
    test('UT-17: unknown code → returns generic fallback "errorUnexpected"', () {
      expect(repo.mapFirebaseError(_exc('unknown-code-xyz')), 'errorUnexpected');
    });
  });
}
