import 'package:bloc/bloc.dart';
import 'package:firebase_login/firebaseLogin/login/iAuthenticationRepository.dart';
import 'package:firebase_login/firebaseLogin/login/model_login.dart';
import 'package:firebase_login/firebaseLogin/widgets/form_validator.dart';

//------------------------------------------------------------------------------
// ESDEVENIMENTS
//------------------------------------------------------------------------------
abstract class LoginEvent {
  const factory LoginEvent.emailChanged(String email) = EmailChangedLoginEvent;
  const factory LoginEvent.passwordChanged(String password) = PasswordChangedLoginEvent;
  const factory LoginEvent.withCredentials() = LoginEventWithCredentials;
  const factory LoginEvent.withGoogle() = LoginEventWithGoogle;
}

class EmailChangedLoginEvent implements LoginEvent {
  final String emailTxt;
  const EmailChangedLoginEvent(this.emailTxt);
}

class PasswordChangedLoginEvent implements LoginEvent {
  final String password;
  const PasswordChangedLoginEvent(this.password);
}

class LoginEventWithCredentials implements LoginEvent {
  const LoginEventWithCredentials();
}

class LoginEventWithGoogle implements LoginEvent {
  const LoginEventWithGoogle();
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
    if (event is EmailChangedLoginEvent) {
      Email newEmail = state.email.copyWith(value: event.emailTxt, status: EmailStatus.noValidated);
      yield state.copyWith(email: newEmail, status: FormValidatorStatus.noValidated);
    } //
    else if (event is PasswordChangedLoginEvent) {
      Password newPassword = state.password.copyWith(value: event.password, status: PasswordStatus.noValidated);
      yield state.copyWith(password: newPassword, status: FormValidatorStatus.noValidated);
    } //
    else if (event is LoginEventWithCredentials) {
      FormValidatorStatus formStatus = FormValidator.validate([state.email, state.password]);
      if (formStatus == FormValidatorStatus.valid)
        yield* logInWithCredentials();
      else
        yield state.copyWith(status: FormValidatorStatus.invalid);
    } //
    else if (event is LoginEventWithGoogle) {
      yield* logInWithGoogle();
    }
  }

  Stream<LoginState> logInWithCredentials() async* {
    yield state.copyWith(status: FormValidatorStatus.submissionInProgress);
    try {
      await authenticationRepository.logInWithEmailAndPassword(
        email: state.email.value,
        password: state.password.value,
      );
      yield state.copyWith(status: FormValidatorStatus.submissionSuccess);
    } on Exception {
      yield state.copyWith(status: FormValidatorStatus.submissionFailure);
    }
  }

  Stream<LoginState> logInWithGoogle() async* {
    yield state.copyWith(status: FormValidatorStatus.submissionInProgress);
    try {
      await authenticationRepository.logInWithGoogle();
      yield state.copyWith(status: FormValidatorStatus.submissionSuccess);
    } on Exception {
      yield state.copyWith(status: FormValidatorStatus.submissionFailure);
    } on NoSuchMethodError {
      yield state.copyWith(status: FormValidatorStatus.noValidated);
    }
  }
}
