import 'package:apps_against_fellowship/blocs/blocs.dart';
// import 'package:apps_against_fellowship/models/models.dart';
// import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool creatingGod = false;
  final TextEditingController displayNameController = TextEditingController();

  @override
  void dispose() {
    displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      screen: 'Profile',
      goBackTo: 'home',
      canScroll: false,
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state.userStatus == UserStatus.initial ||
              state.userStatus == UserStatus.loading ||
              creatingGod) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state.userStatus == UserStatus.loaded ||
              state.userStatus == UserStatus.photoUpload) {
            return ListView(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 32,
                  ),
                  child: Column(
                    children: [
                      ProfileTextField(
                        label: 'Name',
                        content: state.user.name == '' ? '' : state.user.name,
                        width: MediaQuery.of(context).size.width - 50,
                        onSubmit: (value) {
                          context.read<UserBloc>().add(
                                UpdateUser(
                                  updateFirebase: true,
                                  user: state.user.copyWith(
                                    name: value,
                                  ),
                                ),
                              );
                        },
                      ),
                      const ProfilePhoto(),
                      // const SizedBox(height: 50),
                      // TextButton(
                      //   child: Text('Create God Usopp'),
                      //   onPressed: () async {
                      //     setState(() {
                      //       creatingGod = true;
                      //     });
                      //     await context
                      //         .read<UserRepository>()
                      //         .createAGod(godUsopp);
                      //     setState(() {
                      //       creatingGod = false;
                      //     });
                      //   },
                      // ),
                    ],
                  ),
                ),
              ],
            );
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
