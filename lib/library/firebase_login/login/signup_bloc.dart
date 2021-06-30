import 'package:bloc/bloc.dart';
import 'package:firebase_login/library/firebase_login/authentication/authentication_repository.dart';
import 'package:firebase_login/library/firebase_login/login/iAuthenticationRepository.dart';
import 'package:firebase_login/library/firebase_login/login/login_error_messages.dart';
import 'package:firebase_login/library/firebase_login/login/model_login.dart';
import 'package:firebase_login/library/firebase_login/widgets/form_validator.dart';

//------------------------------------------------------------------------------
// ESDEVENIMENTS
//-----------------------------------------------------------------------------
abstract class SignupEvent {
  const factory SignupEvent.emailChanged(String email) = SignupEvent_emailChanged;
  const factory SignupEvent.passwordChanged(String password) = SignupEvent_passwordChanged;
  const factory SignupEvent.withCredentials() = SignupEvent_withCredentials;
}

class SignupEvent_emailChanged implements SignupEvent {
  final String emailTxt;
  const SignupEvent_emailChanged(this.emailTxt);
}

class SignupEvent_passwordChanged implements SignupEvent {
  final String password;
  const SignupEvent_passwordChanged(this.password);
}

class SignupEvent_withCredentials implements SignupEvent {
  const SignupEvent_withCredentials();
}

//------------------------------------------------------------------------------
// ESTAT
//------------------------------------------------------------------------------

class SignupState {
  final Email email;
  final Password password;
  final FormValidatorStatus status;

  SignupState._({required this.email, required this.password, required this.status});

  SignupState.init()
      : email = Email(initValue: ''),
        password = Password(initValue: ''),
        status = FormValidatorStatus.noValidated;

  SignupState copyWith({Email? email, Password? password, FormValidatorStatus? status}) {
    return SignupState._(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }
}

//------------------------------------------------------------------------------
// BLOC
//------------------------------------------------------------------------------
class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final IAuthenticationRepository authenticationRepository;
  SignupBloc({required this.authenticationRepository}) : super(SignupState.init());

  @override
  Stream<SignupState> mapEventToState(SignupEvent event) async* {
    if (event is SignupEvent_emailChanged) {
      Email newEmail = state.email.copyWith(value: event.emailTxt, status: EmailStatus.noValidated);
      yield state.copyWith(email: newEmail, status: FormValidatorStatus.noValidated);
    } //
    else if (event is SignupEvent_passwordChanged) {
      Password newPassword = state.password.copyWith(value: event.password, status: PasswordStatus.noValidated);
      yield state.copyWith(password: newPassword, status: FormValidatorStatus.noValidated);
    } //
    else if (event is SignupEvent_withCredentials) {
      FormValidatorStatus formStatus = FormValidator.validate([state.email, state.password]);
      if (formStatus == FormValidatorStatus.valid)
        yield* SignupWithCredentials();
      else
        yield state.copyWith(status: FormValidatorStatus.invalid);
    } //
  }

  // SignupWithCredentials
  Stream<SignupState> SignupWithCredentials() async* {
    yield state.copyWith(status: FormValidatorStatus.submissionInProgress);
    try {
      await authenticationRepository.signUp(
        email: state.email.value,
        password: state.password.value,
      );
      yield state.copyWith(status: FormValidatorStatus.submissionSuccess);
    } on AuthenticationFailure catch (e) {
      yield* loginErrorHandler(e);
    }
  }

  // loginErrorHandler
  Stream<SignupState> loginErrorHandler(AuthenticationFailure e) async* {
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
