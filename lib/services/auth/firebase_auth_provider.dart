import 'package:chatapp_firebase/firebase_options.dart';
import 'package:chatapp_firebase/helper/helper_function.dart';
import 'package:chatapp_firebase/services/auth/auth_exceptions.dart';
import 'package:chatapp_firebase/services/auth/auth_provider.dart';
import 'package:chatapp_firebase/services/auth/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart' show Firebase;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async => await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        UserNotFoundAuthException.message =
            'Incorrect email or password, please try again.';
        throw UserNotFoundAuthException();
      } else if (e.code == 'user-not-found') {
        UserNotFoundAuthException.message = e.message;
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        WrongPasswordAuthException.message = e.message;
        throw WrongPasswordAuthException();
      } else if (e.code == 'user-disabled') {
        UserDisabledAuthException.message = e.message;
        throw UserDisabledAuthException();
      } else if (e.code == 'invalid-email') {
        InvalidEmailAuthException.message = e.message;
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        WeakPasswordAuthException.message = e.message;
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        EmailAlreadyInUseAuthException.message = e.message;
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        InvalidEmailAuthException.message = e.message;
        throw InvalidEmailAuthException();
      } else if (e.code == 'operation-not-allowed') {
        OperationNotAllowedAuthException.message = e.message;
        throw OperationNotAllowedAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut().then((value) async {
        await HelperFunctions.saveUserLoggedInStatus(false);
        await HelperFunctions.saveUserNameSF('');
        await HelperFunctions.saveUserEmailSF('');
      });
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
