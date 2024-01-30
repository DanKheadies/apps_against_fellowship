import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      screen: 'Terms of Service',
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state.userStatus == UserStatus.initial ||
              state.userStatus == UserStatus.loading) {
            return const Center();
          }
          if (state.userStatus == UserStatus.loaded) {
            if (state.user.acceptedTerms) {
              return const Center(
                child: Icon(
                  Icons.thumb_up_sharp,
                ),
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text('These are the terms.'),
                  const SizedBox(
                    width: double.infinity,
                    height: 25,
                  ),
                  const Text('Have fun.'),
                  const SizedBox(
                    width: double.infinity,
                    height: 50,
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<UserBloc>().add(
                            UpdateUser(
                              user: state.user.copyWith(
                                acceptedTerms: true,
                              ),
                            ),
                          );
                      context.goNamed('home');
                    },
                    child: const Text('I Agree'),
                  ),
                ],
              );
            }
          }
          if (state.userStatus == UserStatus.error) {
            return const Center(
              child: Text('There is an error with the user.'),
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
