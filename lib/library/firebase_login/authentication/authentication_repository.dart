import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_login/library/firebase_login/login/iAuthenticationRepository.dart';
import 'package:firebase_login/library/firebase_login/authentication/authentication_user.dart';
import 'package:google_sign_in/google_sign_in.dart';

//-----------------------------------------------------------------------------
// Classes AuthenticationFailureType
//-----------------------------------------------------------------------------
enum AuthenticationFailureType {
  emailAlreadyExists,
  wrongPassword,
  invalidEmail,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  undefined,
  weakPassword
}

class AuthenticationFailure implements Exception {
  AuthenticationFailure({required this.type});
  AuthenticationFailureType type;
}

//-----------------------------------------------------------------------------
// class AuthenticationRepository
//-----------------------------------------------------------------------------
class InitializeAuthentication {
  static Future<AuthenticationRepository> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    final authenticationRepository = AuthenticationRepository();
    await authenticationRepository.userStream.first;
    return authenticationRepository;
  }
}

//-----------------------------------------------------------------------------
// class AuthenticationRepository
//-----------------------------------------------------------------------------
class AuthenticationRepository implements IAuthenticationRepository<AuthenticationUser> {
  final CacheUser _cache;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  static const userCacheKey = '__user_cache_key__';

  // Constructor
  AuthenticationRepository({CacheUser? cache, firebase_auth.FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _cache = cache ?? CacheUser(),
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard();

  // userStream exposa in Stream d'User que notifica canvis en l'estat de l'autenticació.
  // Inicialment emet un User.empty.
  Stream<AuthenticationUser> get userStream {
    return _firebaseAuth.authStateChanges().map(
      (firebaseUser) {
        final user = (firebaseUser == null)
            ? AuthenticationUser.empty
            : AuthenticationUser(
                id: firebaseUser.uid,
                email: firebaseUser.email,
                name: firebaseUser.displayName,
                photo: firebaseUser.photoURL);
        _cache.write(key: userCacheKey, value: user);
        return user;
      },
    );
  }

  // currentUser
  AuthenticationUser get currentUser {
    return _cache.read<AuthenticationUser>(key: userCacheKey) ?? AuthenticationUser.empty;
  }

  //SignUp
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print(AuthenticationFailureType.invalidEmail.toString());
      AuthenticationExceptionHandler(e);
    }
  }

  // logInWithGoogle
  Future<void> logInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      AuthenticationExceptionHandler(e);
    }
  }

  // logInWithEmailAndPassword
  Future<void> logInWithEmailAndPassword({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      AuthenticationExceptionHandler(e);
    }
  }

  // logOut
  Future<void> logOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } on FirebaseAuthException catch (e) {
      AuthenticationExceptionHandler(e);
    }
  }

  // AuthenticationExceptionHandler
  // https://firebase.google.com/docs/reference/js/firebase.auth.Auth
  //
  void AuthenticationExceptionHandler(FirebaseException e) {
    switch (e.code) {
      case "invalid-email":
        throw AuthenticationFailure(type: AuthenticationFailureType.invalidEmail);
      case "wrong-password":
        throw AuthenticationFailure(type: AuthenticationFailureType.wrongPassword);
      case "user-not-found":
        throw AuthenticationFailure(type: AuthenticationFailureType.userNotFound);
      case "user-disabled":
        throw AuthenticationFailure(type: AuthenticationFailureType.userDisabled);
      case "operation-not-allowed":
        throw AuthenticationFailure(type: AuthenticationFailureType.operationNotAllowed);
      case "email-already-in-use":
        throw AuthenticationFailure(type: AuthenticationFailureType.emailAlreadyExists);
      case "weak-password":
        throw AuthenticationFailure(type: AuthenticationFailureType.weakPassword);
      default:
        throw AuthenticationFailure(type: AuthenticationFailureType.undefined);
    }
  }
}
