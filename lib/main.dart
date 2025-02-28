import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/config/config.dart';
import 'package:apps_against_fellowship/cubits/cubits.dart';
import 'package:apps_against_fellowship/firebase_options.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:firebase_core/firebase_core.dart';
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

  // Bloc.observer = SimpleBlocObserver(); // Same as LoggingBlocDelegate

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
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
            create: (context) => DevicesRepository(),
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
              create: (context) => AuthenticationCubit(),
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
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: goRouter,
                theme: state.user.isDarkTheme ? darkTheme() : lightTheme(),
              );
            },
          ),
        ),
      ),
    );
  }
}
