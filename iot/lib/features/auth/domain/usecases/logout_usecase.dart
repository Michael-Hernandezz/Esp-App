import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository authRepository;

  const LogoutUseCase(this.authRepository);

  Future<void> execute() async {
    await authRepository.logout();
  }
}
