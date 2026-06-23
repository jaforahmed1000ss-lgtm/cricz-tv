import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;

  class MatchesScreen extends StatefulWidget {
    const MatchesScreen({super.key});

    @override
    State<MatchesScreen> createState() => _MatchesScreenState();
  }

  class _MatchesScreenState extends State<MatchesScreen> {
    bool _loading = true;
    String? _error;
    List<Map<String, dynamic>> _allMatches = [];
    String _selectedSport = 'All';
    String _statusFilter = 'All';

    static const _sportsDbBase = 'https://www.thesportsdb.com/api/v1/json/3';
    static const _cyan = Color(0xFF08C7D6);

    final _sportFilters = [
      {'label': 'All', 'icon': Icons.sports_rounded},
      {'label': 'Cricket', 'icon': Icons.sports_cricket_rounded},
      {'label': 'Soccer', 'icon': Icons.sports_soccer_rounded},
      {'label': 'Basketball', 'icon': Icons.sports_basketball_rounded},
      {'label': 'Tennis', 'icon': Icons.sports_tennis_rounded},
      {'label': 'Rugby', 'icon': Icons.sports_rugby_rounded},
    ];

    @override
    void initState() {
      super.initState();
      _fetchMatches();
    }

    String _fmtDate(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    Future<List<Map<String, dynamic>>> _fetchDay(String sport, String date) async {
      try {
        final res = await http.get(
          Uri.parse('$_sportsDbBase/eventsday.php?d=$date&s=$sport'),
          headers: {'User-Agent': 'CricZTV/3.0'},
        ).timeout(const Duration(seconds: 15));
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
        final sports = ['Soccer', 'Cricket', 'Basketball', 'Tennis', 'Rugby'];
        final futures = <Future<List<Map<String, dynamic>>>>[];
        for (final s in sports) {
          for (final d in dates) {
            futures.add(_fetchDay(s, d));
          }
        }
        final results = await Future.wait(futures);
        final all = results.expand((e) => e).toList();
        all.sort((a, b) => (a['strTimestamp'] ?? '').compareTo(b['strTimestamp'] ?? ''));
        if (mounted) setState(() { _allMatches = all; _loading = false; });
      } catch (e) {
        if (mounted) setState(() { _loading = false; _error = e.toString(); });
      }
    }

    bool _isLive(Map<String, dynamic> m) {
      final s = (m['strStatus'] ?? '').toString().toLowerCase();
      if ({'live', 'ht', 'et'}.contains(s) || s.contains('progress')) return true;
      final ts = m['strTimestamp'] ?? '';
      if (ts.isEmpty) return false;
      try {
        final diff = DateTime.now().toUtc().difference(DateTime.parse(ts)).inMinutes;
        return diff >= 0 && diff <= 150;
      } catch (_) { return false; }
    }

    bool _isFinished(Map<String, dynamic> m) {
      final s = (m['strStatus'] ?? '').toString().toLowerCase();
      if ({'ft', 'finished', 'aet', 'complete', 'result'}.contains(s)) return true;
      final ts = m['strTimestamp'] ?? '';
      if (ts.isEmpty) return false;
      try {
        return DateTime.now().toUtc().isAfter(DateTime.parse(ts).add(const Duration(hours: 4)));
      } catch (_) { return false; }
    }

    bool _isUpcoming(Map<String, dynamic> m) => !_isLive(m) && !_isFinished(m);

    String _statusOf(Map<String, dynamic> m) {
      if (_isLive(m)) return 'Live';
      if (_isFinished(m)) return 'Finished';
      return 'Upcoming';
    }

    String _formatTime(Map<String, dynamic> m) {
      final ts = m['strTimestamp'] ?? '';
      if (ts.isEmpty) return '--:--';
      try {
        final dt = DateTime.parse(ts).toLocal();
        final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final min = dt.minute.toString().padLeft(2, '0');
        final ampm = dt.hour < 12 ? 'AM' : 'PM';
        return '$h:$min $ampm';
      } catch (_) { return m['strTime'] ?? '--:--'; }
    }

    String _formatDate(Map<String, dynamic> m) {
      final ts = m['strTimestamp'] ?? '';
      if (ts.isEmpty) return '';
      try {
        final dt = DateTime.parse(ts).toLocal();
        return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      } catch (_) { return ''; }
    }

    String _timeUntil(Map<String, dynamic> m) {
      final ts = m['strTimestamp'] ?? '';
      if (ts.isEmpty) return '';
      try {
        final dt = DateTime.parse(ts).toLocal();
        final diff = dt.difference(DateTime.now());
        if (diff.isNegative) return '';
        if (diff.inDays > 0) return 'Starts in ${diff.inDays} day${diff.inDays > 1 ? 's' : ''}';
        if (diff.inHours > 0) return 'Starts in ${diff.inHours} hour${diff.inHours > 1 ? 's' : ''}';
        return 'Starts in ${diff.inMinutes} minutes';
      } catch (_) { return ''; }
    }

    List<Map<String, dynamic>> get _filteredMatches {
      var list = _allMatches;
      if (_selectedSport != 'All') {
        list = list.where((m) =>
          (m['strSport'] ?? '').toString().toLowerCase() == _selectedSport.toLowerCase()
        ).toList();
      }
      if (_statusFilter == 'Live') list = list.where(_isLive).toList();
      else if (_statusFilter == 'Upcoming') list = list.where(_isUpcoming).toList();
      else if (_statusFilter == 'Finished') list = list.where(_isFinished).toList();
      return list;
    }

    int _countFor(String status) {
      var list = _allMatches;
      if (_selectedSport != 'All') {
        list = list.where((m) =>
          (m['strSport'] ?? '').toString().toLowerCase() == _selectedSport.toLowerCase()
        ).toList();
      }
      if (status == 'All') return list.length;
      if (status == 'Live') return list.where(_isLive).length;
      if (status == 'Upcoming') return list.where(_isUpcoming).length;
      if (status == 'Finished') return list.where(_isFinished).length;
      return 0;
    }

    @override
    Widget build(BuildContext context) {
      if (_loading) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Color(0xFF08C7D6))),
        );
      }
      if (_error != null) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white24, size: 56),
              const SizedBox(height: 14),
              const Text('Could not load matches', style: TextStyle(color: Colors.white60, fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchMatches,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cyan, foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
        );
      }

      final filtered = _filteredMatches;

      return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            // Sport filter chips (horizontal scroll)
            Container(
              height: 72,
              color: Colors.black,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                itemCount: _sportFilters.length,
                itemBuilder: (ctx, i) {
                  final sf = _sportFilters[i];
                  final label = sf['label'] as String;
                  final icon = sf['icon'] as IconData;
                  final selected = _selectedSport == label;
                  final count = label == 'All' ? _allMatches.length : _allMatches.where((m) =>
                    (m['strSport'] ?? '').toString().toLowerCase() == label.toLowerCase()
                  ).length;
                  return GestureDetector(
                    onTap: () => setState(() { _selectedSport = label; _statusFilter = 'All'; }),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF0D2F33) : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: selected ? _cyan : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 20, color: selected ? _cyan : Colors.white54),
                              if (label != 'All') ...[
                                const SizedBox(width: 6),
                                Text(label,
                                  style: TextStyle(
                                    color: selected ? _cyan : Colors.white54,
                                    fontSize: 12,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (count > 0)
                            Positioned(
                              top: -8,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: _isLive({'strSport': label}) || label == 'All'
                                      ? Colors.red
                                      : const Color(0xFF333333),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  count > 99 ? '99+' : '$count',
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Status filter row
            Container(
              height: 44,
              color: Colors.black,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                children: ['All', 'Live', 'Upcoming', 'Finished'].map((status) {
                  final selected = _statusFilter == status;
                  final count = _countFor(status);
                  return GestureDetector(
                    onTap: () => setState(() => _statusFilter = status),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF0D2F33) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? _cyan : const Color(0xFF333333),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selected)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.check_rounded, size: 14, color: Color(0xFF08C7D6)),
                            ),
                          Text(
                            '$status ($count)',
                            style: TextStyle(
                              color: selected ? _cyan : Colors.white54,
                              fontSize: 12,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Match list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.event_busy_rounded, color: Colors.white12, size: 60),
                        const SizedBox(height: 12),
                        const Text('No matches found', style: TextStyle(color: Colors.white38, fontSize: 15)),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _fetchMatches,
                          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF08C7D6)),
                          label: const Text('Refresh', style: TextStyle(color: Color(0xFF08C7D6))),
                        ),
                      ]),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchMatches,
                      color: _cyan,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 20),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) => _MatchCard(
                          match: filtered[i],
                          isLive: _isLive(filtered[i]),
                          isFinished: _isFinished(filtered[i]),
                          time: _formatTime(filtered[i]),
                          date: _formatDate(filtered[i]),
                          timeUntil: _timeUntil(filtered[i]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );
    }
  }

  class _MatchCard extends StatelessWidget {
    final Map<String, dynamic> match;
    final bool isLive;
    final bool isFinished;
    final String time;
    final String date;
    final String timeUntil;

    static const _cyan = Color(0xFF08C7D6);

    const _MatchCard({
      required this.match,
      required this.isLive,
      required this.isFinished,
      required this.time,
      required this.date,
      required this.timeUntil,
    });

    @override
    Widget build(BuildContext context) {
      final sport = match['strSport'] ?? '';
      final league = match['strLeague'] ?? sport;
      final home = match['strHomeTeam'] ?? '?';
      final away = match['strAwayTeam'] ?? '?';
      final homeBadge = match['strHomeTeamBadge'] ?? '';
      final awayBadge = match['strAwayTeamBadge'] ?? '';
      final homeScore = match['intHomeScore'];
      final awayScore = match['intAwayScore'];
      final hasScore = homeScore != null && awayScore != null;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLive
                ? Colors.red.withOpacity(0.5)
                : const Color(0xFF2A2A2A),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sport | League title row
              Row(
                children: [
                  Text(
                    sport.isNotEmpty && league != sport ? '$sport | $league' : league,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  if (isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.4)),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.circle, color: Colors.red, size: 6),
                        SizedBox(width: 3),
                        Text('LIVE', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Teams row
              Row(
                children: [
                  // Home team
                  Expanded(
                    child: Row(
                      children: [
                        _TeamBadge(url: homeBadge, name: home),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            home,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time/Score in center
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        if (hasScore)
                          Text(
                            '$homeScore - $awayScore',
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          )
                        else
                          Text(
                            time,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        if (date.isNotEmpty && !hasScore)
                          Text(date, style: const TextStyle(color: _cyan, fontSize: 11)),
                      ],
                    ),
                  ),
                  // Away team
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            away,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _TeamBadge(url: awayBadge, name: away),
                      ],
                    ),
                  ),
                ],
              ),
              // Time until
              if (timeUntil.isNotEmpty && !isLive && !isFinished) ...[
                const SizedBox(height: 8),
                const Divider(color: Color(0xFF1E1E1E), height: 1),
                const SizedBox(height: 6),
                Text(
                  timeUntil,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }
  }

  class _TeamBadge extends StatelessWidget {
    final String url;
    final String name;

    const _TeamBadge({required this.url, required this.name});

    @override
    Widget build(BuildContext context) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1E1E1E)),
        child: ClipOval(
          child: url.isNotEmpty
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
        ),
      );
    }
  }
  