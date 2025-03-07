import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/config/config.dart';
import 'package:apps_against_fellowship/cubits/cubits.dart';
// import 'package:apps_against_fellowship/repositories/repositories.dart';
// import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppAF extends StatefulWidget {
  const AppAF({super.key});

  @override
  State<AppAF> createState() => _AppAFState();
}

class _AppAFState extends State<AppAF> {
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
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: goRouter,
          theme: state.user.isDarkTheme ? darkTheme() : lightTheme(),
        );
      },
    );
  }
}
