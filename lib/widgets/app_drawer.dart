import 'package:flutter/material.dart';
import '../screens/channels_screen.dart';
import '../screens/matches_screen.dart';
import '../screens/admin_screen.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF050B0F),
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF003D52), Color(0xFF00151E)],
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00D2FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.4)),
              ),
              child: const Icon(Icons.live_tv, color: Color(0xFF00D2FF), size: 32),
            ),
            const SizedBox(height: 12),
            const Text('CricZ TV',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
            const Text('Live Sports Streaming',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _tile(context, Icons.stadium, 'Match Schedule', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MatchesScreen()));
              }),
              _tile(context, Icons.sports_soccer, 'FIFA 2026 Live', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const ChannelsScreen(filterCategory: 'FIFA 2026')));
              }),
              _tile(context, Icons.sports_cricket, 'Cricket Live', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const ChannelsScreen(filterCategory: 'Cricket')));
              }),
              _tile(context, Icons.sports, 'All Sports', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ChannelsScreen()));
              }),
              const Divider(color: Color(0xFF0E1C26), thickness: 1, indent: 16, endIndent: 16),
              _tile(context, Icons.admin_panel_settings, 'Admin Panel', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
              }, color: Colors.white38),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            const Text('LIVE', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            const Text('CricZ TV v1.0', style: TextStyle(color: Colors.white24, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, VoidCallback onTap,
      {Color color = const Color(0xFF00D2FF)}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }
}
