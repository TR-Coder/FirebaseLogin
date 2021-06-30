import 'package:bloc/bloc.dart';
import 'package:firebase_login/library/firebase_login/authentication/authentication_repository.dart';
import 'package:firebase_login/library/firebase_login/login/iAuthenticationRepository.dart';
import 'package:firebase_login/library/firebase_login/login/login_error_messages.dart';
import 'package:firebase_login/library/firebase_login/login/model_login.dart';
import 'package:firebase_login/library/firebase_login/widgets/form_validator.dart';

//------------------------------------------------------------------------------
// ESDEVENIMENTS
//------------------------------------------------------------------------------
abstract class LoginEvent {
  const factory LoginEvent.emailChanged(String email) = LoginEvent_emailChanged;
  const factory LoginEvent.passwordChanged(String password) = LoginEvent_passwordChanged;
  const factory LoginEvent.withCredentials() = LoginEvent_withCredentials;
  const factory LoginEvent.withGoogle() = LoginEvent_withGoogle;
}

class LoginEvent_emailChanged implements LoginEvent {
  final String emailTxt;
  const LoginEvent_emailChanged(this.emailTxt);
}

class LoginEvent_passwordChanged implements LoginEvent {
  final String password;
  const LoginEvent_passwordChanged(this.password);
}

class LoginEvent_withCredentials implements LoginEvent {
  const LoginEvent_withCredentials();
}

class LoginEvent_withGoogle implements LoginEvent {
  const LoginEvent_withGoogle();
}

//------------------------------------------------------------------------------
// ESTAT
//------------------------------------------------------------------------------
class LoginState {
  final Email email;
  final Password password;
  final FormValidatorStatus status;

  LoginState._({required this.email, required this.password, required this.status});

  LoginState.init()
      : email = Email(initValue: ''),
        password = Password(initValue: ''),
        status = FormValidatorStatus.noValidated;

  LoginState copyWith({Email? email, Password? password, FormValidatorStatus? status}) {
    return LoginState._(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }
}

//------------------------------------------------------------------------------
// BLOC
//------------------------------------------------------------------------------
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final IAuthenticationRepository authenticationRepository;
  LoginBloc({required this.authenticationRepository}) : super(LoginState.init());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginEvent_emailChanged) {
      Email newEmail = state.email.copyWith(value: event.emailTxt, status: EmailStatus.noValidated);
      yield state.copyWith(email: newEmail, status: FormValidatorStatus.noValidated);
    } //
    else if (event is LoginEvent_passwordChanged) {
      Password newPassword = state.password.copyWith(value: event.password, status: PasswordStatus.noValidated);
      yield state.copyWith(password: newPassword, status: FormValidatorStatus.noValidated);
    } //
    else if (event is LoginEvent_withCredentials) {
      FormValidatorStatus formStatus = FormValidator.validate([state.email, state.password]);
      if (formStatus == FormValidatorStatus.valid)
        yield* logInWithCredentials();
      else
        yield state.copyWith(status: FormValidatorStatus.invalid);
    } //
    else if (event is LoginEvent_withGoogle) {
      yield* logInWithGoogle();
    }
  }

  // logInWithCredentials
  Stream<LoginState> logInWithCredentials() async* {
    yield state.copyWith(status: FormValidatorStatus.submissionInProgress);
    try {
      await authenticationRepository.logInWithEmailAndPassword(
        email: state.email.value,
        password: state.password.value,
      );
      yield state.copyWith(status: FormValidatorStatus.submissionSuccess);
    } on AuthenticationFailure catch (e) {
      yield* loginErrorHandler(e);
    }
  }

  // logInWithGoogle
  Stream<LoginState> logInWithGoogle() async* {
    yield state.copyWith(status: FormValidatorStatus.submissionInProgress);
    try {
      await authenticationRepository.logInWithGoogle();
      yield state.copyWith(status: FormValidatorStatus.submissionSuccess);
    } on AuthenticationFailure catch (e) {
      yield* loginErrorHandler(e);
    } on NoSuchMethodError {
      yield state.copyWith(status: FormValidatorStatus.noValidated);
    }
  }

  // loginErrorHandler
  Stream<LoginState> loginErrorHandler(AuthenticationFailure e) async* {
    String errorMsg = LoginErrorMessages.get(e);

    if (e.type == AuthenticationFailureType.wrongPassword) {
      var newPassword = state.password.copyWith(status: PasswordStatus.invalid, errorMsg: errorMsg);
      yield state.copyWith(password: newPassword, status: FormValidatorStatus.submissionFailure);
    } else {
      var newEmail = state.email.copyWith(status: EmailStatus.invalid, errorMsg: errorMsg);
      yield state.copyWith(email: newEmail, status: FormValidatorStatus.submissionFailure);
    }
  }
}

// https://medium.com/flutter-community/firebase-auth-exceptions-handling-flutter-54ab59c2853d
