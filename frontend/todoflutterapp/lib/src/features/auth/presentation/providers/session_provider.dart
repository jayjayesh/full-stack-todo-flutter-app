import 'dart:async';
import 'package:todoflutterapp/src/imports/packages_imports.dart';
import 'package:todoflutterapp/src/features/auth/domain/entities/user.dart';
import 'package:todoflutterapp/src/features/auth/domain/repositories/auth_repository.dart';

import 'package:todoflutterapp/src/features/auth/presentation/providers/auth_repository_provider.dart';

/// Provides the current session state
final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return SessionNotifier(repository: repo);
});

/// Session states
enum SessionStatus { unknown, authenticated, unauthenticated }

class SessionState {
  const SessionState({
    this.status = SessionStatus.unknown,
    this.user,
    this.isLoggingOut = false,
    this.errorMessage,
  });

  final SessionStatus status;
  final AppUser? user;
  final bool isLoggingOut;
  final String? errorMessage;

  SessionState copyWith({
    SessionStatus? status,
    AppUser? user,
    bool? isLoggingOut,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _authSub;

  SessionNotifier({required AuthRepository repository})
      : _repository = repository,
        super(const SessionState()) {
    _init();
  }

  Future<void> _init() async {
    // Check persisted session first
    final result = await _repository.checkAuthState();
    if (!mounted) return;

    result.fold(
      (_) => state = const SessionState(status: SessionStatus.unauthenticated),
      (user) {
        if (user != null) {
          state = SessionState(status: SessionStatus.authenticated, user: user);
        } else {
          state = const SessionState(status: SessionStatus.unauthenticated);
        }
      },
    );

    // Listen for future changes
    _authSub = _repository.onAuthStateChanged.listen((user) {
      if (!mounted) return;

      if (user != null) {
        state = SessionState(status: SessionStatus.authenticated, user: user);
      } else {
        state = const SessionState(status: SessionStatus.unauthenticated);
      }
    });
  }

  Future<void> logout() async {
    state = state.copyWith(isLoggingOut: true, clearError: true);

    final result = await _repository.logout();
    if (!mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        isLoggingOut: false,
        errorMessage: failure.message,
      ),
      (_) => state = const SessionState(status: SessionStatus.unauthenticated),
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
