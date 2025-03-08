import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/config/config.dart';
import 'package:apps_against_fellowship/cubits/cubits.dart';
import 'package:apps_against_fellowship/services/services.dart';
// import 'package:apps_against_fellowship/repositories/repositories.dart';
// import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppsAF extends StatefulWidget {
  const AppsAF({super.key});

  @override
  State<AppsAF> createState() => _AppsAFState();
}

class _AppsAFState extends State<AppsAF> {
  bool isDarkTheme = false;
  @override
  Widget build(BuildContext context) {
    // TODO: is there a better way to initilize the deviceCubit for token info
    // Don't expect it to trigger much, but see what Hydration does, i.e. print
    // return BlocBuilder<DeviceCubit, DeviceState>(
    //   builder: (context, state) {
    //     // print('deviceCubit builder');
    //     // Wrap w/ BrightnessCubit or UserBloc to cover theme changes.
    //     return BlocBuilder<UserBloc, UserState>(
    //       builder: (context, state) {
    //         return MaterialApp.router(
    //           debugShowCheckedModeBanner: false,
    //           routerConfig: goRouter,
    //           theme: state.user.isDarkTheme ? darkTheme() : lightTheme(),
    //         );
    //         // return PushNavigator(
    //         //   context: context,
    //         //   gameBloc: context.read<GameBloc>(),
    //         //   gameRepository: context.read<GameRepository>(),
    //         //   userBloc: context.read<UserBloc>(),
    //         //   child: MaterialApp.router(
    //         //     debugShowCheckedModeBanner: false,
    //         //     routerConfig: goRouter,
    //         //     theme: state.user.isDarkTheme ? darkTheme() : lightTheme(),
    //         //   ),
    //         // );
    //       },
    //     );
    //   },
    // );
    // TODO: see if DeviceCubit Hydration runs when not called as a builder.
    // Update: it runs now that it's called in UserBloc and setup is called in
    // the constructor.
    // return MultiBlocListener(
    //   listeners: [],
    //   // TODO: change this from the UserState that rebuilds to Brightness cubit
    //   // Note: test if this runs when ONLY the theme changes
    //   // Could be a Listener/Builder combo that only triggers when
    //   child: BlocBuilder<UserBloc, UserState>(
    //     builder: (context, state) {
    //       print('build user bloc in the AppsAF');
    //       return MaterialApp.router(
    //         // TODO: Locales
    //         debugShowCheckedModeBanner: false,
    //         routerConfig: goRouter,
    //         theme: state.user.isDarkTheme ? darkTheme() : lightTheme(),
    //       );
    //     },
    //   ),
    // );
    // TODO: instantiate MultiBlocListener for AuthBloc (nav), Brightness, and
    // device (id & token, etc). TBD: where to stick audio/settings... It should
    // prob be instantiated here, i.e. we need to create one instance but not
    // activate it until the user is logged in. Also, they should be able to
    // change the Brightness, and once they're authenticated, the theme is
    // constructed from their UserBloc, which is informed by local storage of
    // Brightness cubit.
    // Update: Don't appear to need listners here like i thought, i.e. GoRouter
    // and device / theme / user structural changes. Going for a simple BlocBuild
    // via DeviceCubit for now.
    // TBD: does it rebuild / "kick" when it gets the token the first time?
    return MultiBlocListener(
      listeners: [
        // // Handle authentication and additional navigation
        // BlocListener<AuthBloc, AuthState>(
        //   // listenWhen: (previous, current) =>
        //   //     current.authUser != previous.authUser,
        //   // listener: (context, state) => authenticationNavigator(
        //   //   context,
        //   //   state,
        //   // ),
        //   listener: authenticationNavigator,
        //   // Ahhh.. It seems like GoRouter doesn't activate until below, i.e.
        //   // it's not in context, so it fails in the above function.
        //   // Might need to keep AuthenticationNavigation with ScreenWrapper...
        //   // Yup, not workable here.
        // ),

        // Handle...
        // BlocListener(listener: listener)...
        BlocListener<SettingsBloc, SettingsState>(
          listener: (context, state) => {print('INSTA APPS AF ')},
          // Interesting.. this is initializing SettingsBloc and the subsequent
          // AppLifecycleNotifier. Any time I leave the app and come back,
          // audioCubit starts/resumes music, which triggers the playCurrentSong,
          // but the handleSongFinished doesn't trigger, i.e. no loop, because
          // I haven't initializedAudio in AudioCubit, which handles the music
          // player onComplete stream.
        ),

        // Handle theme changes
        // _listenForThemeChange(),
      ],
      // child: BlocBuilder<UserBloc, UserState>(
      //   builder: (context, state) {
      //     print('build user bloc in the AppsAF');
      //     return MaterialApp.router(
      //       // TODO: Locales
      //       debugShowCheckedModeBanner: false,
      //       routerConfig: goRouter,
      //       // theme: state.user.isDarkTheme ? darkTheme() : lightTheme(),
      //       theme: context.read<UserBloc>().state.user.isDarkTheme
      //           ? darkTheme()
      //           : lightTheme(),
      //     );
      //   },
      // ),
      // child: MaterialApp.router(
      //   // TODO: Locales
      //   debugShowCheckedModeBanner: false,
      //   routerConfig: goRouter,
      //   // theme: state.user.isDarkTheme ? darkTheme() : lightTheme(),
      //   theme: isDarkTheme ? darkTheme() : lightTheme(),
      // ),
      child: BlocBuilder<DeviceCubit, DeviceState>(
        builder: (context, state) {
          print('apps af - bloc builder device cubit');
          return MaterialApp.router(
            // TODO: Locales
            debugShowCheckedModeBanner: false,
            routerConfig: goRouter,
            // theme: state.user.isDarkTheme ? darkTheme() : lightTheme(),
            theme: state.isDarkTheme ? darkTheme() : lightTheme(),
          );
        },
      ),
    );
  }

  // Note: this approach doesn't cover ALL aspects of the change, i.e. the icon
  // doesn't update as it should. Probably best to just keep as a BlocBuilder
  // but change to BrightnessCubit. The theme should be driven by the device
  // rather than the user.
  // Probably should just add Brightness to DeviceCubit
  // BlocListener _listenForThemeChange() {
  //   return BlocListener<UserBloc, UserState>(
  //     listenWhen: (previous, current) =>
  //         previous.user.isDarkTheme != current.user.isDarkTheme,
  //     listener: (context, state) {
  //       print('state changed!');
  //       print(state);
  //       setState(() {
  //         isDarkTheme = state.user.isDarkTheme;
  //       });
  //     },
  //   );
  // }
}
