/*
  文件：services/persistence_service.dart
  说明：
  - 数据持久化服务，统一管理本地和云端数据存储
  - 使用 Hive 存储复杂对象（Pet, UserProfile）- 本地快速访问
  - 使用 SharedPreferences 存储简单值（Treats, 签到日期）
  - 使用 Firestore 云端备份和多设备同步

  职责分工：
  - Hive: 复杂对象的结构化存储（本地，离线优先）
  - SharedPreferences: 简单键值对存储（本地）
  - Firestore: 云端备份和同步（可选启用）

  双写模式（v2.6 - Firebase 集成）：
  - 启用云同步后，数据会同时写入 Hive（本地）和 Firestore（云端）
  - 本地优先：读取总是从 Hive（快速），异步同步到云端
  - 错误容错：云端写入失败不影响本地操作
*/
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_hive_model.dart';
import '../models/user_hive_model.dart';
import '../models/types.dart';
import 'firestore_service.dart';

/// 数据持久化服务
///
/// 提供统一的数据持久化接口
class PersistenceService {
  // ==========================================================================
  // Hive Box 名称
  // ==========================================================================

  static const String _petBoxName = 'pets';
  static const String _userBoxName = 'users';

  // ==========================================================================
  // SharedPreferences 键
  // ==========================================================================

  static const String _treatsKey = 'treats';
  static const String _lastCheckInKey = 'last_checkin';
  static const String _consecutiveDaysKey = 'consecutive_days';
  static const String _currentPetIdKey = 'current_pet_id';
  static const String _currentUserIdKey = 'current_user_id';

  // ==========================================================================
  // 实例变量
  // ==========================================================================

  late Box<PetHiveModel> _petBox;
  late Box<UserHiveModel> _userBox;
  late SharedPreferences _prefs;

  // Firebase 云同步
  final FirestoreService _firestore = FirestoreService();
  bool _cloudSyncEnabled = false;

  // ==========================================================================
  // 初始化
  // ==========================================================================

  /// 初始化持久化服务
  ///
  /// 必须在 runApp 之前调用
  Future<void> initialize() async {
    // 初始化 Hive
    await Hive.initFlutter();

    // 注册适配器
    Hive.registerAdapter(PetHiveModelAdapter());
    Hive.registerAdapter(UserHiveModelAdapter());

    // 打开 boxes
    _petBox = await Hive.openBox<PetHiveModel>(_petBoxName);
    _userBox = await Hive.openBox<UserHiveModel>(_userBoxName);

    // 初始化 SharedPreferences
    _prefs = await SharedPreferences.getInstance();

    // 检查是否启用云同步（从本地配置读取）
    _cloudSyncEnabled = _prefs.getBool('cloud_sync_enabled') ?? false;
    if (_cloudSyncEnabled) {
      debugPrint('[PersistenceService] ☁️ Cloud sync enabled');
    }
  }

  // ==========================================================================
  // 云同步控制
  // ==========================================================================

  /// 启用云同步
  Future<void> enableCloudSync() async {
    _cloudSyncEnabled = true;
    await _prefs.setBool('cloud_sync_enabled', true);
    debugPrint('[PersistenceService] ☁️ Cloud sync enabled');
  }

  /// 禁用云同步
  Future<void> disableCloudSync() async {
    _cloudSyncEnabled = false;
    await _prefs.setBool('cloud_sync_enabled', false);
    debugPrint('[PersistenceService] 📴 Cloud sync disabled');
  }

  /// 获取云同步状态
  bool get isCloudSyncEnabled => _cloudSyncEnabled;

  // ==========================================================================
  // Pet 操作
  // ==========================================================================

  /// 保存宠物（双写：本地 + 云端）
  ///
  /// 返回：成功返回 true，失败返回 false
  Future<bool> savePet(Pet pet) async {
    try {
      // 1. 本地保存（Hive） - 必须成功
      final model = PetHiveModel.fromPet(pet);
      await _petBox.put(pet.id, model);
      debugPrint('[PersistenceService] ✅ Pet saved locally: ${pet.name}');

      // 2. 云端保存（Firestore） - 可选，失败不影响本地
      if (_cloudSyncEnabled) {
        try {
          await _firestore.savePet(pet);
          debugPrint('[PersistenceService] ☁️ Pet synced to cloud: ${pet.name}');
        } catch (e) {
          debugPrint('[PersistenceService] ⚠️ Cloud sync failed (local saved): $e');
          // 不返回 false，因为本地保存成功了
        }
      }

      return true;
    } on HiveError catch (e) {
      debugPrint('[PersistenceService] ❌ Hive error saving pet ${pet.id}: $e');
      return false;
    } catch (e) {
      debugPrint('[PersistenceService] ❌ Unexpected error saving pet ${pet.id}: $e');
      return false;
    }
  }

  /// 获取宠物
  ///
  /// 返回：成功返回 Pet 对象，失败或不存在返回 null
  Pet? getPet(String id) {
    try {
      final model = _petBox.get(id);
      return model?.toPet();
    } on HiveError catch (e) {
      debugPrint('[PersistenceService] Hive error getting pet $id: $e');
      return null;
    } catch (e) {
      debugPrint('[PersistenceService] Unexpected error getting pet $id: $e');
      return null;
    }
  }

  /// 获取所有宠物
  ///
  /// 返回：宠物列表，失败返回空列表
  List<Pet> getAllPets() {
    try {
      return _petBox.values.map((model) => model.toPet()).toList();
    } on HiveError catch (e) {
      debugPrint('[PersistenceService] Hive error getting all pets: $e');
      return [];
    } catch (e) {
      debugPrint('[PersistenceService] Unexpected error getting all pets: $e');
      return [];
    }
  }

  /// 删除宠物
  ///
  /// 返回：成功返回 true，失败返回 false
  Future<bool> deletePet(String id) async {
    try {
      await _petBox.delete(id);
      return true;
    } on HiveError catch (e) {
      debugPrint('[PersistenceService] Hive error deleting pet $id: $e');
      return false;
    } catch (e) {
      debugPrint('[PersistenceService] Unexpected error deleting pet $id: $e');
      return false;
    }
  }

  /// 保存当前宠物 ID
  ///
  /// 返回：成功返回 true，失败返回 false
  Future<bool> saveCurrentPetId(String id) async {
    try {
      await _prefs.setString(_currentPetIdKey, id);
      return true;
    } catch (e) {
      debugPrint('[PersistenceService] Error saving current pet ID: $e');
      return false;
    }
  }

  /// 获取当前宠物 ID
  ///
  /// 返回：宠物 ID 或 null
  String? getCurrentPetId() {
    try {
      return _prefs.getString(_currentPetIdKey);
    } catch (e) {
      debugPrint('[PersistenceService] Error getting current pet ID: $e');
      return null;
    }
  }

  // ==========================================================================
  // User 操作
  // ==========================================================================

  /// 保存用户（双写：本地 + 云端）
  ///
  /// 返回：成功返回 true，失败返回 false
  Future<bool> saveUser(UserProfile user) async {
    try {
      // 1. 本地保存（Hive） - 必须成功
      final model = UserHiveModel.fromUserProfile(user);
      await _userBox.put(user.id, model);
      debugPrint('[PersistenceService] ✅ User saved locally: ${user.name}');

      // 2. 云端保存（Firestore） - 可选，失败不影响本地
      if (_cloudSyncEnabled) {
        try {
          await _firestore.saveUserProfile(user);
          debugPrint('[PersistenceService] ☁️ User synced to cloud: ${user.name}');
        } catch (e) {
          debugPrint('[PersistenceService] ⚠️ Cloud sync failed (local saved): $e');
        }
      }

      return true;
    } on HiveError catch (e) {
      debugPrint('[PersistenceService] ❌ Hive error saving user ${user.id}: $e');
      return false;
    } catch (e) {
      debugPrint('[PersistenceService] ❌ Unexpected error saving user ${user.id}: $e');
      return false;
    }
  }

  /// 获取用户
  ///
  /// 返回：用户对象或 null
  UserProfile? getUser(String id) {
    try {
      final model = _userBox.get(id);
      return model?.toUserProfile();
    } on HiveError catch (e) {
      debugPrint('[PersistenceService] Hive error getting user $id: $e');
      return null;
    } catch (e) {
      debugPrint('[PersistenceService] Unexpected error getting user $id: $e');
      return null;
    }
  }

  /// 保存当前用户 ID
  ///
  /// 返回：成功返回 true，失败返回 false
  Future<bool> saveCurrentUserId(String id) async {
    try {
      await _prefs.setString(_currentUserIdKey, id);
      return true;
    } catch (e) {
      debugPrint('[PersistenceService] Error saving current user ID: $e');
      return false;
    }
  }

  /// 获取当前用户 ID
  ///
  /// 返回：用户 ID 或 null
  String? getCurrentUserId() {
    try {
      return _prefs.getString(_currentUserIdKey);
    } catch (e) {
      debugPrint('[PersistenceService] Error getting current user ID: $e');
      return null;
    }
  }

  /// 登出（清除当前用户）
  ///
  /// 返回：成功返回 true，失败返回 false
  Future<bool> logout() async {
    try {
      await _prefs.remove(_currentUserIdKey);
      await _prefs.remove(_currentPetIdKey);
      return true;
    } catch (e) {
      debugPrint('[PersistenceService] Error during logout: $e');
      return false;
    }
  }

  // ==========================================================================
  // Currency 操作
  // ==========================================================================

  /// 保存 Treats
  ///
  /// 返回：成功返回 true，失败返回 false
  Future<bool> saveTreats(int treats) async {
    try {
      await _prefs.setInt(_treatsKey, treats);
      return true;
    } catch (e) {
      debugPrint('[PersistenceService] Error saving treats: $e');
      return false;
    }
  }

  /// 获取 Treats
  ///
  /// 返回：Treats 数量，失败返回默认值 50
  int getTreats() {
    try {
      return _prefs.getInt(_treatsKey) ?? 50;
    } catch (e) {
      debugPrint('[PersistenceService] Error getting treats: $e');
      return 50; // 出错时返回默认值
    }
  }

  // ==========================================================================
  // CheckIn 操作
  // ==========================================================================

  /// 保存签到日期
  ///
  /// 返回：成功返回 true，失败返回 false
  Future<bool> saveLastCheckIn(String date) async {
    try {
      await _prefs.setString(_lastCheckInKey, date);
      return true;
    } catch (e) {
      debugPrint('[PersistenceService] Error saving last check-in date: $e');
      return false;
    }
  }

  /// 获取签到日期
  ///
  /// 返回：签到日期或 null
  String? getLastCheckIn() {
    try {
      return _prefs.getString(_lastCheckInKey);
    } catch (e) {
      debugPrint('[PersistenceService] Error getting last check-in date: $e');
      return null;
    }
  }

  /// 保存连续签到天数
  ///
  /// 返回：成功返回 true，失败返回 false
  Future<bool> saveConsecutiveDays(int days) async {
    try {
      await _prefs.setInt(_consecutiveDaysKey, days);
      return true;
    } catch (e) {
      debugPrint('[PersistenceService] Error saving consecutive days: $e');
      return false;
    }
  }

  /// 获取连续签到天数
  ///
  /// 返回：连续天数，失败返回 0
  int getConsecutiveDays() {
    try {
      return _prefs.getInt(_consecutiveDaysKey) ?? 0;
    } catch (e) {
      debugPrint('[PersistenceService] Error getting consecutive days: $e');
      return 0;
    }
  }

  // ==========================================================================
  // 清理
  // ==========================================================================

  /// 清除所有数据（用于测试或重置）
  ///
  /// 返回：成功返回 true，失败返回 false
  Future<bool> clearAll() async {
    try {
      await _petBox.clear();
      await _userBox.clear();
      await _prefs.clear();
      return true;
    } catch (e) {
      debugPrint('[PersistenceService] Error clearing all data: $e');
      return false;
    }
  }
}
