import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_login/firebaseLogin/login/iAuthenticationRepository.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_login/firebaseLogin/authentication/authentication_user.dart';

//-----------------------------------------------------------------------------
// Classes Exception
//-----------------------------------------------------------------------------
class SignUpFailure implements Exception {}

class LogInWithEmailAndPasswordFailure implements Exception {}

class LogInWithGoogleFailure implements Exception {}

class LogOutFailure implements Exception {}

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
    } on Exception {
      throw SignUpFailure();
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
    } catch (e) {
      print('--- ERROR AUTENTICACIÓ ---');
      print(e);
      throw LogInWithEmailAndPasswordFailure();
    }

    // on Exception {
    //   throw LogInWithGoogleFailure();
    // }
  }

  // logInWithEmailAndPassword
  Future<void> logInWithEmailAndPassword({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on Exception {
      throw LogInWithEmailAndPasswordFailure();
    }
  }

  // logOut
  Future<void> logOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } on Exception {
      throw LogOutFailure();
    }
  }
}
