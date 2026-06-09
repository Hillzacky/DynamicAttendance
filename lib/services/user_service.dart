import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserService {
  final UserRepository _repository = UserRepository();

  // Validasi username
  Future<bool> isUsernameAvailable(String username) async {
    final user = await _repository.getUserByUsername(username);
    return user == null;
  }

  // Validasi email
  Future<bool> isEmailAvailable(String email) async {
    try {
      final users = await _repository.getAllUsers();
      return !users.any((u) => u.email == email);
    } catch (e) {
      return false;
    }
  }

  // Hash password (simple example - gunakan crypto yang lebih baik di production)
  String hashPassword(String password) {
    // TODO: Implementasi proper password hashing
    return password;
  }

  // Validasi password strength
  bool isPasswordStrong(String password) {
    return password.length >= 6;
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final allUsers = await _repository.getAllUsers();
      final activeUsers = await _repository.getUsersByStatus('active');
      final inactiveUsers = await _repository.getUsersByStatus('inactive');

      return {
        'total': allUsers.length,
        'active': activeUsers.length,
        'inactive': inactiveUsers.length,
        'suspended': allUsers.length - activeUsers.length - inactiveUsers.length,
      };
    } catch (e) {
      return {
        'total': 0,
        'active': 0,
        'inactive': 0,
        'suspended': 0,
      };
    }
  }

  // Export users to JSON
  Future<String> exportUsersToJson() async {
    try {
      final users = await _repository.getAllUsers();
      return users.toString();
    } catch (e) {
      throw Exception('Error exporting users: $e');
    }
  }
}