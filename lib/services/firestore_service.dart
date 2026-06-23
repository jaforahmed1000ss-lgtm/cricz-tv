import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/channel_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<List<Channel>> channelsStream() {
    return _db
        .collection('channels')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Channel.fromFirestore(d)).toList());
  }

  static Stream<List<Channel>> allChannelsStream() {
    return _db
        .collection('channels')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Channel.fromFirestore(d)).toList());
  }

  static Future<List<Channel>> getAllChannels() async {
    final snap = await _db.collection('channels').orderBy('order').get();
    return snap.docs.map((d) => Channel.fromFirestore(d)).toList();
  }

  static Future<void> addChannel(Channel ch) async {
    await _db.collection('channels').add(ch.toMap());
  }

  static Future<void> updateChannel(Channel ch) async {
    await _db.collection('channels').doc(ch.id).update(ch.toMap());
  }

  static Future<void> deleteChannel(String id) async {
    await _db.collection('channels').doc(id).delete();
  }

  static Future<void> toggleActive(String id, bool isActive) async {
    await _db.collection('channels').doc(id).update({'isActive': isActive});
  }

  static Future<void> seedDefaultChannels() async {
    final snap = await _db.collection('channels').limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (int i = 0; i < ChannelData.defaultChannels.length; i++) {
      final ref = _db.collection('channels').doc();
      batch.set(ref, ChannelData.defaultChannels[i].copyWith(order: i).toMap());
    }
    await batch.commit();
  }
}
