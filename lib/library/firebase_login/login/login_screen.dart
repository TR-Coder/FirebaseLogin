import 'package:firebase_login/library/firebase_login/internet_connection/internet_connection_bloc.dart';
import 'package:firebase_login/library/firebase_login/login/iAuthenticationRepository.dart';
import 'package:firebase_login/library/firebase_login/login/login_bloc.dart';
import 'package:firebase_login/library/firebase_login/login/signup_screen.dart';
import 'package:firebase_login/library/firebase_login/widgets/form_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  static const route = '/LoginScreen';
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
      body: Padding(
        padding: EdgeInsets.all(12),
        child: BlocProvider(
          create: (context) {
            return LoginBloc(
              authenticationRepository: context.read<IAuthenticationRepository>(),
            );
          },
          child: LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == FormValidatorStatus.submissionFailure || state.status == FormValidatorStatus.invalid) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text("Error d'autenticació"),
              ),
            );
        }
      },
      child: Align(
        alignment: Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _UsernameInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _PasswordInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _LoginButton(),
            const Padding(padding: EdgeInsets.all(12)),
            _GoogleLoginButton(),
            const SizedBox(height: 4.0),
            _SignUpButton(),
            const SizedBox(height: 4.0),
          ],
        ),
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return TextField(
          onChanged: (text) => context.read<LoginBloc>().add(LoginEvent.emailChanged(text)),
          key: const Key('loginForm_usernameInput_textField'),
          decoration: InputDecoration(
            labelText: 'Usuari (correu)',
            errorText: state.email.isInvalid ? state.email.errorMsg : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return TextField(
          onChanged: (text) => context.read<LoginBloc>().add(LoginEvent.passwordChanged(text)),
          key: const Key('loginForm_passwordInput_textField'),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contrasenya',
            errorText: state.password.isInvalid ? state.password.errorMsg : null,
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    primary: const Color(0xFFFFD600),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return (state.status == FormValidatorStatus.submissionInProgress)
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('loginForm_continue_raisedButton'),
                child: const Text('Login'),
                style: raisedButtonStyle,
                onPressed: () => context.read<LoginBloc>().add(LoginEvent.withCredentials()),
              );
      },
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      primary: Theme.of(context).accentColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
    );

    return ElevatedButton.icon(
      key: const Key('loginForm_googleLogin_raisedButton'),
      label: const Text(
        'SIGN IN WITH GOOGLE',
        style: TextStyle(color: Colors.white),
      ),
      icon: const Icon(FontAwesomeIcons.google, color: Colors.white),
      style: raisedButtonStyle,
      onPressed: () => context.read<LoginBloc>().add(LoginEvent.withGoogle()),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    primary: const Color(0xFFFFD600),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
  );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: const Key('loginForm_continue_raisedButton'),
      child: const Text('SingUp'),
      style: raisedButtonStyle,
      onPressed: () => Navigator.of(context).pushNamed(SignupScreen.route),
    );
  }
}
