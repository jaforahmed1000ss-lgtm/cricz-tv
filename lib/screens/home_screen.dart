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
        decoration: BoxDecoration(
          color: const Color(0xFF050B0F),
          border: const Border(top: BorderSide(color: Color(0xFF0E161B), width: 1.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(children: [
              _NavItem(icon: Icons.stadium_rounded, label: 'Live Events', selected: _idx == 0, onTap: () => setState(() => _idx = 0)),
              _NavItem(icon: Icons.live_tv_rounded, label: 'Sports', selected: _idx == 1, onTap: () => setState(() => _idx = 1)),
              _NavItem(icon: Icons.grid_view_rounded, label: 'Categories', selected: _idx == 2, onTap: () => setState(() => _idx = 2)),
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

  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF00D2FF) : Colors.grey.shade600;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
        ]),
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
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(children: [
          const Icon(Icons.live_tv_rounded, color: Color(0xFF00D2FF), size: 22),
          const SizedBox(width: 8),
          const Text('CricZ TV',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 0.3)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
            child: const Text('LIVE',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white38, size: 22),
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
          final football = channels.where((c) => c.category == 'Football').toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
            children: [
              _HeroBanner(
                emoji: '⚽',
                title: 'FIFA World Cup 2026',
                subtitle: 'Watch all matches live, HD & free!',
                gradient: const [Color(0xFF003D1F), Color(0xFF00A550)],
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ChannelsScreen(filterCategory: 'FIFA 2026'))),
              ),
              const SizedBox(height: 16),
              _sectionHeader(context, '📅  Today\'s Matches', () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchesScreen()))),
              const SizedBox(height: 10),
              _MatchPreviewCard(onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchesScreen()))),
              const SizedBox(height: 20),
              if (fifa.isNotEmpty) ...[
                _sectionHeader(context, '⚽  FIFA 2026 Channels', () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChannelsScreen(filterCategory: 'FIFA 2026')))),
                const SizedBox(height: 10),
                _ChannelRow(channels: fifa.take(8).toList()),
                const SizedBox(height: 20),
              ],
              if (cricket.isNotEmpty) ...[
                _sectionHeader(context, '🏏  Cricket Channels', () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChannelsScreen(filterCategory: 'Cricket')))),
                const SizedBox(height: 10),
                _ChannelRow(channels: cricket.take(8).toList()),
                const SizedBox(height: 20),
              ],
              if (football.isNotEmpty) ...[
                _sectionHeader(context, '🏟️  Football Channels', () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChannelsScreen(filterCategory: 'Football')))),
                const SizedBox(height: 10),
                _ChannelRow(channels: football.take(8).toList()),
                const SizedBox(height: 20),
              ],
              if (sports.isNotEmpty) ...[
                _sectionHeader(context, '🏆  Sports Channels', () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChannelsScreen(filterCategory: 'Sports')))),
                const SizedBox(height: 10),
                _ChannelRow(channels: sports.take(8).toList()),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(BuildContext ctx, String title, VoidCallback onTap) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      GestureDetector(
        onTap: onTap,
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Text('See all', style: TextStyle(color: Color(0xFF00D2FF), fontSize: 12)),
          SizedBox(width: 2),
          Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00D2FF), size: 12),
        ]),
      ),
    ]);
  }
}

class _HeroBanner extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _HeroBanner({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: gradient.last.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Text('Watch Now',
                    style: TextStyle(color: gradient.last, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
        ]),
      ),
    );
  }
}

class _MatchPreviewCard extends StatelessWidget {
  final VoidCallback onTap;
  const _MatchPreviewCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF040C12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.18)),
        ),
        child: const Row(children: [
          Icon(Icons.stadium_rounded, color: Color(0xFF00D2FF), size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Live Match Schedules',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text('FIFA World Cup 2026 & Cricket fixtures',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00D2FF), size: 14),
        ]),
      ),
    );
  }
}

class _ChannelRow extends StatelessWidget {
  final List<Channel> channels;
  const _ChannelRow({required this.channels});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: channels.length,
        itemBuilder: (ctx, i) {
          final ch = channels[i];
          return GestureDetector(
            onTap: () => Navigator.push(
                ctx, MaterialPageRoute(builder: (_) => PlayerScreen(channel: ch))),
            child: Container(
              width: 86,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF060E14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1C26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ch.logoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(ch.logoUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.live_tv_rounded, color: Color(0xFF00D2FF), size: 26)))
                      : const Icon(Icons.live_tv_rounded, color: Color(0xFF00D2FF), size: 26),
                ),
                const SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(ch.name,
                      style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w600),
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
