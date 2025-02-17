import 'package:cloud_functions/cloud_functions.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';

class HelpDialog extends StatefulWidget {
  const HelpDialog({super.key});

  @override
  State<HelpDialog> createState() => _HelpDialogState();

  static Future<void> openHelpDialog(
    BuildContext context,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => HelpDialog(),
    );
  }
}

class _HelpDialogState extends State<HelpDialog> {
  bool canSend = false;
  bool clearInput = false;
  bool isSending = false;
  String email = '';
  String message = '';

  @override
  void initState() {
    super.initState();
    if (context.read<UserBloc>().state.user.email != '') {
      setState(() {
        email = context.read<UserBloc>().state.user.email;
      });
    }
  }

  void clearInputs() async {
    setState(() {
      clearInput = true;
      canSend = false;
      email = '';
      message = '';
    });

    Future.delayed(
        const Duration(
          milliseconds: 100,
        ), () {
      setState(() {
        clearInput = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const double outerPadding = 25;
    return Dialog(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: outerPadding,
          right: outerPadding,
          top: outerPadding,
          bottom: outerPadding / 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 3,
              child: Text(
                'Contact Support',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 1),
            Flexible(
              flex: 5,
              child: CustomInput(
                clearText: clearInput,
                initialValue: email,
                isMulti: false,
                labelText: 'Email',
                onChanged: (value) {
                  if (value != '' && message != '') {
                    setState(() {
                      canSend = true;
                      email = value;
                    });
                  } else {
                    setState(() {
                      canSend = false;
                      email = value;
                    });
                  }
                },
                onEnter: (_) {},
              ),
            ),
            const Spacer(flex: 1),
            Flexible(
              flex: 5,
              child: CustomInput(
                clearText: clearInput,
                isMulti: true,
                labelText: 'Message',
                onChanged: (value) {
                  if (value != '' && email != '') {
                    setState(() {
                      canSend = true;
                      message = value;
                    });
                  } else {
                    setState(() {
                      canSend = false;
                      message = value;
                    });
                  }
                },
                onEnter: (_) {},
              ),
            ),
            const Spacer(flex: 1),
            Flexible(
              flex: 5,
              child: isSending
                  ? CircularProgressIndicator()
                  : TextButton(
                      onPressed: canSend
                          ? () async {
                              print('submit');
                              await submit(context);
                            }
                          : null,
                      child: Text(
                        'Send',
                        style: TextStyle(
                          color: canSend
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onTertiary,
                          fontSize: 18,
                        ),
                      ),
                    ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Future<void> submit(
    BuildContext context,
  ) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    setState(() {
      isSending = true;
    });

    var scaffCont = ScaffoldMessenger.of(context);
    if (EmailValidator.validate(email)) {
      try {
        await FirebaseFunctions.instance.httpsCallable('contactMessage').call(
          {
            'email': email,
            'message': message,
          },
        );

        scaffCont
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Your email has been sent.',
              ),
            ),
          );

        clearInputs();
      } on FirebaseFunctionsException catch (error) {
        print('error: $error');
      } catch (err) {
        print('err: $err');
      }
    } else {
      scaffCont
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Enter a valid email.',
            ),
          ),
        );
    }

    setState(() {
      isSending = false;
    });
  }
}
