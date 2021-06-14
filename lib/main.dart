import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_login/firebaseLogin/authentication/authentication_bloc.dart';
import 'package:firebase_login/firebaseLogin/authentication/authentication_repository.dart';
import 'package:firebase_login/firebaseLogin/internet_connection/internet_connection_bloc.dart';
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthenticationBloc(_authenticationRepository),
          ),
          BlocProvider(
            create: (_) => InternetConnectionBloc(Connectivity()),
          ),
        ],
        child: AppView(),
      ),
      // child: BlocProvider(
      //   create: (_) => AuthenticationBloc(_authenticationRepository),
      //   child: AppView(),
      // ),
    );
  }
}

class AppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          MaterialAppView(),
          OverlayView(),
        ],
      ),
    );
  }
}

class MaterialAppView extends StatelessWidget {
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

class OverlayView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternetConnectionBloc, InternetConnectionBlocState>(
      builder: (context, state) {
        if (state == InternetConnectionBlocState_disconnected) {
          return Container(
            child: Text('No hi ha connexió'),
          );
        }
        return Container();
      },
    );
  }
}
// https://medium.com/saugo360/https-medium-com-saugo360-flutter-using-overlay-to-display-floating-widgets-2e6d0e8decb9
// https://www.youtube.com/watch?v=KuXKwjv2gTY
// https://stackoverflow.com/questions/57069641/how-to-overlay-a-widget-on-top-of-a-flutter-app


