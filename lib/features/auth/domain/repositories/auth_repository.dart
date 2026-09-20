import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<Result<User>> login({
    required String email,
    required String password,
  });

  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Result<UserProfile>> getUserProfile();

  Future<Result<bool>> verifySession();

  Future<Result<void>> logout();
}
