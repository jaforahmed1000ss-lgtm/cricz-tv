import 'package:flutter/material.dart';
  import 'package:cached_network_image/cached_network_image.dart';
  import '../models/channel_model.dart';
  import '../services/firestore_service.dart';
  import 'channels_screen.dart';

  class CategoriesScreen extends StatelessWidget {
    const CategoriesScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: StreamBuilder<List<Channel>>(
          stream: FirestoreService.channelsStream(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF08C7D6)));
            }
            final channels = snap.data ?? [];
            // Group by category — each category becomes a card
            final Map<String, List<Channel>> grouped = {};
            for (final ch in channels) {
              grouped.putIfAbsent(ch.category, () => []).add(ch);
            }
            final categories = grouped.keys.toList()..sort();

            if (categories.isEmpty) {
              return const Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.live_tv_rounded, color: Colors.white12, size: 64),
                  SizedBox(height: 12),
                  Text('No categories found', style: TextStyle(color: Colors.white38, fontSize: 15)),
                ]),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: categories.length,
              itemBuilder: (ctx, i) {
                final cat = categories[i];
                final chs = grouped[cat]!;
                final first = chs.first;
                return _CategoryCard(
                  category: cat,
                  channel: first,
                  channelCount: chs.length,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChannelsScreen(filterCategory: cat),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }

  class _CategoryCard extends StatelessWidget {
    final String category;
    final Channel channel;
    final int channelCount;
    final VoidCallback onTap;

    const _CategoryCard({
      required this.category,
      required this.channel,
      required this.channelCount,
      required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF08C7D6), width: 0.8),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              // Circular logo
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E1E1E),
                ),
                child: ClipOval(
                  child: channel.logoUrl.isNotEmpty
                      ? Image.network(
                          channel.logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              category.isNotEmpty ? category[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Color(0xFF08C7D6),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            category.isNotEmpty ? category[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Color(0xFF08C7D6),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Category name
              Expanded(
                child: Text(
                  category.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      );
    }
  }
  