import 'package:shared_preferences/shared_preferences.dart';
  import '../models/channel_model.dart';
  import 'firestore_service.dart';

  class FavoritesService {
    static const _key = 'fav_channel_ids';

    static Future<List<String>> getFavoriteIds() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_key) ?? [];
    }

    static Future<bool> isFavorite(String channelId) async {
      final ids = await getFavoriteIds();
      return ids.contains(channelId);
    }

    static Future<bool> toggleFavorite(String channelId) async {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_key) ?? [];
      final wasFav = ids.contains(channelId);
      if (wasFav) {
        ids.remove(channelId);
      } else {
        ids.add(channelId);
      }
      await prefs.setStringList(_key, ids);
      return !wasFav;
    }

    static Future<List<Channel>> getFavoriteChannels() async {
      final ids = await getFavoriteIds();
      if (ids.isEmpty) return [];
      final allChannels = await FirestoreService.getAllChannels();
      return allChannels.where((c) => ids.contains(c.id)).toList();
    }
  }
  