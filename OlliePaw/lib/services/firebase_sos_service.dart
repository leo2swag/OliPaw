/*
  文件：services/firebase_sos_service.dart
  说明：
  - Firebase Firestore 集成服务
  - 负责 SOS 帖子和广播的云端持久化
  - 实时同步和查询

  功能：
  - 创建/更新/删除 SOS 帖子
  - 创建/更新广播
  - 提交和管理线索
  - 地理位置查询（附近帖子）
  - 实时数据流

  Firestore 结构：
  /sos_posts/{sosId}
    - petId, ownerId, petName, petBreed, petPhotoUrl
    - lastSeenLocation {lat, lon, address, city}
    - searchRadiusKm, treatsReward
    - status, createdAt, expiresAt
    - clueIds[]

  /clues/{clueId}
    - sosPostId, reporterId, description
    - location {lat, lon}
    - timestamp, helpful

  /broadcasts/{broadcastId}
    - type, authorId, title, content
    - location {lat, lon}, rangeKm
    - createdAt, expiresAt
    - treatsCost, likeCount

  v2.9 - Pet SOS Feature
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/sos_types.dart';

/// Firebase SOS 服务
class FirebaseSOSService {
  // Singleton 模式
  static final FirebaseSOSService _instance = FirebaseSOSService._internal();
  factory FirebaseSOSService() => _instance;
  FirebaseSOSService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 集合引用
  CollectionReference get _sosCollection => _firestore.collection('sos_posts');
  CollectionReference get _cluesCollection => _firestore.collection('clues');
  CollectionReference get _broadcastsCollection => _firestore.collection('broadcasts');

  // ==========================================================================
  // SOS 帖子管理
  // ==========================================================================

  /// 创建 SOS 帖子
  Future<String?> createSOSPost(SOSPost sos) async {
    try {
      final docRef = await _sosCollection.add(sos.toJson());
      debugPrint('[Firebase] SOS created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('[Firebase] Error creating SOS: $e');
      return null;
    }
  }

  /// 更新 SOS 帖子
  Future<bool> updateSOSPost(String sosId, Map<String, dynamic> updates) async {
    try {
      await _sosCollection.doc(sosId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[Firebase] SOS updated: $sosId');
      return true;
    } catch (e) {
      debugPrint('[Firebase] Error updating SOS: $e');
      return false;
    }
  }

  /// 删除 SOS 帖子（软删除）
  Future<bool> deleteSOSPost(String sosId) async {
    try {
      await _sosCollection.doc(sosId).update({
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[Firebase] SOS deleted: $sosId');
      return true;
    } catch (e) {
      debugPrint('[Firebase] Error deleting SOS: $e');
      return false;
    }
  }

  /// 获取单个 SOS 帖子
  Future<SOSPost?> getSOSPost(String sosId) async {
    try {
      final doc = await _sosCollection.doc(sosId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return SOSPost.fromJson({...data, 'id': doc.id});
    } catch (e) {
      debugPrint('[Firebase] Error getting SOS: $e');
      return null;
    }
  }

  /// 获取附近的 SOS 帖子（简化版 - 基于城市）
  ///
  /// 注意：真正的地理查询需要 GeoFlutterFire 或类似库
  /// 这里使用简化版本，仅按城市筛选
  Future<List<SOSPost>> getNearbySOSPosts({
    required String city,
    double radiusKm = 10.0,
  }) async {
    try {
      final snapshot = await _sosCollection
          .where('lastSeenLocation.city', isEqualTo: city)
          .where('status', isEqualTo: 'active')
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SOSPost.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('[Firebase] Error getting nearby SOS: $e');
      return [];
    }
  }

  /// 实时监听附近 SOS 帖子
  Stream<List<SOSPost>> watchNearbySOSPosts({
    required String city,
  }) {
    return _sosCollection
        .where('lastSeenLocation.city', isEqualTo: city)
        .where('status', isEqualTo: 'active')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SOSPost.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  /// 扩展搜索范围
  Future<bool> expandSearchRadius(String sosId, double newRadiusKm, int additionalReward) async {
    try {
      await _sosCollection.doc(sosId).update({
        'searchRadiusKm': newRadiusKm,
        'treatsReward': FieldValue.increment(additionalReward),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[Firebase] Search radius expanded: $sosId');
      return true;
    } catch (e) {
      debugPrint('[Firebase] Error expanding radius: $e');
      return false;
    }
  }

  /// 标记 SOS 为已解决
  Future<bool> resolveSOSPost(String sosId, {String? finderId}) async {
    try {
      await _sosCollection.doc(sosId).update({
        'status': 'resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
        if (finderId != null) 'finderId': finderId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[Firebase] SOS resolved: $sosId');
      return true;
    } catch (e) {
      debugPrint('[Firebase] Error resolving SOS: $e');
      return false;
    }
  }

  // ==========================================================================
  // 线索管理
  // ==========================================================================

  /// 提交线索
  Future<String?> submitClue(ClueReport clue) async {
    try {
      final docRef = await _cluesCollection.add(clue.toJson());

      // 更新 SOS 帖子的线索 ID 列表
      await _sosCollection.doc(clue.sosPostId).update({
        'clueIds': FieldValue.arrayUnion([docRef.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[Firebase] Clue submitted: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('[Firebase] Error submitting clue: $e');
      return null;
    }
  }

  /// 获取 SOS 的所有线索
  Future<List<ClueReport>> getCluesForSOS(String sosId) async {
    try {
      final snapshot = await _cluesCollection
          .where('sosPostId', isEqualTo: sosId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ClueReport.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('[Firebase] Error getting clues: $e');
      return [];
    }
  }

  /// 实时监听 SOS 的线索
  Stream<List<ClueReport>> watchCluesForSOS(String sosId) {
    return _cluesCollection
        .where('sosPostId', isEqualTo: sosId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ClueReport.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  /// 标记线索为有用
  Future<bool> markClueAsHelpful(String clueId) async {
    try {
      await _cluesCollection.doc(clueId).update({
        'helpful': true,
        'verifiedByOwner': true,
      });
      debugPrint('[Firebase] Clue marked as helpful: $clueId');
      return true;
    } catch (e) {
      debugPrint('[Firebase] Error marking clue: $e');
      return false;
    }
  }

  // ==========================================================================
  // 广播管理
  // ==========================================================================

  /// 创建广播
  Future<String?> createBroadcast(CommunityBroadcast broadcast) async {
    try {
      final docRef = await _broadcastsCollection.add(broadcast.toJson());
      debugPrint('[Firebase] Broadcast created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('[Firebase] Error creating broadcast: $e');
      return null;
    }
  }

  /// 获取附近的广播
  Future<List<CommunityBroadcast>> getNearbyBroadcasts({
    required String city,
    BroadcastType? filterType,
    double radiusKm = 5.0,
  }) async {
    try {
      Query query = _broadcastsCollection
          .where('location.city', isEqualTo: city)
          .where('isDeleted', isEqualTo: false);

      if (filterType != null) {
        query = query.where('type', isEqualTo: filterType.name);
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CommunityBroadcast.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('[Firebase] Error getting broadcasts: $e');
      return [];
    }
  }

  /// 实时监听附近广播
  Stream<List<CommunityBroadcast>> watchNearbyBroadcasts({
    required String city,
    BroadcastType? filterType,
  }) {
    Query query = _broadcastsCollection
        .where('location.city', isEqualTo: city)
        .where('isDeleted', isEqualTo: false);

    if (filterType != null) {
      query = query.where('type', isEqualTo: filterType.name);
    }

    return query
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CommunityBroadcast.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  /// 点赞广播
  Future<bool> likeBroadcast(String broadcastId) async {
    try {
      await _broadcastsCollection.doc(broadcastId).update({
        'likeCount': FieldValue.increment(1),
      });
      debugPrint('[Firebase] Broadcast liked: $broadcastId');
      return true;
    } catch (e) {
      debugPrint('[Firebase] Error liking broadcast: $e');
      return false;
    }
  }

  /// 删除过期广播（定期清理任务）
  Future<int> deleteExpiredBroadcasts() async {
    try {
      final now = Timestamp.now();
      final snapshot = await _broadcastsCollection
          .where('expiresAt', isLessThan: now)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isDeleted': true});
      }
      await batch.commit();

      debugPrint('[Firebase] Deleted ${snapshot.size} expired broadcasts');
      return snapshot.size;
    } catch (e) {
      debugPrint('[Firebase] Error deleting expired broadcasts: $e');
      return 0;
    }
  }

  // ==========================================================================
  // 高级地理查询（需要 GeoFlutterFire 库）
  // ==========================================================================

  /// 真正的地理范围查询
  ///
  /// 要实现这个功能，需要：
  /// 1. 添加依赖：geoflutterfire: ^3.0.0
  /// 2. 在数据中存储 geohash
  /// 3. 使用 GeoFlutterFire 进行查询
  ///
  /// 示例代码（未实现）：
  /// ```dart
  /// Future<List<SOSPost>> getSOSPostsWithinRadius(
  ///   GeoFirePoint center,
  ///   double radiusInKm,
  /// ) async {
  ///   final geo = Geoflutterfire();
  ///   final collectionRef = _firestore.collection('sos_posts');
  ///
  ///   Stream<List<DocumentSnapshot>> stream = geo.collection(
  ///     collectionRef: collectionRef
  ///   ).within(
  ///     center: center,
  ///     radius: radiusInKm,
  ///     field: 'position',
  ///   );
  ///
  ///   final docs = await stream.first;
  ///   return docs.map((doc) => SOSPost.fromJson(doc.data())).toList();
  /// }
  /// ```

  // ==========================================================================
  // 批量操作
  // ==========================================================================

  /// 批量更新 SOS 状态（清理过期帖子）
  Future<int> expireOldSOSPosts() async {
    try {
      final now = Timestamp.now();
      final snapshot = await _sosCollection
          .where('status', isEqualTo: 'active')
          .where('expiresAt', isLessThan: now)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'status': 'expired',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      debugPrint('[Firebase] Expired ${snapshot.size} old SOS posts');
      return snapshot.size;
    } catch (e) {
      debugPrint('[Firebase] Error expiring SOS posts: $e');
      return 0;
    }
  }

  // ==========================================================================
  // 统计和分析
  // ==========================================================================

  /// 获取用户创建的 SOS 数量
  Future<int> getUserSOSCount(String userId) async {
    try {
      final snapshot = await _sosCollection
          .where('ownerId', isEqualTo: userId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('[Firebase] Error getting SOS count: $e');
      return 0;
    }
  }

  /// 获取用户提交的线索数量
  Future<int> getUserClueCount(String userId) async {
    try {
      final snapshot = await _cluesCollection
          .where('reporterId', isEqualTo: userId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('[Firebase] Error getting clue count: $e');
      return 0;
    }
  }

  /// 获取用户帮助找到的宠物数量
  Future<int> getUserResolvedCount(String userId) async {
    try {
      final snapshot = await _sosCollection
          .where('finderId', isEqualTo: userId)
          .where('status', isEqualTo: 'resolved')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('[Firebase] Error getting resolved count: $e');
      return 0;
    }
  }
}
