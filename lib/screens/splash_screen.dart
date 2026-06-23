import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _scaleCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut));
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _fadeCtrl.forward();
    _scaleCtrl.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _pulseCtrl.forward();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // Background glow
        Center(
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Transform.scale(
              scale: _pulse.value,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D2FF).withOpacity(0.08),
                      blurRadius: 120,
                      spreadRadius: 60,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                // Logo container
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D2FF), Color(0xFF0055CC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D2FF).withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Stack(alignment: Alignment.center, children: [
                      // Cricket ball hint
                      Positioned(
                        top: 18, right: 18,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.sports_cricket, color: Colors.white, size: 13),
                          ),
                        ),
                      ),
                      // Football hint
                      Positioned(
                        bottom: 18, left: 18,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.sports_soccer, color: Colors.white, size: 13),
                          ),
                        ),
                      ),
                      // Main play icon
                      const Icon(Icons.play_circle_filled_rounded,
                          color: Colors.white, size: 72),
                    ]),
                  ),
                ),
                const SizedBox(height: 28),
                // CricZ
                const Text('CricZ',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3)),
                // TV in teal
                const Text('TV',
                    style: TextStyle(
                        color: Color(0xFF00D2FF),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                        height: 1)),
                const SizedBox(height: 10),
                // Tagline
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: const Text('Live Sports Streaming',
                      style: TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 1)),
                ),
                const SizedBox(height: 60),
                // Loading indicator
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF00D2FF)),
                    strokeWidth: 2.5,
                    backgroundColor: Colors.white.withOpacity(0.08),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Loading...',
                    style: TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 0.5)),
              ]),
            ),
          ),
        ),
        // Bottom version
        Positioned(
          bottom: 28,
          left: 0,
          right: 0,
          child: FadeTransition(
            opacity: _fade,
            child: const Text('v2.0.0 • CricZ TV',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white12, fontSize: 11)),
          ),
        ),
      ]),
    );
  }
}
