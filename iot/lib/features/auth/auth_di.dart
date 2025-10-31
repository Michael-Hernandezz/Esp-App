import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/storage_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/get_current_user_usecase.dart';
import 'data/services/storage_service.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'presentation/providers/auth_notifier.dart';

class AuthDependencyInjection {
  static AuthNotifier? _authNotifier;

  static AuthNotifier getAuthNotifier() {
    _authNotifier ??= _createAuthNotifier();
    return _authNotifier!;
  }

  static AuthNotifier _createAuthNotifier() {
    // Storage
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );

    final StorageRepository storageRepository = StorageService(secureStorage);

    // Auth Repository
    final AuthRepository authRepository = AuthRepositoryImpl(storageRepository);

    // Use Cases
    final loginUseCase = LoginUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);

    // Notifier
    return AuthNotifier(loginUseCase, logoutUseCase, getCurrentUserUseCase);
  }

  static void dispose() {
    _authNotifier?.dispose();
    _authNotifier = null;
  }

  static void reset() {
    dispose();
    _authNotifier = _createAuthNotifier();
  }
}
