import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

class UserWidget extends StatelessWidget {
  const UserWidget({super.key});

  Widget buildErrorIcon(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        radius: 12,
        child: Icon(
          Icons.no_accounts_outlined,
          color: Theme.of(context).colorScheme.surface,
          size: 20,
        ),
      ),
    );
  }

  Widget buildLoadingIcon() {
    return const SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildUserIcon(
    BuildContext context,
    UserState state,
  ) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: state.user.avatarUrl != ''
            ? NetworkImage(state.user.avatarUrl)
            : null,
        radius: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state.userStatus == UserStatus.initial ||
            state.userStatus == UserStatus.loading) {
          return HomeOutlineButton(
            icon: buildLoadingIcon(),
            text: 'Loading...',
          );
        }
        if (state.userStatus == UserStatus.loaded) {
          return HomeOutlineButton(
            icon: buildUserIcon(context, state),
            text: state.user.name != '' ? state.user.name : 'You',
            onTap: () {
              context.goNamed('profile');
            },
          );
        } else {
          return HomeOutlineButton(
            icon: buildErrorIcon(context),
            text: 'Uh oh!',
          );
        }
      },
    );
  }
}
