import 'dart:async';
import 'package:firebase_login/firebaseLogin/authentication/authenticationUser.dart';
import 'package:firebase_login/firebaseLogin/authentication/authenticationRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:pedantic/pedantic.dart';

//-----------------------------------------------------------------------------
// State:
//  - AuthenticationBlocState.authenticated
//  - AuthenticationBlocState.unauthenticated
//-----------------------------------------------------------------------------
enum AuthenticationStatus { authenticated, unauthenticated }

class AuthenticationBlocState {
  final AuthenticationStatus status;
  final AuthenticationUser user;

  // constructors
  const AuthenticationBlocState.authenticated(AuthenticationUser user)
      : this._(status: AuthenticationStatus.authenticated, user: user);
  const AuthenticationBlocState.unauthenticated() : this._(status: AuthenticationStatus.unauthenticated);
  const AuthenticationBlocState._({required this.status, this.user = AuthenticationUser.empty});
}

//-----------------------------------------------------------------------------
// Events:
//  - AuthenticationBlocEvent_LogoutRequested
//  - AuthenticationBlocEvent_UserChanged
//-----------------------------------------------------------------------------
abstract class AuthenticationBlocEvent {
  const AuthenticationBlocEvent();
}

class AuthenticationBlocEvent_LogoutRequested extends AuthenticationBlocEvent {}

class AuthenticationBlocEvent_UserChanged extends AuthenticationBlocEvent {
  final AuthenticationUser user;
  const AuthenticationBlocEvent_UserChanged(this.user);
}

//-----------------------------------------------------------------------------
// AuthenticationBloc
//-----------------------------------------------------------------------------
class AuthenticationBloc extends Bloc<AuthenticationBlocEvent, AuthenticationBlocState> {
  final AuthenticationRepository authenticationRepository;
  late final StreamSubscription<AuthenticationUser> _userSubscription;
  AuthenticationBloc(this.authenticationRepository)
      : super(
          authenticationRepository.currentUser.isNotEmpty
              ? AuthenticationBlocState.authenticated(authenticationRepository.currentUser)
              : const AuthenticationBlocState.unauthenticated(),
        ) {
    _userSubscription = authenticationRepository.userStream.listen(_onUserChanged);
  }

  void _onUserChanged(AuthenticationUser user) => add(AuthenticationBlocEvent_UserChanged(user));

  @override
  Stream<AuthenticationBlocState> mapEventToState(AuthenticationBlocEvent event) async* {
    if (event is AuthenticationBlocEvent_UserChanged) {
      yield _mapUserChangedToState(event, state);
    } else if (event is AuthenticationBlocEvent_LogoutRequested) {
      unawaited(authenticationRepository.logOut());
    }
  }

  AuthenticationBlocState _mapUserChangedToState(
      AuthenticationBlocEvent_UserChanged event, AuthenticationBlocState state) {
    return event.user.isNotEmpty
        ? AuthenticationBlocState.authenticated(event.user)
        : const AuthenticationBlocState.unauthenticated();
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
