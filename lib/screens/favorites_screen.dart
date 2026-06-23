import 'package:flutter/material.dart';
  import '../models/channel_model.dart';
  import '../services/favorites_service.dart';
  import 'player_screen.dart';

  class FavoritesScreen extends StatefulWidget {
    const FavoritesScreen({super.key});
    @override
    State<FavoritesScreen> createState() => _FavoritesScreenState();
  }

  class _FavoritesScreenState extends State<FavoritesScreen> {
    List<Channel> _favs = [];
    bool _loading = true;

    @override
    void initState() {
      super.initState();
      _load();
    }

    Future<void> _load() async {
      setState(() => _loading = true);
      final favs = await FavoritesService.getFavoriteChannels();
      if (mounted) setState(() { _favs = favs; _loading = false; });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Row(children: [
            Icon(Icons.favorite_rounded, color: Color(0xFFFF4081), size: 22),
            SizedBox(width: 10),
            Text('Favorites', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ]),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF), strokeWidth: 2))
            : _favs.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.favorite_border_rounded, color: Colors.white12, size: 72),
                      const SizedBox(height: 18),
                      const Text('No favorites yet', style: TextStyle(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Tap the ❤️ on any channel to save it here', style: TextStyle(color: Colors.white30, fontSize: 13), textAlign: TextAlign.center),
                    ]),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    color: const Color(0xFF00D2FF),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                      itemCount: _favs.length,
                      itemBuilder: (_, i) {
                        final ch = _favs[i];
                        return _FavCard(
                          channel: ch,
                          onRemoved: _load,
                        );
                      },
                    ),
                  ),
      );
    }
  }

  class _FavCard extends StatelessWidget {
    final Channel channel;
    final VoidCallback onRemoved;
    const _FavCard({required this.channel, required this.onRemoved});

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(channel: channel))),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF1A0010).withOpacity(0.8), const Color(0xFF040C12)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF4081).withOpacity(0.15)),
          ),
          child: Row(children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(color: const Color(0xFF0A0515), borderRadius: BorderRadius.circular(12)),
              child: channel.logoUrl.isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.circular(12),
                      child: Image.network(channel.logoUrl, fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.live_tv_rounded, color: Color(0xFF00D2FF), size: 28)))
                  : const Icon(Icons.live_tv_rounded, color: Color(0xFF00D2FF), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(channel.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF00D2FF).withOpacity(0.12), borderRadius: BorderRadius.circular(5), border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.25))),
                  child: Text(channel.category, style: const TextStyle(color: Color(0xFF00D2FF), fontSize: 10, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.circle, color: Colors.red, size: 7),
                const SizedBox(width: 4),
                const Text('LIVE', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
              ]),
            ])),
            IconButton(
              icon: const Icon(Icons.favorite_rounded, color: Color(0xFFFF4081), size: 22),
              onPressed: () async {
                await FavoritesService.toggleFavorite(channel.id);
                onRemoved();
              },
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF00D2FF).withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.25))),
              child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF00D2FF), size: 22),
            ),
          ]),
        ),
      );
    }
  }
  