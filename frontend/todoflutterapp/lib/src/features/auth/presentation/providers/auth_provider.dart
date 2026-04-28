import 'package:todoflutterapp/src/imports/core_imports.dart';
import 'package:todoflutterapp/src/imports/packages_imports.dart';

import 'package:todoflutterapp/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:todoflutterapp/src/features/auth/presentation/providers/auth_repository_provider.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthFormState>((ref) {
  return AuthController(
    repository: ref.read(authRepositoryProvider),
  );
});

class AuthFormState extends Equatable {
  const AuthFormState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  AuthFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage];
}

class AuthController extends StateNotifier<AuthFormState> {
  final AuthRepository _repository;

  AuthController({
    required AuthRepository repository,
  })  : _repository = repository,
        super(const AuthFormState());

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearError: true);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.login(email: email, password: password);

    if (!mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, clearError: true);
        return true;
      },
    );
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.signUp(
      name: name,
      email: email,
      password: password,
    );

    if (!mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, clearError: true);
        return true;
      },
    );
  }

  Future<void> forgotPassword({
    required BuildContext context,
    required String email,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.forgotPassword(email: email);

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        if (context.mounted) {
          showToast(context, message: failure.message, status: 'error');
        }
      },
      (success) {
        state = state.copyWith(isLoading: false, clearError: true);
        if (!context.mounted) return;

        showToast(
          context,
          message: 'Password reset link sent successfully',
          status: 'success',
        );
        context.go(AppRoutes.login);
      },
    );
  }
}
