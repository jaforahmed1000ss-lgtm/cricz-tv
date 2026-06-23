import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:media_kit/media_kit.dart';
  import 'services/notification_service.dart';
  import 'screens/splash_screen.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    MediaKit.ensureInitialized();
    await NotificationService.init();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    runApp(const CricZTVApp());
  }

  class CricZTVApp extends StatelessWidget {
    const CricZTVApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CricZ TV',
        theme: ThemeData.dark().copyWith(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF000000),
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF00D2FF),
            secondary: const Color(0xFFFF4081),
            surface: const Color(0xFF050B0F),
            onSurface: Colors.white,
            surfaceContainerHighest: const Color(0xFF0A1219),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF000000),
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF050B0F),
            selectedItemColor: Color(0xFF00D2FF),
            unselectedItemColor: Colors.white38,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color(0xFF0A1825),
            contentTextStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        home: const SplashScreen(),
      );
    }
  }
  