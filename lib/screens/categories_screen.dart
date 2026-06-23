import 'package:flutter/material.dart';
import '../models/channel_model.dart';
import '../services/firestore_service.dart';
import 'channels_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const _meta = {
    'FIFA 2026': {'icon': Icons.sports_soccer, 'color': Color(0xFF4CAF50),  'grad': [Color(0xFF1A4A1A), Color(0xFF0D240D)]},
    'Football':  {'icon': Icons.sports_soccer, 'color': Color(0xFF8BC34A),  'grad': [Color(0xFF1A2E0A), Color(0xFF0D1A05)]},
    'Cricket':   {'icon': Icons.sports_cricket,'color': Color(0xFF00D2FF),  'grad': [Color(0xFF001A2C), Color(0xFF000D16)]},
    'Sports':    {'icon': Icons.sports,        'color': Color(0xFFFF9800),  'grad': [Color(0xFF2C1A00), Color(0xFF160D00)]},
    'BD Sports': {'icon': Icons.flag,          'color': Color(0xFFE91E63),  'grad': [Color(0xFF2C001A), Color(0xFF16000D)]},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Channels', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Channel>>(
        stream: FirestoreService.channelsStream(),
        builder: (_, snap) {
          final channels = snap.data ?? ChannelData.defaultChannels;
          final cats = channels.map((c) => c.category).toSet().toList()..sort();
          final total = channels.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BROWSE CATEGORY',
                    style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5),
                  itemCount: cats.length,
                  itemBuilder: (_, i) {
                    final cat = cats[i];
                    final m = _meta[cat] ?? {
                      'icon': Icons.live_tv,
                      'color': const Color(0xFF00D2FF),
                      'grad': [const Color(0xFF001A2C), const Color(0xFF000D16)]
                    };
                    final color = m['color'] as Color;
                    final grads = m['grad'] as List<Color>;
                    final count = channels.where((c) => c.category == cat).length;
                    return GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ChannelsScreen(filterCategory: cat))),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft, end: Alignment.bottomRight, colors: grads),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: color.withOpacity(0.15), shape: BoxShape.circle),
                              child: Icon(m['icon'] as IconData, color: color, size: 26)),
                          const SizedBox(height: 8),
                          Text(cat,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('$count channels', style: TextStyle(color: color, fontSize: 12)),
                        ]),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text('ALL CHANNELS',
                    style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const ChannelsScreen())),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF001A2C), Color(0xFF002A40)]),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: const Color(0xFF00D2FF).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.live_tv, color: Color(0xFF00D2FF), size: 24)),
                      const SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('All Channels',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('$total live channels',
                            style: const TextStyle(color: Color(0xFF00D2FF), fontSize: 13)),
                      ]),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
