import 'package:firebase_login/firebaseLogin/authentication/authentication_user.dart';

abstract class IAuthenticationRepository<T> {
  // ignore: unused_field
  final Stream<T> _inputStream;
  IAuthenticationRepository(Stream<T> inputStream) : _inputStream = inputStream;
  Stream<AuthenticationUser> get userStream;
  Future<void> logOut();
  Future<void> logInWithEmailAndPassword({required String email, required String password});
  Future<void> logInWithGoogle();
  Future<void> signUp({required String email, required String password});
  AuthenticationUser get currentUser;
}
