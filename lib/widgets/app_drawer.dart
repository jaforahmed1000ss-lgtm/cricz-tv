import 'package:flutter/material.dart';
import '../screens/channels_screen.dart';
import '../screens/matches_screen.dart';
import '../screens/admin_screen.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF030A0F),
      width: MediaQuery.of(context).size.width * 0.78,
      child: Column(children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 58, 20, 26),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF002535), Color(0xFF000E16)],
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D2FF), Color(0xFF0055CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D2FF).withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 38),
            ),
            const SizedBox(height: 14),
            const Text('CricZ TV',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.4)),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.circle, color: Colors.red, size: 6),
                  SizedBox(width: 4),
                  Text('LIVE', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(width: 8),
              const Text('Sports Streaming',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
          ]),
        ),

        // Menu Items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Text('MENU',
                    style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
              ),
              _DrawerTile(
                icon: Icons.stadium_rounded,
                title: 'Live Events',
                subtitle: 'FIFA & Cricket matches',
                color: const Color(0xFF00D2FF),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MatchesScreen()));
                },
              ),
              _DrawerTile(
                icon: Icons.sports_soccer_rounded,
                title: 'FIFA 2026',
                subtitle: 'World Cup channels',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const ChannelsScreen(filterCategory: 'FIFA 2026')));
                },
              ),
              _DrawerTile(
                icon: Icons.sports_cricket_rounded,
                title: 'Cricket Live',
                subtitle: 'Star Sports, T Sports & more',
                color: const Color(0xFF00BCD4),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const ChannelsScreen(filterCategory: 'Cricket')));
                },
              ),
              _DrawerTile(
                icon: Icons.sports_rounded,
                title: 'All Sports',
                subtitle: 'Browse all channels',
                color: const Color(0xFFFF9800),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ChannelsScreen()));
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(color: Color(0xFF0E1C26), height: 1),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 6),
                child: Text('OTHER',
                    style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
              ),
              _DrawerTile(
                icon: Icons.admin_panel_settings_rounded,
                title: 'Admin Panel',
                subtitle: 'Manage channels & streams',
                color: Colors.white38,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
                },
              ),
            ],
          ),
        ),

        // Footer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFF0A1219), width: 1)),
          ),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.live_tv_rounded, color: Color(0xFF00D2FF), size: 14),
            SizedBox(width: 6),
            Text('CricZ TV  v2.0.0',
                style: TextStyle(color: Colors.white24, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Colors.white30, fontSize: 11)),
      onTap: onTap,
    );
  }
}
