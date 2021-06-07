import 'package:firebase_login/home_screen.dart';
import 'package:firebase_login/firebaseLogin/login/login_screen.dart';
import 'package:firebase_login/splashScreen.dart';
import 'package:flutter/material.dart';

class Routing {
  static final Routing _singleton = Routing._();
  factory Routing() => _singleton;
  Routing._();

  get splashScreen => SplashScreen.route;

  Route<dynamic> selector(RouteSettings settings) {
    switch (settings.name) {
      case HomeScreen.route:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(),
        );
      case SplashScreen.route:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(),
        );
      case LoginScreen.route:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
