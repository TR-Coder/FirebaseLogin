import 'package:firebase_login/firebaseLogin/login/iAuthenticationRepository.dart';
import 'package:firebase_login/firebaseLogin/login/signup_bloc.dart';
import 'package:firebase_login/firebaseLogin/widgets/form_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatelessWidget {
  static const route = '/SignupScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup screen')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: BlocProvider(
          create: (context) {
            return SignupBloc(
              authenticationRepository: context.read<IAuthenticationRepository>(),
            );
          },
          child: SignUpForm(),
        ),
      ),
    );
  }
}

class SignUpForm extends StatelessWidget {
  const SignUpForm();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state.status == FormValidatorStatus.submissionFailure) {
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
            _SignUpButton(),
            const Padding(padding: EdgeInsets.all(12)),
          ],
        ),
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      builder: (context, state) {
        return TextField(
          onChanged: (text) => context.read<SignupBloc>().add(SignupEvent.emailChanged(text)),
          key: const Key('signUpForm_usernameInput_textField'),
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
    return BlocBuilder<SignupBloc, SignupState>(
      builder: (context, state) {
        return TextField(
          onChanged: (text) => context.read<SignupBloc>().add(SignupEvent.passwordChanged(text)),
          key: const Key('signupForm_passwordInput_textField'),
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

class _SignUpButton extends StatelessWidget {
  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    primary: const Color(0xFFFFD600),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      builder: (context, state) {
        return (state.status == FormValidatorStatus.submissionInProgress)
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('signUpForm_continue_raisedButton'),
                child: const Text('Send'),
                style: raisedButtonStyle,
                onPressed: () => context.read<SignupBloc>().add(SignupEvent.withCredentials()),
              );
      },
    );
  }
}
