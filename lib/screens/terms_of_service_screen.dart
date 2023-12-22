import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      screen: 'Terms of Service',
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
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
                },
                child: const Text('I Agree'),
              ),
            ],
          );
        },
      ),
    );
  }
}
