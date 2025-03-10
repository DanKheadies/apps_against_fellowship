import 'package:apps_against_fellowship/config/config.dart';
import 'package:apps_against_fellowship/cubits/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// TODO: consider moving back into main.dart
class AppsAF extends StatelessWidget {
  const AppsAF({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceCubit, DeviceState>(
      builder: (context, state) {
        print('apps af - bloc builder device cubit');
        return MaterialApp.router(
          // TODO: Locales
          debugShowCheckedModeBanner: false,
          routerConfig: goRouter,
          theme: state.isDarkTheme ? darkTheme() : lightTheme(),
        );
      },
    );
  }
}
