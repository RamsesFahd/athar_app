import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:athar_app/features/auth/logic/auth_repository.dart';
import 'package:athar_app/core/models/user_model.dart';

// AUTH STATE
// User status within the application
sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthGuest extends AuthState {}


// AUTH NOTIFIER

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(AuthInitial()) {
    checkStatus(); 
  }

  //  FUNCTION 1: CHECK STATUS
  Future<void> checkStatus() async {
    final current = FirebaseAuth.instance.currentUser;

    if (current == null) {
      state = AuthUnauthenticated();
      return;
    }

    if (current.isAnonymous) {
      state = AuthGuest();
      return;
    }

    final userData = await _repo.getUserData(current.uid);
    if (userData != null) {
      state = AuthAuthenticated(userData);
    } else {
      state = AuthUnauthenticated();
    }
  }

  // FUNCTION 2: SIGN UP
  Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = AuthLoading();

    final error = await _repo.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );

    if (error != null) {
      state = AuthUnauthenticated();
      return error;
    }

    await checkStatus();
    return null;
  }

  // FUNCTION 3: SIGN IN
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    state = AuthLoading();

    final error = await _repo.signIn(
      email: email,
      password: password,
    );

    if (error != null) {
      state = AuthUnauthenticated();
      return error;
    }

    await checkStatus();
    return null;
  }

  // FUNCTION 4: LOGIN AS GUEST
  Future<String?> loginAsGuest() async {
    state = AuthLoading();

    final error = await _repo.guestLogin();

    if (error != null) {
      state = AuthUnauthenticated();
      return error;
    }

    state = AuthGuest();
    return null;
  }


  // PROVIDER
  final authNotifierProvider =
      StateNotifierProvider<AuthNotifier, AuthState>((ref) {
    final repo = ref.watch(authRepositoryProvider);
    return AuthNotifier(repo);
  });
}