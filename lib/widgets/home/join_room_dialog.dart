import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JoinRoomDialog extends StatefulWidget {
  const JoinRoomDialog({super.key});

  @override
  State<JoinRoomDialog> createState() => _JoinRoomDialogState();
}

class _JoinRoomDialogState extends State<JoinRoomDialog> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController gameInputController = TextEditingController();

  @override
  void dispose() {
    gameInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: TextFormField(
              controller: gameInputController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Game ID',
                labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                    ),
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
              ),
              maxLength: 5,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              keyboardType: TextInputType.text,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.go,
              onFieldSubmitted: (value) {
                Navigator.of(context).pop(value);
              },
              validator: (value) {
                if (value?.length != 5) {
                  return 'Please enter a valid game id';
                }
                return null;
              },
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            bottom: 8,
            top: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  'JOIN',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    var gameId = gameInputController.text;
                    context.read<HomeBloc>().add(
                          JoinGame(gameCode: gameId),
                        );
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<String?> showJoinRoomDialog(BuildContext context) {
  if (kIsWeb) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return AlertDialog(
          title: Text(
            'Join a game',
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          content: const JoinRoomDialog(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(0),
        );
      },
    );
  } else {
    return showDialog(
      context: context,
      builder: (builderContext) {
        return AlertDialog(
          title: Text(
            'Join a game',
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          content: const JoinRoomDialog(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(0),
        );
      },
    );
  }
}
