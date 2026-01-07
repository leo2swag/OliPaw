/*
  文件：utils/firebase_test_helper.dart
  说明：
  - Firebase 连接测试工具
  - 用于验证 Firebase 初始化和 Firestore 连接
  - 提供简单的测试方法供开发调试使用
*/

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/types.dart';
import '../services/firestore_service.dart';

/// Firebase 测试助手
class FirebaseTestHelper {
  static final FirestoreService _firestore = FirestoreService();

  /// 测试 Firestore 连接
  ///
  /// 尝试写入和读取一个测试文档
  static Future<bool> testConnection() async {
    try {
      debugPrint('[FirebaseTest] 🧪 Testing Firestore connection...');

      // 创建测试宠物
      final testPet = Pet(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Firebase Test Pet',
        type: PetType.DOG,
        breed: 'Test Breed',
        birthDate: '2024-01-01',
        avatarUrl: 'https://example.com/test.jpg',
        bio: 'This is a test pet for Firebase connection',
        vaccines: [],
        weightHistory: [],
        gallery: [],
        isFollowing: false,
        userId: 'test_user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
      );

      // 尝试保存
      await _firestore.savePet(testPet);
      debugPrint('[FirebaseTest] ✅ Test pet saved to Firestore');

      // 尝试读取
      final retrievedPet = await _firestore.getPet(testPet.id);
      if (retrievedPet != null && retrievedPet.name == testPet.name) {
        debugPrint('[FirebaseTest] ✅ Test pet retrieved successfully');
        debugPrint('[FirebaseTest] ✅ Firestore connection is working!');

        // 清理测试数据
        await _firestore.deletePet(testPet.id);
        debugPrint('[FirebaseTest] 🧹 Test pet cleaned up');

        return true;
      } else {
        debugPrint('[FirebaseTest] ❌ Failed to retrieve test pet');
        return false;
      }
    } catch (e) {
      debugPrint('[FirebaseTest] ❌ Firestore connection test failed: $e');
      return false;
    }
  }

  /// 检查 Firestore 是否可用
  static Future<bool> isFirestoreAvailable() async {
    try {
      // 尝试获取一个不存在的文档（快速检查）
      await FirebaseFirestore.instance
          .collection('_connection_test')
          .doc('test')
          .get();
      debugPrint('[FirebaseTest] ✅ Firestore is available');
      return true;
    } catch (e) {
      debugPrint('[FirebaseTest] ❌ Firestore is not available: $e');
      return false;
    }
  }

  /// 打印 Firestore 统计信息
  static Future<void> printStats() async {
    try {
      final pets = await _firestore.getAllPets();
      final posts = await _firestore.getAllPosts();

      debugPrint('[FirebaseTest] 📊 Firestore Stats:');
      debugPrint('[FirebaseTest]    - Pets: ${pets.length}');
      debugPrint('[FirebaseTest]    - Posts: ${posts.length}');
    } catch (e) {
      debugPrint('[FirebaseTest] ❌ Error getting stats: $e');
    }
  }
}
