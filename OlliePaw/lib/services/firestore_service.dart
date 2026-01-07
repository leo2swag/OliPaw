/*
  文件：services/firestore_service.dart
  说明：
  - Firebase Firestore 云数据库服务类
  - 负责所有 Firestore 的 CRUD 操作
  - 支持宠物档案、帖子、健康记录的云端存储和同步

  架构设计：
  - 单例模式，全局共享一个实例
  - 异步操作，返回 Future
  - 错误处理和日志记录
  - 支持软删除（isDeleted 字段）
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/types.dart';

/// Firestore 云数据库服务
///
/// 提供宠物、帖子、健康记录等数据的云端存储功能
/// 使用软删除策略（标记 isDeleted 而非真删除）
class FirestoreService {
  // Firestore 实例
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 集合名称常量
  static const String petsCollection = 'pets';
  static const String postsCollection = 'posts';
  static const String usersCollection = 'users';

  // 子集合名称
  static const String vaccinesSubcollection = 'vaccines';
  static const String weightHistorySubcollection = 'weightHistory';
  static const String gallerySubcollection = 'gallery';

  // ==================== Pet 操作 ====================

  /// 保存或更新宠物档案
  ///
  /// 使用 SetOptions(merge: true) 实现 upsert 操作
  /// - 如果文档不存在，创建新文档
  /// - 如果文档存在，只更新提供的字段
  Future<void> savePet(Pet pet) async {
    try {
      final now = DateTime.now();

      // 准备数据（添加时间戳）
      final data = pet.toJson();
      data['createdAt'] = pet.createdAt?.toIso8601String() ?? now.toIso8601String();
      data['updatedAt'] = now.toIso8601String();
      data['isDeleted'] = false;

      await _firestore
          .collection(petsCollection)
          .doc(pet.id)
          .set(data, SetOptions(merge: true));

      debugPrint('[Firestore] ✅ Pet saved: ${pet.name} (${pet.id})');
    } catch (e) {
      debugPrint('[Firestore] ❌ Error saving pet: $e');
      rethrow;
    }
  }

  /// 获取单个宠物档案
  ///
  /// 返回 Pet 对象，如果不存在返回 null
  Future<Pet?> getPet(String petId) async {
    try {
      final doc = await _firestore
          .collection(petsCollection)
          .doc(petId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data()!;

      // 检查是否已被软删除
      if (data['isDeleted'] == true) {
        return null;
      }

      return Pet.fromJson(data);
    } catch (e) {
      debugPrint('[Firestore] ❌ Error getting pet: $e');
      return null;
    }
  }

  /// 获取所有宠物（未删除）
  ///
  /// 按创建时间倒序排序
  Future<List<Pet>> getAllPets() async {
    try {
      final snapshot = await _firestore
          .collection(petsCollection)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Pet.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('[Firestore] ❌ Error getting all pets: $e');
      return [];
    }
  }

  /// 删除宠物（软删除）
  ///
  /// 只标记 isDeleted=true，不真正删除数据
  /// 便于数据恢复和审计
  Future<void> deletePet(String petId) async {
    try {
      await _firestore
          .collection(petsCollection)
          .doc(petId)
          .update({
        'isDeleted': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('[Firestore] ✅ Pet soft-deleted: $petId');
    } catch (e) {
      debugPrint('[Firestore] ❌ Error deleting pet: $e');
      rethrow;
    }
  }

  // ==================== Post 操作 ====================

  /// 创建帖子
  Future<void> createPost(Post post) async {
    try {
      final now = DateTime.now();

      final data = post.toJson();
      data['createdAt'] = now.toIso8601String();
      data['updatedAt'] = now.toIso8601String();
      data['isDeleted'] = false;

      await _firestore
          .collection(postsCollection)
          .doc(post.id)
          .set(data);

      debugPrint('[Firestore] ✅ Post created: ${post.id}');
    } catch (e) {
      debugPrint('[Firestore] ❌ Error creating post: $e');
      rethrow;
    }
  }

  /// 获取指定宠物的所有帖子
  Future<List<Post>> getPostsForPet(String petId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(postsCollection)
          .where('petId', isEqualTo: petId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Post.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('[Firestore] ❌ Error getting posts for pet: $e');
      return [];
    }
  }

  /// 获取时间线帖子（所有宠物）
  Future<List<Post>> getAllPosts({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(postsCollection)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Post.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('[Firestore] ❌ Error getting all posts: $e');
      return [];
    }
  }

  /// 删除帖子（软删除）
  Future<void> deletePost(String postId) async {
    try {
      await _firestore
          .collection(postsCollection)
          .doc(postId)
          .update({
        'isDeleted': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('[Firestore] ✅ Post soft-deleted: $postId');
    } catch (e) {
      debugPrint('[Firestore] ❌ Error deleting post: $e');
      rethrow;
    }
  }

  // ==================== Vaccine 子集合操作 ====================

  /// 添加疫苗记录到宠物
  Future<void> addVaccine(String petId, Vaccine vaccine) async {
    try {
      await _firestore
          .collection(petsCollection)
          .doc(petId)
          .collection(vaccinesSubcollection)
          .doc(vaccine.id)
          .set(vaccine.toJson());

      // 更新父文档的 updatedAt
      await _firestore
          .collection(petsCollection)
          .doc(petId)
          .update({'updatedAt': DateTime.now().toIso8601String()});

      debugPrint('[Firestore] ✅ Vaccine added to pet $petId');
    } catch (e) {
      debugPrint('[Firestore] ❌ Error adding vaccine: $e');
      rethrow;
    }
  }

  /// 获取宠物的所有疫苗记录
  Future<List<Vaccine>> getVaccines(String petId) async {
    try {
      final snapshot = await _firestore
          .collection(petsCollection)
          .doc(petId)
          .collection(vaccinesSubcollection)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Vaccine.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('[Firestore] ❌ Error getting vaccines: $e');
      return [];
    }
  }

  // ==================== Weight History 子集合操作 ====================

  /// 添加体重记录到宠物
  Future<void> addWeightRecord(String petId, WeightRecord record) async {
    try {
      await _firestore
          .collection(petsCollection)
          .doc(petId)
          .collection(weightHistorySubcollection)
          .doc(record.id)
          .set(record.toJson());

      // 更新父文档的 updatedAt
      await _firestore
          .collection(petsCollection)
          .doc(petId)
          .update({'updatedAt': DateTime.now().toIso8601String()});

      debugPrint('[Firestore] ✅ Weight record added to pet $petId');
    } catch (e) {
      debugPrint('[Firestore] ❌ Error adding weight record: $e');
      rethrow;
    }
  }

  /// 获取宠物的体重历史
  Future<List<WeightRecord>> getWeightHistory(String petId) async {
    try {
      final snapshot = await _firestore
          .collection(petsCollection)
          .doc(petId)
          .collection(weightHistorySubcollection)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WeightRecord.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('[Firestore] ❌ Error getting weight history: $e');
      return [];
    }
  }

  // ==================== Gallery 子集合操作 ====================

  /// 添加照片到画廊
  Future<void> addGalleryPhoto(String petId, String photoUrl) async {
    try {
      final galleryItem = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'url': photoUrl,
        'uploadedAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection(petsCollection)
          .doc(petId)
          .collection(gallerySubcollection)
          .add(galleryItem);

      // 更新父文档的 updatedAt
      await _firestore
          .collection(petsCollection)
          .doc(petId)
          .update({'updatedAt': DateTime.now().toIso8601String()});

      debugPrint('[Firestore] ✅ Gallery photo added to pet $petId');
    } catch (e) {
      debugPrint('[Firestore] ❌ Error adding gallery photo: $e');
      rethrow;
    }
  }

  /// 获取宠物的画廊照片
  Future<List<String>> getGallery(String petId, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection(petsCollection)
          .doc(petId)
          .collection(gallerySubcollection)
          .orderBy('uploadedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['url'] as String)
          .toList();
    } catch (e) {
      debugPrint('[Firestore] ❌ Error getting gallery: $e');
      return [];
    }
  }

  // ==================== 用户操作 ====================

  /// 保存用户档案
  Future<void> saveUserProfile(UserProfile user) async {
    try {
      final data = user.toJson();
      data['createdAt'] = DateTime.now().toIso8601String();
      data['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore
          .collection(usersCollection)
          .doc(user.id)
          .set(data, SetOptions(merge: true));

      debugPrint('[Firestore] ✅ User profile saved: ${user.name}');
    } catch (e) {
      debugPrint('[Firestore] ❌ Error saving user profile: $e');
      rethrow;
    }
  }

  /// 获取用户档案
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserProfile.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('[Firestore] ❌ Error getting user profile: $e');
      return null;
    }
  }
}
