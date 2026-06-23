import 'package:flutter/material.dart';
  import 'package:cached_network_image/cached_network_image.dart';
  import '../models/channel_model.dart';
  import '../services/firestore_service.dart';
  import '../services/favorites_service.dart';
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
        appBar: widget.filterCategory != null
            ? AppBar(
                backgroundColor: Colors.black,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  widget.filterCategory!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: Colors.white),
                    onPressed: () => _showSearch(context),
                  ),
                ],
              )
            : null,
        body: Column(
          children: [
            if (widget.filterCategory == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: TextField(
                  controller: _ctrl,
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search channels...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.white38, size: 18),
                            onPressed: () {
                              _ctrl.clear();
                              setState(() => _search = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: StreamBuilder<List<Channel>>(
                stream: FirestoreService.channelsStream(),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF08C7D6)));
                  }
                  var channels = snap.data ?? [];
                  if (widget.filterCategory != null) {
                    channels = channels.where((c) => c.category == widget.filterCategory).toList();
                  }
                  if (_search.isNotEmpty) {
                    channels = channels.where((c) => c.name.toLowerCase().contains(_search)).toList();
                  }
                  if (channels.isEmpty) {
                    return const Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.tv_off_rounded, color: Colors.white12, size: 64),
                        SizedBox(height: 12),
                        Text('No channels found', style: TextStyle(color: Colors.white38, fontSize: 15)),
                      ]),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: channels.length,
                    itemBuilder: (ctx, i) => _ChannelTile(channel: channels[i]),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    void _showSearch(BuildContext context) {
      showSearch(context: context, delegate: _ChannelSearchDelegate());
    }
  }

  class _ChannelTile extends StatefulWidget {
    final Channel channel;
    const _ChannelTile({required this.channel});

    @override
    State<_ChannelTile> createState() => _ChannelTileState();
  }

  class _ChannelTileState extends State<_ChannelTile> {
    bool _isFav = false;

    @override
    void initState() {
      super.initState();
      FavoritesService.isFavorite(widget.channel.id).then((v) {
        if (mounted) setState(() => _isFav = v);
      });
    }

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(channel: widget.channel),
          ),
        ),
        onLongPress: () async {
          await FavoritesService.toggle(widget.channel.id, widget.channel.name);
          final fav = await FavoritesService.isFavorite(widget.channel.id);
          if (mounted) {
            setState(() => _isFav = fav);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(fav ? 'Added to favorites' : 'Removed from favorites'),
              duration: const Duration(seconds: 1),
              backgroundColor: const Color(0xFF1A1A1A),
            ));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular logo
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E1E1E),
                ),
                child: ClipOval(
                  child: widget.channel.logoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.channel.logoUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: Icon(Icons.live_tv_rounded, color: Color(0xFF08C7D6), size: 24),
                          ),
                          errorWidget: (_, __, ___) => Center(
                            child: Text(
                              widget.channel.name.isNotEmpty
                                  ? widget.channel.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Color(0xFF08C7D6),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            widget.channel.name.isNotEmpty
                                ? widget.channel.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Color(0xFF08C7D6),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.channel.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  class _ChannelSearchDelegate extends SearchDelegate<Channel?> {
    @override
    ThemeData appBarTheme(BuildContext context) => ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF111111)),
      inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
    );

    @override
    List<Widget> buildActions(BuildContext context) => [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];

    @override
    Widget buildLeading(BuildContext context) =>
        IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

    @override
    Widget buildResults(BuildContext context) => _buildSuggestions();

    @override
    Widget buildSuggestions(BuildContext context) => _buildSuggestions();

    Widget _buildSuggestions() {
      return StreamBuilder<List<Channel>>(
        stream: FirestoreService.channelsStream(),
        builder: (ctx, snap) {
          final all = snap.data ?? [];
          final filtered = query.isEmpty
              ? all
              : all.where((c) => c.name.toLowerCase().contains(query.toLowerCase())).toList();
          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final ch = filtered[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1E1E1E),
                  child: ch.logoUrl.isNotEmpty
                      ? CachedNetworkImage(imageUrl: ch.logoUrl, fit: BoxFit.cover)
                      : Text(ch.name[0], style: const TextStyle(color: Color(0xFF08C7D6))),
                ),
                title: Text(ch.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(ch.category, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                onTap: () => close(ctx, ch),
              );
            },
          );
        },
      );
    }
  }
  