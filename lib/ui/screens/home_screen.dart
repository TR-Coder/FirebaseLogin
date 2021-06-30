import 'package:firebase_login/library/firebase_login/authentication/authentication_bloc.dart';
import 'package:firebase_login/library/firebase_login/internet_connection/internet_connection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  static const route = '/HomeScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login screen'),
        leading: BlocBuilder<InternetConnectionBloc, InternetConnectionBlocState>(
          builder: (context, state) {
            if (state == InternetConnectionBlocState.connected) return Icon(Icons.signal_wifi_4_bar);
            if (state == InternetConnectionBlocState.disconnected) return Icon(Icons.signal_wifi_off);
            return Icon(Icons.signal_wifi_statusbar_connected_no_internet_4);
          },
        ),
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
                child: Text('Sign out'),
                onPressed: () => context.read<AuthenticationBloc>().add(AuthenticationBlocEvent.logoutRequested())),
          ),
          Center(
            child: ElevatedButton(
              child: Text('verifica'),
              onPressed: null,
            ),
          ),
          BlocBuilder<InternetConnectionBloc, InternetConnectionBlocState>(
            builder: (context, state) {
              if (state == InternetConnectionBlocState.connected) return Text('Connected');
              if (state == InternetConnectionBlocState.disconnected) return Text('Disconnected');
              return Text('???');
            },
          ),
        ],
      ),
    );
  }
}
