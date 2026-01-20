/*
  文件：providers/sos_provider.dart
  说明：
  - SOS 紧急寻宠系统状态管理
  - 管理 SOS 帖子、线索上报、搜索范围扩展

  职责：
  - SOS 帖子创建与管理
  - 线索收集与验证
  - 搜索范围动态扩展
  - 宠物找到后的奖励分配
  - 附近 SOS 查询

  使用示例：
  ```dart
  // 创建 SOS 帖子
  final sosId = await context.read<SOSProvider>().createSOSPost(
    pet: myPet,
    treatsReward: 100,
  );

  // 提交线索
  await context.read<SOSProvider>().submitClue(
    sosId: sosId,
    description: '在公园看到类似的狗',
    photoUrl: 'https://...',
  );

  // 监听附近 SOS
  final nearbySOSList = context.watch<SOSProvider>().nearbySOSPosts;
  ```
*/

import 'package:flutter/material.dart';
import '../models/types.dart';
import '../models/sos_types.dart';
import '../services/location_service.dart';
import 'currency_provider.dart';

/// SOS 紧急寻宠系统状态管理
class SOSProvider extends ChangeNotifier {
  final LocationService _locationService;
  final CurrencyProvider _currencyProvider;

  SOSProvider(this._locationService, this._currencyProvider);

  // ==========================================================================
  // 私有状态字段
  // ==========================================================================

  /// 所有活跃的 SOS 帖子
  final List<SOSPost> _activeSOS = [];

  /// 附近的 SOS 帖子（当前位置 10km 范围内）
  final List<SOSPost> _nearbySOSPosts = [];

  /// 所有线索报告
  final Map<String, List<ClueReport>> _cluesBySOSId = {};

  /// 当前用户创建的 SOS（假设单用户，实际应从 UserProvider 获取）
  final String _currentUserId = 'user_001'; // TODO: 从 UserProvider 获取

  /// 简单的 ID 生成器
  String _generateId() {
    return 'id_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 1000}';
  }

  // ==========================================================================
  // 公开访问器
  // ==========================================================================

  /// 获取所有活跃的 SOS 帖子
  List<SOSPost> get activeSOS => List.unmodifiable(_activeSOS);

  /// 获取附近的 SOS 帖子
  List<SOSPost> get nearbySOSPosts => List.unmodifiable(_nearbySOSPosts);

  /// 获取指定 SOS 的所有线索
  List<ClueReport> getCluesForSOS(String sosId) {
    return List.unmodifiable(_cluesBySOSId[sosId] ?? []);
  }

  /// 获取指定 SOS 帖子
  SOSPost? getSOSById(String sosId) {
    try {
      return _activeSOS.firstWhere((sos) => sos.id == sosId);
    } catch (e) {
      return null;
    }
  }

  /// 获取当前用户创建的 SOS
  List<SOSPost> get mySOSPosts {
    return _activeSOS
        .where((sos) => sos.ownerId == _currentUserId)
        .toList();
  }

  // ==========================================================================
  // SOS 创建与管理
  // ==========================================================================

  /// 创建 SOS 寻宠帖子
  ///
  /// 参数：
  /// - pet: 走失的宠物对象
  /// - treatsReward: Treats 悬赏金额（最少 10）
  /// - additionalPhotos: 额外照片（可选）
  ///
  /// 返回：
  /// - SOS 帖子 ID，失败返回 null
  Future<String?> createSOSPost({
    required Pet pet,
    required int treatsReward,
    List<String>? additionalPhotos,
  }) async {
    try {
      // 1. 验证悬赏金额
      if (treatsReward < 10) {
        debugPrint('❌ SOS 创建失败：悬赏金额不足（最少 10 Treats）');
        return null;
      }

      // 2. 验证 Treats 余额（实际发放在找到宠物时）
      if (_currencyProvider.treats < treatsReward) {
        debugPrint('❌ SOS 创建失败：Treats 余额不足');
        return null;
      }

      // 3. 获取当前位置
      final location = await _locationService.getCurrentLocation();

      // 4. 创建 SOS 帖子
      final now = DateTime.now();
      final sosPost = SOSPost(
        id: _generateId(),
        petId: pet.id,
        ownerId: _currentUserId,
        ownerName: '用户名', // TODO: 从 UserProvider 获取
        ownerAvatar: 'assets/images/default_avatar.png', // TODO: 从 UserProvider 获取
        petName: pet.name,
        petBreed: pet.breed,
        petPhotoUrl: pet.gallery.isNotEmpty ? pet.gallery.first : pet.avatarUrl,
        petCharacteristics: _extractCharacteristics(pet),
        lastSeenLocation: location,
        lastSeenTime: now,
        searchRadiusKm: 3.0, // 初始 3km
        treatsReward: treatsReward,
        status: SOSStatus.active,
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 48)), // 48小时后自动过期
        updatedAt: now,
      );

      // 5. 添加到列表
      _activeSOS.add(sosPost);

      // 6. 更新附近 SOS 列表
      await refreshNearbySOSPosts();

      // 7. 触发通知（3km 范围内的用户）
      _sendSOSNotification(sosPost);

      notifyListeners();

      debugPrint('✅ SOS 创建成功: ${sosPost.id}');
      debugPrint('   宠物: ${pet.name} (${pet.breed})');
      debugPrint('   位置: ${location.addressName}');
      debugPrint('   悬赏: $treatsReward Treats');
      debugPrint('   范围: 3km');

      return sosPost.id;
    } catch (e) {
      debugPrint('❌ SOS 创建失败: $e');
      return null;
    }
  }

  /// 扩大搜索范围（从 3km 扩展到 10km）
  ///
  /// 条件：
  /// - SOS 创建超过 2 小时
  /// - 增加悬赏金额
  Future<bool> expandSearchRadius(String sosId, int additionalReward) async {
    try {
      final sos = getSOSById(sosId);
      if (sos == null) {
        debugPrint('❌ 扩大搜索失败：SOS 不存在');
        return false;
      }

      // 1. 验证是否可以扩大范围
      if (!sos.canExpandRadius) {
        debugPrint('❌ 扩大搜索失败：尚未满足扩大条件（需 2 小时后）');
        return false;
      }

      // 2. 验证 Treats 余额
      if (!_currencyProvider.spendTreats(additionalReward)) {
        debugPrint('❌ 扩大搜索失败：Treats 余额不足');
        return false;
      }

      // 3. 更新 SOS
      final updatedSOS = sos.copyWith(
        searchRadiusKm: 10.0,
        treatsReward: sos.treatsReward + additionalReward,
        updatedAt: DateTime.now(),
      );

      // 4. 替换列表中的 SOS
      final index = _activeSOS.indexWhere((s) => s.id == sosId);
      if (index != -1) {
        _activeSOS[index] = updatedSOS;
      }

      // 5. 触发扩展通知（10km 范围内的用户）
      _sendExpandNotification(updatedSOS);

      notifyListeners();

      debugPrint('✅ 搜索范围已扩大到 10km');
      debugPrint('   新增悬赏: $additionalReward Treats');
      debugPrint('   总悬赏: ${updatedSOS.treatsReward} Treats');

      return true;
    } catch (e) {
      debugPrint('❌ 扩大搜索失败: $e');
      return false;
    }
  }

  /// 解决 SOS（宠物找到）
  ///
  /// 参数：
  /// - sosId: SOS 帖子 ID
  /// - finderId: 找到宠物的用户 ID（可选）
  Future<bool> resolveSOSPost(String sosId, {String? finderId}) async {
    try {
      final sos = getSOSById(sosId);
      if (sos == null) {
        debugPrint('❌ 解决 SOS 失败：SOS 不存在');
        return false;
      }

      // 1. 更新状态
      final updatedSOS = sos.copyWith(
        status: SOSStatus.resolved,
        resolvedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final index = _activeSOS.indexWhere((s) => s.id == sosId);
      if (index != -1) {
        _activeSOS[index] = updatedSOS;
      }

      // 2. 发放悬赏（如果有找到者）
      if (finderId != null) {
        // TODO: 转账 Treats 到 finderId
        debugPrint('💰 悬赏发放: ${sos.treatsReward} Treats -> $finderId');
      }

      // 3. 通知所有提交线索的用户
      _sendResolvedNotification(updatedSOS);

      notifyListeners();

      debugPrint('✅ SOS 已解决: ${sos.petName} 找到了！');

      return true;
    } catch (e) {
      debugPrint('❌ 解决 SOS 失败: $e');
      return false;
    }
  }

  /// 取消 SOS
  Future<bool> cancelSOSPost(String sosId) async {
    try {
      final sos = getSOSById(sosId);
      if (sos == null) return false;

      // 验证是否是 SOS 创建者
      if (sos.ownerId != _currentUserId) {
        debugPrint('❌ 取消 SOS 失败：无权限');
        return false;
      }

      final updatedSOS = sos.copyWith(
        status: SOSStatus.cancelled,
        updatedAt: DateTime.now(),
      );

      final index = _activeSOS.indexWhere((s) => s.id == sosId);
      if (index != -1) {
        _activeSOS[index] = updatedSOS;
      }

      notifyListeners();
      debugPrint('✅ SOS 已取消');

      return true;
    } catch (e) {
      debugPrint('❌ 取消 SOS 失败: $e');
      return false;
    }
  }

  // ==========================================================================
  // 线索管理
  // ==========================================================================

  /// 提交线索
  ///
  /// 参数：
  /// - sosId: SOS 帖子 ID
  /// - description: 线索描述
  /// - photoUrl: 照片 URL（可选）
  Future<bool> submitClue({
    required String sosId,
    required String description,
    String? photoUrl,
  }) async {
    try {
      // 1. 验证 SOS 存在
      final sos = getSOSById(sosId);
      if (sos == null) {
        debugPrint('❌ 提交线索失败：SOS 不存在');
        return false;
      }

      // 2. 获取当前位置
      final location = await _locationService.getCurrentLocation();

      // 3. 创建线索报告
      final clue = ClueReport(
        id: _generateId(),
        sosPostId: sosId,
        reporterId: _currentUserId,
        reporterName: '用户名', // TODO: 从 UserProvider 获取
        description: description,
        photoUrl: photoUrl,
        location: location,
        timestamp: DateTime.now(),
      );

      // 4. 添加到线索列表
      if (!_cluesBySOSId.containsKey(sosId)) {
        _cluesBySOSId[sosId] = [];
      }
      _cluesBySOSId[sosId]!.add(clue);

      // 5. 更新 SOS 的线索 ID 列表
      final updatedSOS = sos.copyWith(
        clueIds: [...sos.clueIds, clue.id],
        updatedAt: DateTime.now(),
      );

      final index = _activeSOS.indexWhere((s) => s.id == sosId);
      if (index != -1) {
        _activeSOS[index] = updatedSOS;
      }

      // 6. 通知 SOS 主人
      _sendClueNotification(sos, clue);

      notifyListeners();

      debugPrint('✅ 线索提交成功');
      debugPrint('   描述: $description');
      debugPrint('   位置: ${location.addressName}');

      return true;
    } catch (e) {
      debugPrint('❌ 提交线索失败: $e');
      return false;
    }
  }

  /// 标记线索为有帮助
  Future<bool> markClueAsHelpful(String sosId, String clueId) async {
    try {
      final clues = _cluesBySOSId[sosId];
      if (clues == null) return false;

      final index = clues.indexWhere((c) => c.id == clueId);
      if (index == -1) return false;

      _cluesBySOSId[sosId]![index] = clues[index].copyWith(helpful: true);
      notifyListeners();

      debugPrint('✅ 线索标记为有帮助');
      return true;
    } catch (e) {
      debugPrint('❌ 标记线索失败: $e');
      return false;
    }
  }

  // ==========================================================================
  // 查询与过滤
  // ==========================================================================

  /// 刷新附近的 SOS 帖子
  Future<void> refreshNearbySOSPosts({double radiusKm = 10.0}) async {
    try {
      final currentLocation = await _locationService.getCurrentLocation();

      _nearbySOSPosts.clear();
      _nearbySOSPosts.addAll(
        _activeSOS.where((sos) {
          // 只显示活跃的 SOS
          if (sos.status != SOSStatus.active) return false;
          if (sos.isExpired) return false;

          // 计算距离
          final distance = _locationService.calculateDistance(
            currentLocation,
            sos.lastSeenLocation,
          );

          return distance <= radiusKm;
        }).toList(),
      );

      // 按距离排序（最近的在前）
      _nearbySOSPosts.sort((a, b) {
        final distA = _locationService.calculateDistance(
          currentLocation,
          a.lastSeenLocation,
        );
        final distB = _locationService.calculateDistance(
          currentLocation,
          b.lastSeenLocation,
        );
        return distA.compareTo(distB);
      });

      notifyListeners();
      debugPrint('✅ 刷新附近 SOS: ${_nearbySOSPosts.length} 个');
    } catch (e) {
      debugPrint('❌ 刷新附近 SOS 失败: $e');
    }
  }

  /// 清理过期的 SOS
  void cleanupExpiredSOS() {
    final before = _activeSOS.length;
    _activeSOS.removeWhere((sos) => sos.isExpired);

    if (_activeSOS.length < before) {
      notifyListeners();
      debugPrint('✅ 清理过期 SOS: ${before - _activeSOS.length} 个');
    }
  }

  // ==========================================================================
  // 辅助方法
  // ==========================================================================

  /// 从宠物信息中提取特征
  List<String> _extractCharacteristics(Pet pet) {
    final characteristics = <String>[];

    // 从宠物名字中提取（如果有描述性内容）
    characteristics.add('品种: ${pet.breed}');

    // TODO: 未来可以从 Pet 模型中添加更多特征字段
    // 例如：颜色、体重、项圈、胎记等

    return characteristics;
  }

  /// 发送 SOS 创建通知（3km 范围内）
  void _sendSOSNotification(SOSPost sos) {
    // TODO: 实现通知服务集成
    debugPrint('📢 发送 SOS 通知（3km 范围）: ${sos.petName}');
  }

  /// 发送搜索范围扩展通知（10km 范围内）
  void _sendExpandNotification(SOSPost sos) {
    // TODO: 实现通知服务集成
    debugPrint('📢 发送扩展通知（10km 范围）: ${sos.petName}');
  }

  /// 发送线索通知给 SOS 主人
  void _sendClueNotification(SOSPost sos, ClueReport clue) {
    // TODO: 实现通知服务集成
    debugPrint('📢 发送线索通知给主人: ${clue.description}');
  }

  /// 发送 SOS 解决通知
  void _sendResolvedNotification(SOSPost sos) {
    // TODO: 实现通知服务集成
    debugPrint('📢 发送解决通知: ${sos.petName} 找到了！');
  }
}

/// Treats 交易记录（未来功能）
class TreatsTransaction {
  final String id;
  final String type; // 'earn' 或 'spend'
  final int amount;
  final String description;
  final DateTime timestamp;

  TreatsTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
  });
}
