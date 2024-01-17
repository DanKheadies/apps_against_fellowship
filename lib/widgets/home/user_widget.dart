import 'package:flutter/material.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';

class UserWidget extends StatelessWidget {
  final HomeState state;
  final VoidCallback onTap;

  const UserWidget({
    super.key,
    required this.onTap,
    required this.state,
  });

  Widget buildErrorIcon() {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircleAvatar(
        backgroundColor: Colors.redAccent,
        radius: 12,
        child: Icon(
          Icons.no_accounts_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget buildLoadingIcon() {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(),
    );
  }

  Widget buildUserIcon(BuildContext context) {
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
    return HomeOutlineButton(
      icon: state.isLoading
          ? buildLoadingIcon()
          : state.error != ''
              ? buildErrorIcon()
              : buildUserIcon(context),
      text: state.isLoading
          ? 'Loading...'
          : state.error != ''
              ? 'Uh oh!'
              : state.user.name,
      textColor: Colors.white,
      onTap: onTap,
    );
  }
}
