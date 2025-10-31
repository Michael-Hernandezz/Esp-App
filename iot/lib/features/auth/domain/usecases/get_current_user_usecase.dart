import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository authRepository;

  const GetCurrentUserUseCase(this.authRepository);

  Future<User?> execute() async {
    return await authRepository.getCurrentUser();
  }
}
