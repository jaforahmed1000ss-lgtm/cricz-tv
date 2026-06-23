import 'package:flutter/material.dart';
  import '../widgets/app_drawer.dart';
  import 'channels_screen.dart';
  import 'categories_screen.dart';
  import 'matches_screen.dart';

  class MainNavigationHub extends StatefulWidget {
    const MainNavigationHub({super.key});

    @override
    State<MainNavigationHub> createState() => _MainNavigationHubState();
  }

  class _MainNavigationHubState extends State<MainNavigationHub> {
    int _idx = 0;

    static const _titles = ['Sports', 'Live Events', 'Categories'];

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 26),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: Text(
            _titles[_idx],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.star_border_rounded, color: Colors.white, size: 24),
              onPressed: () {},
              tooltip: 'Favorites',
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
              onPressed: () => setState(() {}),
              tooltip: 'Refresh',
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
              onPressed: () {},
              tooltip: 'Search',
            ),
          ],
        ),
        drawer: const AppNavigationDrawer(),
        body: IndexedStack(
          index: _idx,
          children: const [
            ChannelsScreen(),
            MatchesScreen(),
            CategoriesScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0D0D0D),
            border: Border(top: BorderSide(color: Color(0xFF1A1A1A), width: 1)),
          ),
          child: BottomNavigationBar(
            currentIndex: _idx,
            onTap: (i) => setState(() => _idx = i),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF08C7D6),
            unselectedItemColor: Colors.white38,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.sports_soccer_rounded),
                label: 'Sports',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sensors_rounded),
                label: 'Live Events',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.live_tv_rounded),
                label: 'Categories',
              ),
            ],
          ),
        ),
      );
    }
  }
  