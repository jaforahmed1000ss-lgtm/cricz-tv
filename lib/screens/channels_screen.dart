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
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: widget.filterCategory != null,
        leading: widget.filterCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(children: [
          const Icon(Icons.live_tv_rounded, color: Color(0xFF00D2FF), size: 20),
          const SizedBox(width: 8),
          Text(widget.filterCategory ?? 'Sports',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _ctrl,
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search channels...',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white30, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white30, size: 18),
                        onPressed: () {
                          _ctrl.clear();
                          setState(() => _search = '');
                        })
                    : null,
                filled: true,
                fillColor: const Color(0xFF0A1219),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1A2530))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1A2530))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00D2FF), width: 1.5)),
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
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00D2FF), strokeWidth: 2));
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
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.search_off_rounded, color: Colors.white24, size: 56),
                const SizedBox(height: 14),
                const Text('No channels found',
                    style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(_search.isNotEmpty ? 'Try a different search term' : 'No channels in this category',
                    style: const TextStyle(color: Colors.white30, fontSize: 13)),
              ]),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final ch = list[i];
              return _ChannelCard(channel: ch);
            },
          );
        },
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final Channel channel;
  const _ChannelCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => PlayerScreen(channel: channel))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF040C12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF0A1825),
              borderRadius: BorderRadius.circular(12),
            ),
            child: channel.logoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(channel.logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.live_tv_rounded, color: Color(0xFF00D2FF), size: 28)))
                : const Icon(Icons.live_tv_rounded, color: Color(0xFF00D2FF), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(channel.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D2FF).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.25)),
                  ),
                  child: Text(channel.category,
                      style: const TextStyle(color: Color(0xFF00D2FF), fontSize: 10, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.circle, color: Colors.red, size: 7),
                const SizedBox(width: 4),
                const Text('LIVE',
                    style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ]),
            ]),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00D2FF).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.25)),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF00D2FF), size: 22),
          ),
        ]),
      ),
    );
  }
}
