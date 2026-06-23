import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2500)),
      FirestoreService.seedDefaultChannels(),
    ]);
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainNavigationHub()));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.of(context).size.width * 0.45;
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: sz,
              height: sz,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00A8C5), Color(0xFF000535)]),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF00A8C5).withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 5)
                ],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.live_tv, color: Colors.white, size: sz * 0.3),
                const SizedBox(height: 8),
                Text('CricZ TV',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: sz * 0.18,
                        letterSpacing: 1.2)),
                Text('LIVE SPORTS',
                    style: TextStyle(
                        color: Colors.white60,
                        fontSize: sz * 0.09,
                        letterSpacing: 2)),
              ]),
            ),
            const SizedBox(height: 32),
            const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(color: Color(0xFF00D2FF), strokeWidth: 2.5)),
            const SizedBox(height: 12),
            const Text('Loading channels...', style: TextStyle(color: Colors.white38, fontSize: 13)),
          ]),
        ),
      ),
    );
  }
}
