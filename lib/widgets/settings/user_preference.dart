import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';

class UserPreference extends StatelessWidget {
  final void Function(User)? onTap;

  const UserPreference({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        // print('user state: $state');
        return ListTile(
          title: Text(
            state.user.name != '' ? state.user.name : 'Loading...',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          onTap: onTap != null ? () => onTap!(state.user) : null,
          leading: CircleAvatar(
            backgroundColor: state.user.avatarUrl != ''
                ? Colors.black12
                : Theme.of(context).colorScheme.primary,
            backgroundImage: state.user.avatarUrl != ''
                ? NetworkImage(state.user.avatarUrl)
                : null,
            radius: 20,
            child: state.user.avatarUrl != ''
                ? null
                : const Icon(
                    Icons.person,
                    color: Colors.black87,
                  ),
          ),
        );
      },
    );
  }
}
