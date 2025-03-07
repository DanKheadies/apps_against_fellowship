import 'package:apps_against_fellowship/app_af.dart';
import 'package:apps_against_fellowship/blocs/blocs.dart';
// import 'package:apps_against_fellowship/config/config.dart';
import 'package:apps_against_fellowship/cubits/cubits.dart';
import 'package:apps_against_fellowship/firebase_options.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:apps_against_fellowship/helpers/helpers.dart';
import 'package:apps_against_fellowship/services/services.dart';
// import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  // TODO (?)
  // Setup Push Notifications
  // Note: should initizlie when the cubit does. We'll see if that's a problem..
  // Can't seem to wire up the cubit as a "start-up" call. Going to implment
  // the "current" way to handle Firebase Messaging
  // TODO
  // FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  // Note: need to activate the Notifictions TODOs via ii-CC
  // Note: initializing a function here in the MultiBloc provider, i.e. ..init(),
  // won't trigger until the bloc is called, i.e. BlocBuilder, etc.
  // Once it's called, the function here and anything in the constructors workflow
  // will trigger, i.e. { init(); }
  // This is useful to run DeviceCubit and get token updates.
  // Note: AudioCubit initializes (successfully?) when the subsequent cubit/bloc
  // references it in the Multi hierarchy. Perhaps I should look to have
  // UsersBloc make a call to it and get the device info for the user?
  // Update: Yea DeviceCubit & AudioCubit don't kick off unless something calls
  // for them to be used. The Hydration runs (?)
  // Current guess: I'm serving up the flow of Blocs, Cubits, and Repos here.
  // It's not until I call them in some way, e.g. BlocBuilder, Listener, etc.,
  // that they come "online" and do stuff. So, how to best structure this so
  // that things like Device & Audio start from the get-go, but don't overload
  // or cause unnecessary rebuilds.

  // Bloc.observer = SimpleBlocObserver(); // Same as LoggingBlocDelegate

  runApp(const AppsAgainstFellowship());
}

class AppsAgainstFellowship extends StatelessWidget {
  const AppsAgainstFellowship({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: BlocProvider(
        create: (context) => CardCacheCubit(),
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
              create: (context) => CardsRepository(
                cardCache: context.read<CardCacheCubit>(),
              ),
            ),
            RepositoryProvider(
              create: (context) => AuthRepository(
                userRepository: context.read<UserRepository>(),
              ),
            ),
          ],
          // TODO:
          // 3) Locales
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => AudioCubit(), //..initializeAudio(),
              ),
              BlocProvider(
                create: (context) => AuthenticationCubit(),
              ),
              BlocProvider(
                create: (context) => DeviceCubit(
                  deviceRepository: context.read<DeviceRepository>(),
                  // )..setup(),
                ),
              ),
              BlocProvider(
                create: (context) => SettingsBloc(
                  appLifecycleNotifier:
                      context.read<AppLifecycleStateNotifier>(),
                  audioCubit: context.read<AudioCubit>(),
                ),
              ),
              BlocProvider(
                create: (context) => UserBloc(
                  // audioCubit: context.read<AudioCubit>(),
                  deviceCubit: context.read<DeviceCubit>(),
                  settingsBloc: context.read<SettingsBloc>(),
                  storageRepository: context.read<StorageRepository>(),
                  userRepository: context.read<UserRepository>(),
                ),
              ),
              BlocProvider(
                create: (context) => AuthBloc(
                  authRepository: context.read<AuthRepository>(),
                  userBloc: context.read<UserBloc>(),
                  userRepository: context.read<UserRepository>(),
                ),
              ),
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
            child: AppAF(),
          ),
        ),
      ),
    );
  }
}
