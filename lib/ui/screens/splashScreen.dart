import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static const route = '/SplashScreen';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
