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
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF08C7D6),
            secondary: Color(0xFF08C7D6),
            surface: Color(0xFF0D0D0D),
            onSurface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF0D0D0D),
            selectedItemColor: Color(0xFF08C7D6),
            unselectedItemColor: Colors.white38,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 11),
          ),
        ),
        home: const SplashScreen(),
      );
    }
  }
  