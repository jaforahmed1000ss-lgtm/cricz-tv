import 'package:flutter/material.dart';
import '../models/channel_model.dart';
import '../services/firestore_service.dart';
import 'player_screen.dart';

class ChannelsScreen extends StatefulWidget {
  final String? filterCategory;
  const ChannelsScreen({super.key, this.filterCategory});
  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  String _search = '';
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.filterCategory ?? 'All Channels',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _ctrl,
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search channels...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white38),
                        onPressed: () { _ctrl.clear(); setState(() => _search = ''); })
                    : null,
                filled: true,
                fillColor: const Color(0xFF0E161B),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Channel>>(
        stream: FirestoreService.channelsStream(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF)));
          }
          var list = snap.data ?? ChannelData.defaultChannels;
          if (widget.filterCategory != null) {
            list = list.where((c) => c.category == widget.filterCategory).toList();
          }
          if (_search.isNotEmpty) {
            list = list
                .where((c) => c.name.toLowerCase().contains(_search.toLowerCase()))
                .toList();
          }
          if (list.isEmpty) {
            return const Center(
                child: Text('No channels found', style: TextStyle(color: Colors.white60)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final ch = list[i];
              return GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => PlayerScreen(channel: ch))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFF02090F),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF0A161E))),
                  child: Row(children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          color: const Color(0xFF0E1C26),
                          borderRadius: BorderRadius.circular(10)),
                      child: ch.logoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(ch.logoUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.live_tv, color: Color(0xFF00D2FF), size: 28)))
                          : const Icon(Icons.live_tv, color: Color(0xFF00D2FF), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(ch.name,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF00D2FF).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(ch.category,
                                  style: const TextStyle(color: Color(0xFF00D2FF), fontSize: 11))),
                          const SizedBox(width: 6),
                          Container(
                              width: 6,
                              height: 6,
                              decoration:
                                  const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          const Text('LIVE',
                              style: TextStyle(
                                  color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                        ]),
                      ]),
                    ),
                    const Icon(Icons.play_circle_filled, color: Color(0xFF00D2FF), size: 32),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
