import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/auth_service.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/auth/auth_gate.dart';
import 'core/services/user_service.dart';
import 'core/services/notification_service.dart';
import 'features/favorites/cubit/favorites_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'features/splash/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService().init();
  } catch (e) {
    print('تنبيه: لم يتم العثور على إعدادات Firebase. هل قمت بتنفيذ flutterfire configure؟');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthService()),
        RepositoryProvider(create: (context) => UserService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(
              authService: context.read<AuthService>(),
            ),
          ),
          BlocProvider(create: (context) => FavoritesCubit()),
          BlocProvider(create: (context) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'صحة +',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
