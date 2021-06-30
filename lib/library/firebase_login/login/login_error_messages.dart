import 'package:firebase_login/library/firebase_login/authentication/authentication_repository.dart';

class LoginErrorMessages {
  static String get(AuthenticationFailure e) {
    switch (e.type) {
      case AuthenticationFailureType.emailAlreadyExists:
        return 'El correu ja existix';
      case AuthenticationFailureType.wrongPassword:
        return 'Contrasenya incorrecta';
      case AuthenticationFailureType.invalidEmail:
        return 'Format del correu incorrecte';
      case AuthenticationFailureType.userNotFound:
        return 'No existix un usuari amb este correu';
      case AuthenticationFailureType.userDisabled:
        return "L'usuari amb este correu ha sigut deshabilitat";
      case AuthenticationFailureType.operationNotAllowed:
        return "L'autenticació amb este correu i contrasenya està deshabilitada";
      case AuthenticationFailureType.undefined:
        return 'Ha ocorregut un error indefinit';
      case AuthenticationFailureType.weakPassword:
        return 'La contrasenya no és segura';
    }
  }
}
