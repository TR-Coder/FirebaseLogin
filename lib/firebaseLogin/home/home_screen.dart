import 'package:firebase_login/firebaseLogin/authentication/authentication_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  static const route = '/HomeScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login screen')),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
                child: Text('Sign out'),
                onPressed: () => context.read<AuthenticationBloc>().add(AuthenticationBlocEvent.logoutRequested())),
          ),
        ],
      ),
    );
  }
}
