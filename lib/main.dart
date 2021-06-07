import 'package:firebase_login/firebaseLogin/authentication/authenticationBloc.dart';
import 'package:firebase_login/firebaseLogin/authentication/authenticationRepository.dart';
import 'package:firebase_login/firebaseLogin/login/iAuthenticationRepository.dart';
import 'package:firebase_login/firebaseLogin/home/home_screen.dart';
import 'package:firebase_login/firebaseLogin/login/login_screen.dart';
import 'package:firebase_login/routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  final IAuthenticationRepository authenticationRepository = await InitializeAuthentication.init();
  runApp(App(authenticationRepository));
}

class App extends StatelessWidget {
  final IAuthenticationRepository _authenticationRepository;
  const App(this._authenticationRepository);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: BlocProvider(
        create: (_) => AuthenticationBloc(_authenticationRepository),
        child: AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  final _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      theme: ThemeData(primarySwatch: Colors.purple),
      onGenerateRoute: Routing().selector,
      initialRoute: Routing().splashScreen,
      builder: (context, child) {
        return BlocListener<AuthenticationBloc, AuthenticationBlocState>(
          listener: (context, state) {
            switch (state.status) {
              case AuthenticationStatus.authenticated:
                _navigator.pushNamedAndRemoveUntil<void>(HomeScreen.route, (_) => false);
                break;
              case AuthenticationStatus.unauthenticated:
                _navigator.pushNamedAndRemoveUntil<void>(LoginScreen.route, (_) => false);
                break;
            }
          },
          child: child,
        );
      },
    );
  }
}
