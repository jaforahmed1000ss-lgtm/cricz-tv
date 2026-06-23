import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/channel_model.dart';
import '../services/firestore_service.dart';
import 'player_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _soccer = [];
  List<Map<String, dynamic>> _cricket = [];

  static const _sportsDbBase = 'https://www.thesportsdb.com/api/v1/json/3';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<List<Map<String, dynamic>>> _fetchDay(String sport, String date) async {
    try {
      final url = '$_sportsDbBase/eventsday.php?d=$date&s=$sport';
      final res =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return ((data['events'] as List?) ?? []).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _fetchMatches() async {
    setState(() { _loading = true; _error = null; });
    try {
      final now = DateTime.now().toUtc();
      final today = _fmtDate(now);
      final tomorrow = _fmtDate(now.add(const Duration(days: 1)));
      final yesterday = _fmtDate(now.subtract(const Duration(days: 1)));

      final results = await Future.wait([
        _fetchDay('Soccer', yesterday),
        _fetchDay('Soccer', today),
        _fetchDay('Soccer', tomorrow),
        _fetchDay('Cricket', yesterday),
        _fetchDay('Cricket', today),
        _fetchDay('Cricket', tomorrow),
      ]);

      final soccer = [...results[0], ...results[1], ...results[2]];
      final cricket = [...results[3], ...results[4], ...results[5]];

      soccer.sort((a, b) => (a['strTimestamp'] ?? '').compareTo(b['strTimestamp'] ?? ''));
      cricket.sort((a, b) => (a['strTimestamp'] ?? '').compareTo(b['strTimestamp'] ?? ''));

      if (mounted) {
        setState(() {
          _soccer = soccer;
          _cricket = cricket;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  bool _isLive(Map<String, dynamic> m) {
    final status = (m['strStatus'] ?? '').toString().toLowerCase();
    if (status.contains('live') || status.contains('progress') || status == 'ht') return true;
    final ts = m['strTimestamp'] ?? '';
    if (ts.isEmpty) return false;
    try {
      final matchTime = DateTime.parse(ts);
      final now = DateTime.now().toUtc();
      final diff = now.difference(matchTime).inMinutes;
      return diff >= 0 && diff <= 130;
    } catch (_) {}
    return false;
  }

  bool _isFinished(Map<String, dynamic> m) {
    final status = (m['strStatus'] ?? '').toString().toLowerCase();
    if (status == 'ft' || status == 'finished' || status == 'aet' || status == 'pen') return true;
    final s1 = m['intHomeScore'];
    final s2 = m['intAwayScore'];
    if (s1 == null && s2 == null) return false;
    final ts = m['strTimestamp'] ?? '';
    try {
      final matchTime = DateTime.parse(ts);
      final now = DateTime.now().toUtc();
      return now.isAfter(matchTime.add(const Duration(hours: 3)));
    } catch (_) {}
    return false;
  }

  String _formatTime(Map<String, dynamic> m) {
    final ts = m['strTimestamp'] ?? '';
    if (ts.isEmpty) return m['strTime'] ?? '--:--';
    try {
      final dt = DateTime.parse(ts).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month) return 'Today $h:$min';
      if (dt.day == now.day + 1) return 'Tomorrow $h:$min';
      if (dt.day == now.day - 1) return 'Yesterday $h:$min';
      return '${dt.day}/${dt.month} $h:$min';
    } catch (_) {}
    return m['strTime'] ?? '';
  }

  String _getScore(Map<String, dynamic> m) {
    final s1 = m['intHomeScore'];
    final s2 = m['intAwayScore'];
    if (s1 != null && s2 != null) return '$s1 - $s2';
    return 'VS';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(children: [
          Icon(Icons.stadium, color: Color(0xFF00D2FF), size: 22),
          SizedBox(width: 8),
          Text('Match Schedule',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF00D2FF)),
              onPressed: _fetchMatches),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00D2FF),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF00D2FF),
          tabs: [
            Tab(
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('⚽ FIFA 2026',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                if (_soccer.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('${_soccer.length}',
                        style: const TextStyle(fontSize: 11, color: Colors.green)),
                  ),
                ],
              ]),
            ),
            Tab(
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('🏏 Cricket',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                if (_cricket.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('${_cricket.length}',
                        style: const TextStyle(fontSize: 11, color: Colors.green)),
                  ),
                ],
              ]),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(color: Color(0xFF00D2FF)),
              SizedBox(height: 16),
              Text('Loading live matches...', style: TextStyle(color: Colors.white54)),
            ]))
          : _error != null
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.wifi_off, color: Colors.white38, size: 48),
                  const SizedBox(height: 12),
                  const Text('Failed to load matches',
                      style: TextStyle(color: Colors.white60, fontSize: 16)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                      onPressed: _fetchMatches,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D2FF)),
                      child: const Text('Retry', style: TextStyle(color: Colors.black))),
                ]))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMatchList(_soccer, 'Soccer'),
                    _buildMatchList(_cricket, 'Cricket'),
                  ],
                ),
    );
  }

  Widget _buildMatchList(List<Map<String, dynamic>> matches, String sport) {
    if (matches.isEmpty) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(sport == 'Soccer' ? Icons.sports_soccer : Icons.sports_cricket,
            color: Colors.white24, size: 64),
        const SizedBox(height: 16),
        const Text('No matches scheduled', style: TextStyle(color: Colors.white38, fontSize: 16)),
        const SizedBox(height: 8),
        TextButton.icon(
            onPressed: _fetchMatches,
            icon: const Icon(Icons.refresh, color: Color(0xFF00D2FF)),
            label: const Text('Refresh', style: TextStyle(color: Color(0xFF00D2FF)))),
      ]));
    }

    return RefreshIndicator(
      onRefresh: _fetchMatches,
      color: const Color(0xFF00D2FF),
      backgroundColor: const Color(0xFF0E161B),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        itemCount: matches.length,
        itemBuilder: (ctx, i) => _buildMatchCard(matches[i], sport),
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> m, String sport) {
    final isLive = _isLive(m);
    final isFinished = _isFinished(m);
    final score = _getScore(m);
    final hasScore = score != 'VS';
    final timeStr = isFinished ? 'FT' : (isLive ? 'LIVE' : _formatTime(m));
    final league = m['strLeague'] ?? '';
    final t1 = m['strHomeTeam'] ?? '?';
    final t2 = m['strAwayTeam'] ?? '?';
    final t1Logo = m['strHomeTeamBadge'] ?? '';
    final t2Logo = m['strAwayTeamBadge'] ?? '';

    final statusColor = isLive ? Colors.red : isFinished ? Colors.grey : const Color(0xFF00D2FF);

    return GestureDetector(
      onTap: !isFinished ? () => _showChannels(m, sport) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF02090F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLive
                ? Colors.red.withOpacity(0.4)
                : isFinished
                    ? Colors.white12
                    : const Color(0xFF00D2FF).withOpacity(0.15),
            width: isLive ? 1.5 : 1,
          ),
          boxShadow: isLive
              ? [BoxShadow(color: Colors.red.withOpacity(0.08), blurRadius: 12, spreadRadius: 2)]
              : [],
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isLive ? Colors.red.withOpacity(0.08) : const Color(0xFF060E14),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Text(league,
                    style: TextStyle(
                        color: isLive ? Colors.red.shade200 : Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (isLive) ...[
                    Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                  ],
                  Text(timeStr,
                      style: TextStyle(
                          color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(children: [
              Expanded(
                child: Column(children: [
                  if (t1Logo.isNotEmpty)
                    Image.network(t1Logo,
                        width: 42,
                        height: 42,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.sports, color: Colors.white30, size: 36))
                  else
                    const Icon(Icons.sports, color: Colors.white30, size: 36),
                  const SizedBox(height: 6),
                  Text(t1,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ]),
              ),
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: hasScore ? statusColor.withOpacity(0.1) : const Color(0xFF0E161B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: hasScore ? statusColor.withOpacity(0.35) : Colors.white12),
                ),
                child: Text(
                  score,
                  style: TextStyle(
                    color: hasScore ? statusColor : Colors.white54,
                    fontWeight: FontWeight.bold,
                    fontSize: hasScore ? 20 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Column(children: [
                  if (t2Logo.isNotEmpty)
                    Image.network(t2Logo,
                        width: 42,
                        height: 42,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.sports, color: Colors.white30, size: 36))
                  else
                    const Icon(Icons.sports, color: Colors.white30, size: 36),
                  const SizedBox(height: 6),
                  Text(t2,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ]),
              ),
            ]),
          ),
          if (!isFinished)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isLive ? Colors.red : const Color(0xFF00D2FF),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(isLive ? Icons.sensors : Icons.play_circle_outline,
                    color: Colors.white, size: 17),
                const SizedBox(width: 6),
                Text(isLive ? 'Watch LIVE Now' : 'Watch Match',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ]),
            ),
        ]),
      ),
    );
  }

  void _showChannels(Map<String, dynamic> match, String sport) {
    final t1 = match['strHomeTeam'] ?? '';
    final t2 = match['strAwayTeam'] ?? '';
    final categories = sport == 'Soccer'
        ? ['FIFA 2026', 'Football', 'Sports']
        : ['Cricket', 'Sports', 'BD Sports'];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A1219),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) {
        return StreamBuilder<List<Channel>>(
          stream: FirestoreService.channelsStream(),
          builder: (ctx, snap) {
            final allChannels = snap.data ?? ChannelData.defaultChannels;
            final filtered = allChannels.where((c) => categories.contains(c.category)).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              builder: (_, scroll) => Column(children: [
                Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(children: [
                    const Icon(Icons.play_circle_filled, color: Color(0xFF00D2FF), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('$t1 vs $t2',
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis),
                        const Text('Select a channel to watch',
                            style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ]),
                    ),
                  ]),
                ),
                const Divider(color: Color(0xFF1A1A1A), height: 1),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No channels available.',
                                style: TextStyle(color: Colors.white38),
                                textAlign: TextAlign.center),
                          ))
                      : ListView.builder(
                          controller: scroll,
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final ch = filtered[i];
                            return ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF0E1C26),
                                    borderRadius: BorderRadius.circular(8)),
                                child: ch.logoUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(ch.logoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(
                                                Icons.live_tv,
                                                color: Color(0xFF00D2FF),
                                                size: 22)))
                                    : const Icon(Icons.live_tv,
                                        color: Color(0xFF00D2FF), size: 22),
                              ),
                              title: Text(ch.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              subtitle: Text(ch.category,
                                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF00D2FF).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.play_arrow, color: Color(0xFF00D2FF), size: 16),
                                  Text('Watch',
                                      style: TextStyle(
                                          color: Color(0xFF00D2FF),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold))
                                ]),
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => PlayerScreen(channel: ch)));
                              },
                            );
                          },
                        ),
                ),
              ]),
            );
          },
        );
      },
    );
  }
}
