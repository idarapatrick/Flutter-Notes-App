abstract class AuthRepository {
  /// Signs up a user with email and password.
  Future<void> signUp({required String email, required String password});

  /// Logs in a user with email and password.
  Future<void> logIn({required String email, required String password});

  /// Logs out the current user.
  Future<void> logOut();

  /// Returns the current user's UID, or null if not logged in.
  String? getCurrentUserId();

  /// Returns the current user's email, or null if not logged in.
  String? getCurrentUserEmail();
}
