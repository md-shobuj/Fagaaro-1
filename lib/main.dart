import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/router/app_router.dart';
import 'core/theme/pgb_theme.dart';
import 'core/di/injection_container.dart';
import 'features/geofence/data/services/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment configuration file
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('[Bootstrap] .env config load failed. Falling back to build environment variables.');
  }

  // Initialize Dependency Injection container (resolves SharedPreferences async)
  await initDI();

  // Setup global error tracking boundaries (ready to hook with Firebase Crashlytics)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // TODO: FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    debugPrint('[Fatal Error] ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    // TODO: FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    debugPrint('[PlatformDispatcher Error] $error\n$stack');
    return true;
  };

  // Initialize notifications platform specific setups
  await sl<NotificationHelper>().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(328, 720),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Fagaaro App',
          themeMode: ThemeMode.system,
          theme: PgbTheme.lightTheme,
          darkTheme: PgbTheme.darkTheme,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
