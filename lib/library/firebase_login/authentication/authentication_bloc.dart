import 'dart:async';
import 'package:firebase_login/library/firebase_login/authentication/authentication_user.dart';
import 'package:firebase_login/library/firebase_login/login/iAuthenticationRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:pedantic/pedantic.dart';

//-----------------------------------------------------------------------------
// State:
//  - AuthenticationBlocState.authenticated(AuthenticationUser user)
//  - AuthenticationBlocState.unauthenticated()
//-----------------------------------------------------------------------------
enum AuthenticationStatus { authenticated, unauthenticated }

class AuthenticationBlocState {
  final AuthenticationStatus status;
  final AuthenticationUser user;

  // constructors
  const AuthenticationBlocState._({required this.status, this.user = AuthenticationUser.empty});

  const AuthenticationBlocState.authenticated(AuthenticationUser user)
      : this._(status: AuthenticationStatus.authenticated, user: user);

  const AuthenticationBlocState.unauthenticated() : this._(status: AuthenticationStatus.unauthenticated);
}

//-----------------------------------------------------------------------------
// Events:
//  - AuthenticationBlocEvent.logoutRequested()
//  - AuthenticationBlocEvent.userChanged((AuthenticationUser user))
//-----------------------------------------------------------------------------

abstract class AuthenticationBlocEvent {
  const factory AuthenticationBlocEvent.logoutRequested() = AuthenticationBlocEvent_logoutRequested;
  const factory AuthenticationBlocEvent.userChanged(AuthenticationUser user) = AuthenticationBlocEvent_userChanged;
}

// ignore: camel_case_types
class AuthenticationBlocEvent_logoutRequested implements AuthenticationBlocEvent {
  const AuthenticationBlocEvent_logoutRequested();
}

// ignore: camel_case_types
class AuthenticationBlocEvent_userChanged implements AuthenticationBlocEvent {
  final AuthenticationUser user;
  const AuthenticationBlocEvent_userChanged(this.user);
}

//-----------------------------------------------------------------------------
// AuthenticationBloc
//-----------------------------------------------------------------------------
class AuthenticationBloc extends Bloc<AuthenticationBlocEvent, AuthenticationBlocState> {
  final IAuthenticationRepository authenticationRepository;
  late final StreamSubscription<AuthenticationUser> _userSubscription;
  AuthenticationBloc(this.authenticationRepository)
      : super(
          authenticationRepository.currentUser.isNotEmpty
              ? AuthenticationBlocState.authenticated(authenticationRepository.currentUser)
              : const AuthenticationBlocState.unauthenticated(),
        ) {
    _userSubscription = authenticationRepository.userStream.listen(_onUserChanged);
  }

  void _onUserChanged(AuthenticationUser user) => add(AuthenticationBlocEvent.userChanged(user));

  @override
  Stream<AuthenticationBlocState> mapEventToState(AuthenticationBlocEvent event) async* {
    if (event is AuthenticationBlocEvent_userChanged) {
      yield _mapUserChangedToState(event, state);
    } else if (event is AuthenticationBlocEvent_logoutRequested) {
      unawaited(authenticationRepository.logOut());
    }
  }

  AuthenticationBlocState _mapUserChangedToState(
      AuthenticationBlocEvent_userChanged event, AuthenticationBlocState state) {
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
