import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_translate/flutter_translate.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
// import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/config/config.dart';
import 'package:apps_against_fellowship/firebase_options.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
// import 'package:apps_against_fellowship/simple_bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO (?)
  // App Preferences

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getTemporaryDirectory(),
  );

  // TODO: is logger needed (?)
  // Setup logger
  // Logger.root.level = Level.ALL;
  // Logger.root.onRecord.listen((LogRecord rec) {
  //   print('${rec.level.name}: ${rec.time}: ${rec.message}');
  // });

  // TODO (?)
  // Setup Push Notifications

  // Bloc.observer = SimpleBlocObserver(); // Same as LoggingBlocDelegate

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => DatabaseRepository(),
        ),
        RepositoryProvider(
          create: (context) => StorageRepository(),
        ),
        RepositoryProvider(
          create: (context) => AuthRepository(
            databaseRepository: context.read<DatabaseRepository>(),
          ),
        ),
      ],
      // TODO:
      // 2) Themes; w/ state
      // 3) Locales
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              databaseRepository: context.read<DatabaseRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => UserBloc(
              databaseRepository: context.read<DatabaseRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          // theme: state == Brightness.dark ? darkTheme() : lightTheme(),
          routerConfig: goRouter,
        ),
      ),
    );
  }
}
