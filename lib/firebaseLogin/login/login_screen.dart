import 'package:firebase_login/firebaseLogin/login/iAuthenticationRepository.dart';
import 'package:firebase_login/firebaseLogin/login/login_bloc.dart';
import 'package:firebase_login/firebaseLogin/widgets/form_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  static const route = '/LoginScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login screen')),
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
        if (state.status == FormValidatorStatus.submissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Authentication Failure'),
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
          onChanged: (text) => context.read<LoginBloc>().add(EmailChangedLoginEvent(text)),
          key: const Key('loginForm_usernameInput_textField'),
          decoration: InputDecoration(
            labelText: 'Usuari',
            errorText: state.email.isInvalid ? 'Usuari incorrecte' : null,
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
          onChanged: (text) => context.read<LoginBloc>().add(PasswordChangedLoginEvent(text)),
          key: const Key('loginForm_passwordInput_textField'),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contrasenya',
            errorText: state.password.isInvalid ? 'Contrasenya incorrecta' : null,
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
