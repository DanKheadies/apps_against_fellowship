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

  runApp(const AppsAgainstFellowship());
}

class AppsAgainstFellowship extends StatelessWidget {
  const AppsAgainstFellowship({super.key});

  @override
  Widget build(BuildContext context) {
    // Setup ALO to track app state and initialize the provider tree.
    // TODO: while setting up a ProviderTree does work, it might be more
    // cumbersome than anything. The previous "smaller" bloc approach lets us
    // call the necessary provides only where needed. In a hydrated approach,
    // this should save on unnecessary setup, e.g. card cache cubit.
    // At a minimum, initializing anything needed for authorization should
    // remain here as a "core" wrapping. Then in the "MaterialApp.router"
    // setup, we can handle any other small, app-wide state, e.g. device cubit
    // and brightness (theme) cubit.
    return AppLifecycleObserver(
      // Initialize card cache
      // TODO: not sure if I need to do this here. It needs to be initialized so
      // Create Game Screen can check. I'm wondering if this is the "smaller
      // blocs" pattern helps, i.e. the only time we use the cache is when we
      // try to create a new game, so to avoid pulling a bunch of data from the
      // local storage, wait until we need it.
      // Update: fixed the Audio issue, and have insights on cloud-permission
      // issue(s) -> need to close out of all Sub/Streams when I sign-out.
      // Would be good to include in AuthBloc rather than as an additional call
      // out in the UI. Including in AuthBloc will require it here and instantiate.
      // Will basically have all Blocs w/ sub/streams initialized here, which
      // puts us back to square one--sorta. Would still be smart to slim down
      // where we can, e.g. CardCacheCubit, CardRepo, GameRepo & Bloc (?), etc.
      child: BlocProvider(
        create: (context) => CardCacheCubit(),
        child: MultiRepositoryProvider(
          providers: [
            // Needed for Auth
            RepositoryProvider(
              create: (context) => UserRepository(),
            ),
            // Needed for Auth
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
            // Needed for Auth
            RepositoryProvider(
              create: (context) => AuthRepository(
                userRepository: context.read<UserRepository>(),
              ),
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              // Needed for Auth (TBC)
              BlocProvider(
                create: (context) => AudioCubit(),
              ),
              // Needed for Auth
              BlocProvider(
                create: (context) => AuthenticationCubit(),
              ),
              BlocProvider(
                create: (context) => DeviceCubit(
                  deviceRepository: context.read<DeviceRepository>(),
                  // )..setup(), // TBD if this is the right spot
                ),
              ),
              // Needed for Auth (TBC)
              BlocProvider(
                create: (context) => SettingsBloc(
                  appLifecycleNotifier:
                      context.read<AppLifecycleStateNotifier>(),
                  audioCubit: context.read<AudioCubit>(),
                ),
              ),
              // Needed for Auth
              BlocProvider(
                create: (context) => UserBloc(
                  storageRepository: context.read<StorageRepository>(),
                  userRepository: context.read<UserRepository>(),
                ),
              ),
              // Needed for Auth
              BlocProvider(
                create: (context) => AuthBloc(
                  authRepository: context.read<AuthRepository>(),
                  settingsBloc: context.read<SettingsBloc>(),
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
            child: AppsAF(),
          ),
        ),
      ),
    );
  }
}
