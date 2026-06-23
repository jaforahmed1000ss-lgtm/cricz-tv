import 'package:flutter/material.dart';
  import 'home_screen.dart';

  class SplashScreen extends StatefulWidget {
    const SplashScreen({super.key});
    @override
    State<SplashScreen> createState() => _SplashScreenState();
  }

  class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
    late AnimationController _ctrl;
    late Animation<double> _fade;

    @override
    void initState() {
      super.initState();
      _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
      _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
      _ctrl.forward();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      });
    }

    @override
    void dispose() {
      _ctrl.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D2FF), Color(0xFF0066FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
                ),
                const SizedBox(height: 24),
                const Text(
                  'CricZ TV',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Live Sports Streaming',
                  style: TextStyle(fontSize: 16, color: Color(0xFF00D2FF)),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D2FF)),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  