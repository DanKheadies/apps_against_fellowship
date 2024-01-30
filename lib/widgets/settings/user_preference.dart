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
        return ListTile(
          title: Text(
            state.user.name != '' ? state.user.name : 'You',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          onTap: onTap != null ? () => onTap!(state.user) : null,
          leading: CircleAvatar(
            backgroundColor: state.user.avatarUrl != ''
                ? Theme.of(context).cardColor
                : Theme.of(context).colorScheme.primary,
            backgroundImage: state.user.avatarUrl != ''
                ? NetworkImage(state.user.avatarUrl)
                : null,
            radius: 20,
            child: state.user.avatarUrl != ''
                ? null
                : Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.background,
                  ),
          ),
        );
      },
    );
  }
}
