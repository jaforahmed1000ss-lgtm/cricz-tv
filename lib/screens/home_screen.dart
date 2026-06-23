import 'package:flutter/material.dart';
  import '../widgets/app_drawer.dart';
  import '../services/firestore_service.dart';
  import '../models/channel_model.dart';
  import 'player_screen.dart';
  import 'channels_screen.dart';
  import 'categories_screen.dart';
  import 'matches_screen.dart';
  import 'favorites_screen.dart';
  import 'admin_screen.dart';

  class MainNavigationHub extends StatefulWidget {
    const MainNavigationHub({super.key});

    @override
    State<MainNavigationHub> createState() => _MainNavigationHubState();
  }

  class _MainNavigationHubState extends State<MainNavigationHub> {
    int _idx = 0;

    final List<Widget> _screens = const [
      MatchesScreen(),
      ChannelsScreen(),
      CategoriesScreen(),
      FavoritesScreen(),
    ];

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: IndexedStack(index: _idx, children: _screens),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF050B0F),
            border: const Border(top: BorderSide(color: Color(0xFF0E161B), width: 1.5)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 24, offset: const Offset(0, -6)),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 64,
              child: Row(children: [
                _NavItem(icon: Icons.stadium_rounded, label: 'Live Events', selected: _idx == 0, onTap: () => setState(() => _idx = 0)),
                _NavItem(icon: Icons.live_tv_rounded, label: 'Sports', selected: _idx == 1, onTap: () => setState(() => _idx = 1)),
                _NavItem(icon: Icons.grid_view_rounded, label: 'Categories', selected: _idx == 2, onTap: () => setState(() => _idx = 2)),
                _NavItem(icon: Icons.favorite_rounded, label: 'Favorites', selected: _idx == 3, onTap: () => setState(() => _idx = 3), activeColor: const Color(0xFFFF4081)),
              ]),
            ),
          ),
        ),
      );
    }
  }

  class _NavItem extends StatelessWidget {
    final IconData icon;
    final String label;
    final bool selected;
    final VoidCallback onTap;
    final Color? activeColor;

    const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap, this.activeColor});

    @override
    Widget build(BuildContext context) {
      final color = selected ? (activeColor ?? const Color(0xFF00D2FF)) : Colors.white30;
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? color.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
            ]),
          ),
        ),
      );
    }
  }
  