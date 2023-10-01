// Login Exceptions

class UserNotFoundAuthException implements Exception {
  static String? message = 'Error';
}

class WrongPasswordAuthException implements Exception {
  static String? message = 'Error';
  //  = 'Incorrect password.';
}

class UserDisabledAuthException implements Exception {
  static String? message = 'Error';
  //  = 'Incorrect password.';
}

// Register Exceptions

class WeakPasswordAuthException implements Exception {
  static String? message = 'Error';
  //  = 'Password should be at least 6 characters.';
}

class EmailAlreadyInUseAuthException implements Exception {
  static String? message = 'Error';
  //  =
  //     'The email address is already in use by another account.';
}

class InvalidEmailAuthException implements Exception {
  static String? message = 'Error';
  //  = 'The email address is badly formatted.';
}

class OperationNotAllowedAuthException implements Exception {
  static String? message = 'Error';
  //  =
  //     'The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.';
}

// Generic Exceptions

//TODO message variable
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
