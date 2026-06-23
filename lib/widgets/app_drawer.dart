import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';

  class AppNavigationDrawer extends StatelessWidget {
    const AppNavigationDrawer({super.key});

    @override
    Widget build(BuildContext context) {
      return Drawer(
        backgroundColor: const Color(0xFF111111),
        width: MediaQuery.of(context).size.width * 0.78,
        child: SafeArea(
          child: Column(
            children: [
              // Logo + Version header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                color: const Color(0xFF111111),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF08C7D6), Color(0xFF007B87)],
                        ),
                      ),
                      child: const Icon(
                        Icons.live_tv_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Version: 3.0',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF222222), height: 1),
              const SizedBox(height: 8),
              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _item(context, Icons.cast_connected_rounded, 'Network Stream', () {}),
                    _item(context, Icons.playlist_add_rounded, 'Playlists', () {}),
                    _item(context, Icons.play_circle_outline_rounded, 'Highlights', () {}),
                    _item(context, Icons.picture_in_picture_alt_rounded, 'Floating Player', () {}),
                    _item(context, Icons.settings_rounded, 'Force Low Quality', () {}),
                    _item(context, Icons.sports_cricket_rounded, 'Cricket Score', () {}),
                    _item(context, Icons.sports_soccer_rounded, 'Football Score', () {}),
                    _item(context, Icons.send_rounded, 'Telegram', () {}),
                    _item(context, Icons.language_rounded, 'Website', () {}),
                    const Divider(color: Color(0xFF222222), height: 24),
                    _item(
                      context,
                      Icons.exit_to_app_rounded,
                      'Exit',
                      () {
                        Navigator.pop(context);
                        SystemNavigator.pop();
                      },
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _item(BuildContext ctx, IconData icon, String label, VoidCallback onTap, {Color? color}) {
      final c = color ?? Colors.white;
      return InkWell(
        onTap: () {
          Navigator.pop(ctx);
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: c, size: 22),
              const SizedBox(width: 18),
              Text(label, style: TextStyle(color: c, fontSize: 15)),
            ],
          ),
        ),
      );
    }
  }
  