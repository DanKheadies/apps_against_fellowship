import 'package:apps_against_fellowship/apps_af.dart';
import 'package:apps_against_fellowship/blocs/blocs.dart';
// import 'package:apps_against_fellowship/config/config.dart';
import 'package:apps_against_fellowship/cubits/cubits.dart';
import 'package:apps_against_fellowship/firebase_options.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:apps_against_fellowship/helpers/helpers.dart';
// import 'package:apps_against_fellowship/services/services.dart';
// import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_translate/flutter_translate.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  // TODO: is logger needed (?)
  // Update: helps print "prettier" log entries; not necessary but N2H
  // Setup logger
  // Logger.root.level = Level.ALL;
  Logger.level = Level.all;
  // Logger.root.onRecord.listen((LogRecord rec) {
  //   print('${rec.level.name}: ${rec.time}: ${rec.message}');
  // });
  Logger.addLogListener((rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  SystemChannels.textInput.invokeMethod('TextInput.hide');

  // Setup Push Notifications
  // TODO
  // FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  // Bloc.observer = SimpleBlocObserver(); // Same as LoggingBlocDelegate

  // Google for Web

  runApp(const AppsAgainstFellowship());
}

class AppsAgainstFellowship extends StatelessWidget {
  const AppsAgainstFellowship({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => UserRepository(),
          ),
          RepositoryProvider(
            create: (context) => StorageRepository(),
          ),
          RepositoryProvider(
            create: (context) => GameRepository(
              userRepository: context.read<UserRepository>(),
            ),
          ),
          RepositoryProvider(
            create: (context) => DeviceRepository(),
          ),
          RepositoryProvider(
            create: (context) => AuthRepository(
              userRepository: context.read<UserRepository>(),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AudioCubit(),
            ),
            BlocProvider(
              create: (context) => AuthenticationCubit(),
            ),
            BlocProvider(
              create: (context) => DeviceCubit(
                deviceRepository: context.read<DeviceRepository>(),
              ),
            ),
            BlocProvider(
              create: (context) => SettingsBloc(
                appLifecycleNotifier: context.read<AppLifecycleStateNotifier>(),
                audioCubit: context.read<AudioCubit>(),
              ),
            ),
            BlocProvider(
              create: (context) => UserBloc(
                storageRepository: context.read<StorageRepository>(),
                userRepository: context.read<UserRepository>(),
              ),
            ),
            BlocProvider(
              create: (context) => AuthBloc(
                authRepository: context.read<AuthRepository>(),
                settingsBloc: context.read<SettingsBloc>(),
                userBloc: context.read<UserBloc>(),
                userRepository: context.read<UserRepository>(),
              ),
            ),
            // Note: need to not be linked to AuthBloc b/c of sub/stream using
            // user.id
            BlocProvider(
              create: (context) => GameBloc(
                authRepository: context.read<AuthRepository>(),
                gameRepository: context.read<GameRepository>(),
                userBloc: context.read<UserBloc>(),
              ),
            ),
            BlocProvider(
              create: (context) => HomeBloc(
                gameRepository: context.read<GameRepository>(),
                userBloc: context.read<UserBloc>(),
              ),
            ),
          ],
          child: AppsAF(),
        ),
      ),
    );
  }
}
