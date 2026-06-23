import 'package:flutter/material.dart';
import '../models/channel_model.dart';
import '../services/firestore_service.dart';

const _adminPin = '2024';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _pinCtrl = TextEditingController();
  bool _wrong = false;

  void _verify() {
    if (_pinCtrl.text == _adminPin) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
    } else {
      setState(() => _wrong = true);
      _pinCtrl.clear();
    }
  }

  @override
  void dispose() { _pinCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Admin Login', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: const Color(0xFF00D2FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.4))),
                child: const Icon(Icons.admin_panel_settings, color: Color(0xFF00D2FF), size: 48),
              ),
              const SizedBox(height: 24),
              const Text('Enter Admin PIN',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: _pinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 24),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '● ● ● ●',
                  hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 8),
                  filled: true,
                  fillColor: const Color(0xFF0E161B),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _wrong ? Colors.red : Colors.transparent)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00D2FF))),
                ),
                onSubmitted: (_) => _verify(),
              ),
              if (_wrong) ...[
                const SizedBox(height: 8),
                const Text('Wrong PIN. Try again.',
                    style: TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D2FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _verify,
                  child: const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  List<Channel> _channels = [];
  bool _loading = true;
  String _filterCat = 'All';

  final List<String> _categories = ['All', 'FIFA 2026', 'Football', 'Cricket', 'Sports', 'BD Sports'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _channels = await FirestoreService.getAllChannels();
    if (_channels.isEmpty) _channels = ChannelData.defaultChannels;
    setState(() => _loading = false);
  }

  List<Channel> get _filtered =>
      _filterCat == 'All' ? _channels : _channels.where((c) => c.category == _filterCat).toList();

  void _showAddEdit({Channel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final urlCtrl = TextEditingController(text: existing?.streamUrl ?? '');
    final logoCtrl = TextEditingController(text: existing?.logoUrl ?? '');
    String selectedCat = existing?.category ?? 'FIFA 2026';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Padding(
          padding: EdgeInsets.only(
              left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(existing == null ? 'Add Channel' : 'Edit Channel',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _field('Channel Name', nameCtrl, 'e.g. beIN Sports 1'),
                const SizedBox(height: 12),
                _field('Stream URL (M3U8)', urlCtrl, 'https://example.com/stream/index.m3u8'),
                const SizedBox(height: 12),
                _field('Logo URL (optional)', logoCtrl, 'https://...'),
                const SizedBox(height: 12),
                const Text('Category', style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: ['FIFA 2026', 'Football', 'Cricket', 'Sports', 'BD Sports'].map((cat) {
                    final sel = selectedCat == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: sel,
                      onSelected: (_) => setM(() => selectedCat = cat),
                      selectedColor: const Color(0xFF00D2FF),
                      backgroundColor: const Color(0xFF0E161B),
                      labelStyle: TextStyle(
                          color: sel ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white60,
                          side: const BorderSide(color: Color(0xFF222222)),
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D2FF),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty || urlCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Name and URL are required'),
                              backgroundColor: Colors.red));
                          return;
                        }
                        Navigator.pop(ctx);
                        final ch = Channel(
                          id: existing?.id ?? '',
                          name: nameCtrl.text.trim(),
                          category: selectedCat,
                          streamUrl: urlCtrl.text.trim(),
                          logoUrl: logoCtrl.text.trim(),
                          isActive: existing?.isActive ?? true,
                          order: existing?.order ?? _channels.length,
                        );
                        if (existing == null) {
                          await FirestoreService.addChannel(ch);
                        } else {
                          await FirestoreService.updateChannel(ch);
                        }
                        _load();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(existing == null ? '✅ Channel added!' : '✅ Channel updated!'),
                            backgroundColor: Colors.green,
                          ));
                        }
                      },
                      child: Text(existing == null ? 'Add' : 'Save'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF0E161B),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF00D2FF))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteChannel(Channel ch) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Delete Channel', style: TextStyle(color: Colors.white)),
        content: Text('Delete "${ch.name}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await FirestoreService.deleteChannel(ch.id);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deleted'), backgroundColor: Colors.orange));
      }
    }
  }

  Future<void> _seedChannels() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Seed Default Channels', style: TextStyle(color: Colors.white)),
        content: const Text('This will add all default channels to Firestore. Continue?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes', style: TextStyle(color: Color(0xFF00D2FF)))),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _loading = true);
      for (int i = 0; i < ChannelData.defaultChannels.length; i++) {
        await FirestoreService.addChannel(ChannelData.defaultChannels[i].copyWith(order: i));
      }
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('✅ ${ChannelData.defaultChannels.length} channels added!'),
            backgroundColor: Colors.green));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF050B0F),
        title: const Text('Admin Panel',
            style: TextStyle(color: Color(0xFF00D2FF), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              tooltip: 'Seed Defaults',
              onPressed: _seedChannels),
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00D2FF),
        foregroundColor: Colors.black,
        onPressed: () => _showAddEdit(),
        icon: const Icon(Icons.add),
        label: const Text('Add Channel', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF060E14),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(children: [
              const Icon(Icons.filter_list, color: Colors.white60, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final sel = _filterCat == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _filterCat = cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFF00D2FF) : const Color(0xFF0E161B),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(cat,
                              style: TextStyle(
                                  color: sel ? Colors.black : Colors.white,
                                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Text('${_filtered.length}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ]),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF)))
                : _filtered.isEmpty
                    ? Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.live_tv_outlined, color: Colors.white24, size: 64),
                          const SizedBox(height: 12),
                          const Text('No channels yet',
                              style: TextStyle(color: Colors.white38, fontSize: 16)),
                          const SizedBox(height: 8),
                          TextButton.icon(
                              onPressed: _seedChannels,
                              icon: const Icon(Icons.download_rounded, color: Color(0xFF00D2FF)),
                              label: const Text('Seed Default Channels',
                                  style: TextStyle(color: Color(0xFF00D2FF)))),
                        ]),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final ch = _filtered[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF02090F),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: ch.isActive
                                      ? const Color(0xFF00D2FF).withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2)),
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF0E1C26),
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.live_tv,
                                    color: Color(0xFF00D2FF), size: 22),
                              ),
                              title: Text(ch.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(ch.category,
                                      style: const TextStyle(
                                          color: Color(0xFF00D2FF), fontSize: 11)),
                                  Text(ch.streamUrl,
                                      style: const TextStyle(
                                          color: Colors.white24, fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: ch.isActive,
                                    activeColor: const Color(0xFF00D2FF),
                                    onChanged: (v) async {
                                      await FirestoreService.toggleActive(ch.id, v);
                                      _load();
                                    },
                                  ),
                                  PopupMenuButton<String>(
                                    color: const Color(0xFF111111),
                                    icon: const Icon(Icons.more_vert, color: Colors.white54),
                                    onSelected: (val) {
                                      if (val == 'edit') _showAddEdit(existing: ch);
                                      if (val == 'delete') _deleteChannel(ch);
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(children: [
                                            Icon(Icons.edit, color: Color(0xFF00D2FF), size: 18),
                                            SizedBox(width: 8),
                                            Text('Edit', style: TextStyle(color: Colors.white))
                                          ])),
                                      const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(children: [
                                            Icon(Icons.delete, color: Colors.red, size: 18),
                                            SizedBox(width: 8),
                                            Text('Delete', style: TextStyle(color: Colors.red))
                                          ])),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
