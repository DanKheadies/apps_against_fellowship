import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      screen: 'Home',
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state.userStatus == UserStatus.initial ||
              state.userStatus == UserStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state.userStatus == UserStatus.loaded) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Home'),
                const SizedBox(
                  height: 50,
                  width: double.infinity,
                ),
                Switch(
                  value: state.user.acceptedTerms,
                  activeColor: Colors.red,
                  onChanged: (value) => context.read<UserBloc>().add(
                        UpdateUser(
                          user: state.user.copyWith(
                            acceptedTerms: value,
                          ),
                        ),
                      ),
                ),
                const SizedBox(
                  height: 50,
                  width: double.infinity,
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          SignOut(),
                        );
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            );
          }
          if (state.userStatus == UserStatus.error) {
            return const Center(
              child: Text('There was an error.'),
            );
          } else {
            return const Center(
              child: Text('Something went wrong.'),
            );
          }
        },
      ),
    );
  }
}
