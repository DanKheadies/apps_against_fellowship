import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// import 'package:apps_against_fellowship/blocs/blocs.dart';
// import 'package:apps_against_fellowship/widgets/widgets.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Something went wrong. This page does not exist.',
            // style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 50,
            width: double.infinity,
          ),
          TextButton(
            onPressed: () => context.goNamed('signIn'),
            child: const Text(
              'To Sign In',
              // style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              //       color: Theme.of(context).colorScheme.primary,
              //     ),
            ),
          ),
        ],
      ),
    );
  }
}
