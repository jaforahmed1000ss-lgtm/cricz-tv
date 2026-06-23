import '../models/channel_model.dart';

  class FirestoreService {
    static List<Channel> _channels = List.from(ChannelData.defaultChannels);

    static Stream<List<Channel>> channelsStream() async* {
      yield _channels.where((c) => c.isActive).toList();
    }

    static Stream<List<Channel>> allChannelsStream() async* {
      yield List.from(_channels);
    }

    static Future<List<Channel>> getAllChannels() async {
      return List.from(_channels);
    }

    static Future<void> addChannel(Channel ch) async {
      _channels.add(ch.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString()));
    }

    static Future<void> updateChannel(Channel ch) async {
      final idx = _channels.indexWhere((c) => c.id == ch.id);
      if (idx != -1) _channels[idx] = ch;
    }

    static Future<void> deleteChannel(String id) async {
      _channels.removeWhere((c) => c.id == id);
    }

    static Future<void> toggleActive(String id, bool isActive) async {
      final idx = _channels.indexWhere((c) => c.id == id);
      if (idx != -1) _channels[idx] = _channels[idx].copyWith(isActive: isActive);
    }

    static Future<void> seedDefaultChannels() async {
      // Already seeded with static data
    }
  }
  