import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      screen: 'Sign In',
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.submitting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state.status == AuthStatus.authenticated) {
            return const Center(
              child: Text('Authenticated.'),
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const RegisterWithEmailAndPassword(
                            email: 'davidwcorso@gmail.com',
                            password: 'Password1#',
                          ),
                        );
                  },
                  child: const Text('Register'),
                ),
                const SizedBox(
                  height: 50,
                  width: double.infinity,
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const LoginWithEmailAndPassword(
                            email: 'davidwcorso@gmail.com',
                            password: 'Password1#',
                          ),
                        );
                  },
                  child: const Text('Sign In'),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
