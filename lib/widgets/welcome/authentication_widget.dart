import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/cubits/cubits.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Authentication extends StatefulWidget {
  final bool isRegister;

  const Authentication({
    super.key,
    required this.isRegister,
  });

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  bool isResetting = false;
  bool showPassword = false;
  bool validEmail = false;
  bool validPassword = false;
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  TextEditingController emailCont = TextEditingController();
  TextEditingController nameCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailCont.text = context.read<AuthenticationCubit>().state.email;
  }

  @override
  void dispose() {
    emailCont.dispose();
    nameCont.dispose();
    passwordCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, state) {
        bool canSend = (!widget.isRegister &&
                validEmail &&
                passwordCont.text != '') ||
            (widget.isRegister &&
                (context.read<AuthenticationCubit>().state.isRegisterValid &&
                    validPassword));

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 25,
            left: 20,
            right: 20,
            top: 25,
          ),
          child: Column(
            children: [
              widget.isRegister
                  ? SizedBox(
                      width: 400,
                      child: CustomTextField(
                        label: 'Name',
                        cont: nameCont,
                        onChange: (value) {
                          context
                              .read<AuthenticationCubit>()
                              .nameChanged(value);
                        },
                        onEditComplete: () {
                          _checkEmail(context);
                          _closeKeyboard();
                        },
                      ),
                    )
                  : const SizedBox(),
              SizedBox(
                height: widget.isRegister ? 15 : 0,
                width: double.infinity,
              ),
              SizedBox(
                width: 400,
                child: Focus(
                  // onKey: (focusNode, event) {
                  //   if (event.logicalKey == LogicalKeyboardKey.tab) {
                  //     _checkEmail(context);
                  //   }
                  //   return KeyEventResult.ignored;
                  // },
                  onKeyEvent: (node, event) {
                    if (event.logicalKey == LogicalKeyboardKey.tab) {
                      _checkEmail(context);
                    }
                    return KeyEventResult.ignored;
                  },
                  child: CustomTextField(
                    label: 'Email',
                    cont: emailCont,
                    focusNode: emailFocus,
                    onChange: (value) {
                      context.read<AuthenticationCubit>().emailChanged(value);
                    },
                    onEditComplete: () {
                      _checkEmail(context);
                      _closeKeyboard();
                    },
                    // Note: disable to allow scroll
                    onTapOutside: (value) {
                      if (emailFocus.hasFocus) {
                        _checkEmail(context);
                        _closeKeyboard();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 95,
                    child: CustomTextField(
                      label: 'Password',
                      cont: passwordCont,
                      focusNode: passwordFocus,
                      obscure: showPassword ? false : true,
                      onChange: (value) {
                        context
                            .read<AuthenticationCubit>()
                            .passwordChanged(value);
                      },
                      onEditComplete: !validEmail ||
                              state.password == '' ||
                              (widget.isRegister && !validPassword)
                          ? null
                          : () {
                              if (widget.isRegister) {
                                context.read<AuthBloc>().add(
                                      RegisterWithEmailAndPassword(
                                        // area: state.area,
                                        email: state.email,
                                        name: state.name,
                                        password: state.password,
                                      ),
                                    );
                              } else {
                                context.read<AuthBloc>().add(
                                      LoginWithEmailAndPassword(
                                        email: state.email,
                                        password: state.password,
                                      ),
                                    );
                              }
                            },
                      onTap: () {
                        if (!validEmail) {
                          _checkEmail(context);
                        }
                      },
                      // Note: disable to allow scroll
                      onTapOutside: (value) {
                        if (passwordFocus.hasFocus) {
                          _checkEmail(context);
                          _closeKeyboard();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () => setState(() {
                      showPassword = !showPassword;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              widget.isRegister
                  ? FlutterPwValidator(
                      controller: passwordCont,
                      minLength: 8,
                      uppercaseCharCount: 1,
                      numericCharCount: 1,
                      specialCharCount: 1,
                      defaultColor: Theme.of(context).colorScheme.surface,
                      failureColor: Theme.of(context).colorScheme.error,
                      successColor: Theme.of(context).colorScheme.surface,
                      width: 400,
                      height: 150,
                      onSuccess: () {
                        if (!validPassword) {
                          setState(() {
                            validPassword = true;
                          });
                        }
                      },
                      onFail: () {
                        if (validPassword) {
                          setState(() {
                            validPassword = false;
                          });
                        }
                      },
                    )
                  : const SizedBox(),
              widget.isRegister
                  ? const SizedBox()
                  : isResetting
                      ? const CircularProgressIndicator()
                      : TextButton(
                          onPressed: () async {
                            var scaffCont = ScaffoldMessenger.of(context);

                            if (!validEmail) {
                              scaffCont
                                ..clearSnackBars()
                                ..showSnackBar(
                                  const SnackBar(
                                    duration: Duration(seconds: 3),
                                    content: Text('Enter a valid email.'),
                                  ),
                                );
                            } else {
                              setState(() {
                                isResetting = true;
                              });
                              try {
                                await context
                                    .read<AuthRepository>()
                                    .resetPassword(email: emailCont.text);

                                scaffCont
                                  ..clearSnackBars()
                                  ..showSnackBar(
                                    const SnackBar(
                                      duration: Duration(seconds: 3),
                                      content: Text(
                                        'A password reset was sent to the email provided.',
                                      ),
                                    ),
                                  );
                              } catch (err) {
                                print(err);
                                scaffCont
                                  ..clearSnackBars()
                                  ..showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 3),
                                      content: Text('There was an error: $err'),
                                    ),
                                  );
                              }
                              setState(() {
                                isResetting = false;
                              });
                            }
                          },
                          child: const Text('Reset Password'),
                        ),
              const SizedBox(height: 50),
              HomeOutlineButton(
                icon: Icon(
                  widget.isRegister ? MdiIcons.creation : MdiIcons.login,
                  color: canSend
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                ),
                text: widget.isRegister ? 'Register' : 'Login',
                borderColor: canSend
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                textColor: canSend
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                onTap: canSend
                    ? () {
                        if (widget.isRegister) {
                          context.read<AuthBloc>().add(
                                RegisterWithEmailAndPassword(
                                  email: state.email,
                                  name: state.name,
                                  password: state.password,
                                ),
                              );
                        } else {
                          context.read<AuthBloc>().add(
                                LoginWithEmailAndPassword(
                                  email: state.email,
                                  password: state.password,
                                ),
                              );
                        }
                      }
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  void _checkEmail(BuildContext context) {
    var email = context.read<AuthenticationCubit>().state.email;

    if (EmailValidator.validate(email)) {
      setState(() {
        validEmail = true;
      });
    } else {
      if (email != '') {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text("Enter a valid email."),
            ),
          );
      }

      setState(() {
        validEmail = false;
      });
    }
  }

  void _closeKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
