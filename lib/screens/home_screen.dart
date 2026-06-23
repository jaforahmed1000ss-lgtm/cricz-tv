import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../services/firestore_service.dart';
import '../models/channel_model.dart';
import 'player_screen.dart';
import 'channels_screen.dart';
import 'categories_screen.dart';
import 'matches_screen.dart';
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF0E161B), width: 1.5)),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF050B0F),
          selectedItemColor: const Color(0xFF00D2FF),
          unselectedItemColor: Colors.grey,
          currentIndex: _idx,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => _idx = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.stadium), label: 'Matches'),
            BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Live TV'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Categories'),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(children: [
          const Icon(Icons.live_tv, color: Color(0xFF00D2FF), size: 22),
          const SizedBox(width: 8),
          const Text('CricZ TV',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
            child: const Text('LIVE',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.white54),
            tooltip: 'Admin',
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
          ),
        ],
      ),
      drawer: const AppNavigationDrawer(),
      body: StreamBuilder<List<Channel>>(
        stream: FirestoreService.channelsStream(),
        builder: (ctx, snap) {
          final channels = snap.data ?? ChannelData.defaultChannels;
          final fifa = channels.where((c) => c.category == 'FIFA 2026').toList();
          final cricket = channels.where((c) => c.category == 'Cricket').toList();
          final sports = channels.where((c) => c.category == 'Sports').toList();

          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF003D1F), Color(0xFF00A550)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  const Text('⚽', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('FIFA World Cup 2026',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const Text('Watch all matches live!',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChannelsScreen(filterCategory: 'FIFA 2026'))),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green.shade800,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero),
                        child: const Text('Watch Now',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              _sectionHeader('📅 Today\'s Matches',
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const MatchesScreen()))),
              const SizedBox(height: 10),
              _matchSchedulePreview(),
              const SizedBox(height: 20),

              if (fifa.isNotEmpty) ...[
                _sectionHeader('⚽ FIFA 2026 Channels',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const ChannelsScreen(filterCategory: 'FIFA 2026')))),
                const SizedBox(height: 10),
                _channelRow(fifa.take(6).toList()),
                const SizedBox(height: 20),
              ],

              if (cricket.isNotEmpty) ...[
                _sectionHeader('🏏 Cricket Channels',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const ChannelsScreen(filterCategory: 'Cricket')))),
                const SizedBox(height: 10),
                _channelRow(cricket.take(6).toList()),
                const SizedBox(height: 20),
              ],

              if (sports.isNotEmpty) ...[
                _sectionHeader('🏆 Sports Channels',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const ChannelsScreen(filterCategory: 'Sports')))),
                const SizedBox(height: 10),
                _channelRow(sports.take(6).toList()),
                const SizedBox(height: 20),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title, {VoidCallback? onTap}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      if (onTap != null)
        GestureDetector(
          onTap: onTap,
          child: const Text('See all', style: TextStyle(color: Color(0xFF00D2FF), fontSize: 13)),
        ),
    ]);
  }

  Widget _matchSchedulePreview() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const MatchesScreen())),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF02090F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.2)),
        ),
        child: const Row(children: [
          Icon(Icons.stadium, color: Color(0xFF00D2FF), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Live Match Schedules',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text('FIFA & Cricket matches with real scores',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ]),
          ),
          Icon(Icons.arrow_forward_ios, color: Color(0xFF00D2FF), size: 16),
        ]),
      ),
    );
  }

  Widget _channelRow(List<Channel> channels) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: channels.length,
        itemBuilder: (ctx, i) {
          final ch = channels[i];
          return GestureDetector(
            onTap: () => Navigator.push(
                ctx, MaterialPageRoute(builder: (_) => PlayerScreen(channel: ch))),
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                  color: const Color(0xFF0E161B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: const Color(0xFF1A2530),
                      borderRadius: BorderRadius.circular(8)),
                  child: ch.logoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(ch.logoUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.live_tv, color: Color(0xFF00D2FF), size: 24)))
                      : const Icon(Icons.live_tv, color: Color(0xFF00D2FF), size: 24),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(ch.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
