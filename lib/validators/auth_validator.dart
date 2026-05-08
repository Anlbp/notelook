class AuthValidator {
  AuthValidator._();

  static bool validEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  static bool strongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }
}
