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
      final res = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'CricZTV/2.0',
      }).timeout(const Duration(seconds: 15));
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
      final dates = [
        _fmtDate(now.subtract(const Duration(days: 1))),
        _fmtDate(now),
        _fmtDate(now.add(const Duration(days: 1))),
        _fmtDate(now.add(const Duration(days: 2))),
      ];

      final results = await Future.wait([
        for (final d in dates) _fetchDay('Soccer', d),
        for (final d in dates) _fetchDay('Cricket', d),
      ]);

      final soccer = results.sublist(0, 4).expand((e) => e).toList();
      final cricket = results.sublist(4, 8).expand((e) => e).toList();

      soccer.sort((a, b) =>
          (a['strTimestamp'] ?? '').compareTo(b['strTimestamp'] ?? ''));
      cricket.sort((a, b) =>
          (a['strTimestamp'] ?? '').compareTo(b['strTimestamp'] ?? ''));

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
    if (status == 'live' || status.contains('progress') ||
        status == 'ht' || status == 'et' || status == 'pen' && _getScore(m) == 'VS') return true;
    final ts = m['strTimestamp'] ?? '';
    if (ts.isEmpty) return false;
    try {
      final matchTime = DateTime.parse(ts);
      final now = DateTime.now().toUtc();
      final diff = now.difference(matchTime).inMinutes;
      return diff >= 0 && diff <= 150;
    } catch (_) {}
    return false;
  }

  bool _isFinished(Map<String, dynamic> m) {
    final status = (m['strStatus'] ?? '').toString().toLowerCase();
    if ({'ft', 'finished', 'aet', 'pen', 'complete', 'result'}.contains(status)) return true;
    final ts = m['strTimestamp'] ?? '';
    if (ts.isEmpty) return false;
    try {
      final matchTime = DateTime.parse(ts);
      final now = DateTime.now().toUtc();
      return now.isAfter(matchTime.add(const Duration(hours: 4)));
    } catch (_) {}
    return false;
  }

  bool _isUpcoming(Map<String, dynamic> m) => !_isLive(m) && !_isFinished(m);

  String _formatTime(Map<String, dynamic> m) {
    final ts = m['strTimestamp'] ?? '';
    if (ts.isEmpty) return m['strTime'] ?? '--:--';
    try {
      final dt = DateTime.parse(ts).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month) return '$h:$min Today';
      if (dt.day == now.day + 1) return '$h:$min Tomorrow';
      if (dt.day == now.day - 1) return 'Yesterday $h:$min';
      return '${dt.day}/${dt.month} $h:$min';
    } catch (_) {}
    return m['strTime'] ?? '';
  }

  String _getScore(Map<String, dynamic> m) {
    final s1 = m['intHomeScore'];
    final s2 = m['intAwayScore'];
    if (s1 != null && s2 != null) return '$s1 : $s2';
    return 'VS';
  }

  @override
  Widget build(BuildContext context) {
    final liveCount = _soccer.where(_isLive).length + _cricket.where(_isLive).length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(children: [
          const Icon(Icons.stadium_rounded, color: Color(0xFF00D2FF), size: 22),
          const SizedBox(width: 8),
          const Text('Live Events',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          if (liveCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.4))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.circle, color: Colors.red, size: 7),
                const SizedBox(width: 4),
                Text('$liveCount LIVE',
                    style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
              ]),
            ),
          ],
        ]),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00D2FF)),
              onPressed: _fetchMatches),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF00D2FF),
            unselectedLabelColor: Colors.white38,
            indicatorColor: const Color(0xFF00D2FF),
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('⚽  FIFA 2026'),
                  if (_soccer.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _countBadge(_soccer.where(_isLive).length, _soccer.length),
                  ],
                ]),
              ),
              Tab(
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('🏏  Cricket'),
                  if (_cricket.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _countBadge(_cricket.where(_isLive).length, _cricket.length),
                  ],
                ]),
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? _buildLoader()
          : _error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(_soccer, 'Soccer'),
                    _buildList(_cricket, 'Cricket'),
                  ],
                ),
    );
  }

  Widget _countBadge(int live, int total) {
    if (live > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
        child: Text('$live', style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
      child: Text('$total', style: const TextStyle(color: Colors.white38, fontSize: 10)),
    );
  }

  Widget _buildLoader() => const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(color: Color(0xFF00D2FF), strokeWidth: 2.5),
          SizedBox(height: 16),
          Text('Fetching live matches...', style: TextStyle(color: Colors.white54, fontSize: 14)),
        ]),
      );

  Widget _buildErrorState() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white24, size: 56),
          const SizedBox(height: 14),
          const Text('Could not load matches',
              style: TextStyle(color: Colors.white60, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Check your internet and try again.',
              style: TextStyle(color: Colors.white30, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _fetchMatches,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D2FF),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]),
      );

  Widget _buildList(List<Map<String, dynamic>> matches, String sport) {
    if (matches.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(sport == 'Soccer' ? Icons.sports_soccer : Icons.sports_cricket,
              color: Colors.white12, size: 72),
          const SizedBox(height: 16),
          const Text('No matches scheduled', style: TextStyle(color: Colors.white38, fontSize: 16)),
          const SizedBox(height: 6),
          const Text('Check back later for upcoming fixtures.',
              style: TextStyle(color: Colors.white24, fontSize: 13)),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: _fetchMatches,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00D2FF)),
            label: const Text('Refresh', style: TextStyle(color: Color(0xFF00D2FF))),
          ),
        ]),
      );
    }

    final live = matches.where(_isLive).toList();
    final upcoming = matches.where(_isUpcoming).toList();
    final finished = matches.where(_isFinished).toList();

    return RefreshIndicator(
      onRefresh: _fetchMatches,
      color: const Color(0xFF00D2FF),
      backgroundColor: const Color(0xFF0E161B),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
        children: [
          if (live.isNotEmpty) ...[
            _sectionLabel('🔴  LIVE NOW', Colors.red, live.length),
            ...live.map((m) => _buildCard(m, sport)),
            const SizedBox(height: 6),
          ],
          if (upcoming.isNotEmpty) ...[
            _sectionLabel('📅  UPCOMING', const Color(0xFF00D2FF), upcoming.length),
            ...upcoming.map((m) => _buildCard(m, sport)),
            const SizedBox(height: 6),
          ],
          if (finished.isNotEmpty) ...[
            _sectionLabel('✅  RESULTS', Colors.white30, finished.length),
            ...finished.map((m) => _buildCard(m, sport)),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String title, Color color, int count) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Row(children: [
          Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$count', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ]),
      );

  Widget _buildCard(Map<String, dynamic> m, String sport) {
    final live = _isLive(m);
    final finished = _isFinished(m);
    final score = _getScore(m);
    final hasScore = score != 'VS';
    final timeStr = finished ? 'FT' : (live ? 'LIVE' : _formatTime(m));
    final league = m['strLeague'] ?? m['strSport'] ?? '';
    final t1 = m['strHomeTeam'] ?? '?';
    final t2 = m['strAwayTeam'] ?? '?';
    final t1Logo = m['strHomeTeamBadge'] ?? '';
    final t2Logo = m['strAwayTeamBadge'] ?? '';
    final statusColor = live ? Colors.red : finished ? Colors.white30 : const Color(0xFF00D2FF);

    return GestureDetector(
      onTap: finished ? null : () => _showChannels(m, sport),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF050D12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: live
                ? Colors.red.withOpacity(0.35)
                : finished
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFF00D2FF).withOpacity(0.12),
            width: live ? 1.5 : 1,
          ),
          boxShadow: live
              ? [BoxShadow(color: Colors.red.withOpacity(0.06), blurRadius: 16, spreadRadius: 1)]
              : [],
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: live ? Colors.red.withOpacity(0.07) : Colors.white.withOpacity(0.02),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(children: [
              Expanded(
                child: Text(league,
                    style: TextStyle(
                        color: live ? Colors.red.shade200 : Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.35)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (live) ...[
                    const Icon(Icons.circle, color: Colors.red, size: 7),
                    const SizedBox(width: 4),
                  ],
                  Text(timeStr,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(children: [
              Expanded(child: _teamCol(t1, t1Logo)),
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: hasScore ? statusColor.withOpacity(0.08) : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasScore ? statusColor.withOpacity(0.3) : Colors.white.withOpacity(0.07),
                  ),
                ),
                child: Text(score,
                    style: TextStyle(
                      color: hasScore ? statusColor : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: hasScore ? 22 : 14,
                    ),
                    textAlign: TextAlign.center),
              ),
              Expanded(child: _teamCol(t2, t2Logo)),
            ]),
          ),
          if (!finished)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: live ? Colors.red : const Color(0xFF00D2FF),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(live ? Icons.sensors_rounded : Icons.play_circle_outline_rounded,
                    color: Colors.white, size: 17),
                const SizedBox(width: 6),
                Text(live ? 'Watch LIVE Now' : 'Watch When Live',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13,
                        letterSpacing: 0.3)),
              ]),
            ),
        ]),
      ),
    );
  }

  Widget _teamCol(String name, String logoUrl) => Column(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            shape: BoxShape.circle,
          ),
          child: logoUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.sports, color: Colors.white24, size: 28)))
              : const Icon(Icons.sports, color: Colors.white24, size: 28),
        ),
        const SizedBox(height: 8),
        Text(name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ]);

  void _showChannels(Map<String, dynamic> match, String sport) {
    final t1 = match['strHomeTeam'] ?? '';
    final t2 = match['strAwayTeam'] ?? '';
    final categories = sport == 'Soccer'
        ? ['FIFA 2026', 'Football', 'Sports']
        : ['Cricket', 'BD Sports', 'Sports'];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF060E14),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) => StreamBuilder<List<Channel>>(
        stream: FirestoreService.channelsStream(),
        builder: (ctx, snap) {
          final allChannels = snap.data ?? ChannelData.defaultChannels;
          final filtered = allChannels.where((c) => categories.contains(c.category)).toList();

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.55,
            maxChildSize: 0.9,
            builder: (_, scroll) => Column(children: [
              Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D2FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.play_circle_filled_rounded, color: Color(0xFF00D2FF), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('$t1  vs  $t2',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                      const Text('Choose a channel to watch',
                          style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ]),
                  ),
                ]),
              ),
              const Divider(color: Color(0xFF101A22), height: 1),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('No channels available.',
                            style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        controller: scroll,
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final ch = filtered[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF0E1C26),
                                  borderRadius: BorderRadius.circular(10)),
                              child: ch.logoUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(ch.logoUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.live_tv, color: Color(0xFF00D2FF), size: 22)))
                                  : const Icon(Icons.live_tv, color: Color(0xFF00D2FF), size: 22),
                            ),
                            title: Text(ch.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(ch.category,
                                style: const TextStyle(color: Colors.white30, fontSize: 11)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D2FF).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.3)),
                              ),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.play_arrow_rounded, color: Color(0xFF00D2FF), size: 16),
                                SizedBox(width: 2),
                                Text('Watch', style: TextStyle(color: Color(0xFF00D2FF), fontSize: 12, fontWeight: FontWeight.bold)),
                              ]),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => PlayerScreen(channel: ch)));
                            },
                          );
                        },
                      ),
              ),
            ]),
          );
        },
      ),
    );
  }
}
