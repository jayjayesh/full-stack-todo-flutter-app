import 'package:todoflutterapp/src/imports/packages_imports.dart';

import 'package:todoflutterapp/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:todoflutterapp/src/features/auth/domain/repositories/auth_repository.dart';

/// The single AuthRepository provider used by auth screens and session state.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});
