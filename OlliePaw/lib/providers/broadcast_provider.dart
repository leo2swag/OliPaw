/*
  文件：providers/broadcast_provider.dart
  说明：
  - 社区广播系统状态管理
  - 管理各类广播（危险预警、社交活动、闲置市场）

  职责：
  - 广播创建与发布
  - 附近广播查询
  - 广播互动（点赞、回复）
  - 费用扣除（社交/市场广播需 50 Treats）
  - 自动过期清理

  使用示例：
  ```dart
  // 创建社交广播
  final broadcastId = await context.read<BroadcastProvider>().createBroadcast(
    type: BroadcastType.social,
    title: '周末狗狗公园聚会',
    content: '明天下午3点在中央公园',
    rangeKm: 5.0,
  );

  // 监听附近广播
  final nearbyBroadcasts = context.watch<BroadcastProvider>().nearbyBroadcasts;
  ```
*/

import 'package:flutter/material.dart';
import '../models/sos_types.dart';
import '../services/location_service.dart';
import 'currency_provider.dart';

/// 社区广播系统状态管理
class BroadcastProvider extends ChangeNotifier {
  final LocationService _locationService;
  final CurrencyProvider _currencyProvider;

  BroadcastProvider(this._locationService, this._currencyProvider);

  // ==========================================================================
  // 私有状态字段
  // ==========================================================================

  /// 所有活跃的广播
  final List<CommunityBroadcast> _broadcasts = [];

  /// 附近的广播（当前位置指定范围内）
  final List<CommunityBroadcast> _nearbyBroadcasts = [];

  /// 当前用户 ID
  final String _currentUserId = 'user_001'; // TODO: 从 UserProvider 获取

  /// 简单的 ID 生成器
  String _generateId() {
    return 'broadcast_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 1000}';
  }

  // ==========================================================================
  // 公开访问器
  // ==========================================================================

  /// 获取所有活跃的广播
  List<CommunityBroadcast> get broadcasts => List.unmodifiable(_broadcasts);

  /// 获取附近的广播
  List<CommunityBroadcast> get nearbyBroadcasts => List.unmodifiable(_nearbyBroadcasts);

  /// 获取指定类型的广播
  List<CommunityBroadcast> getBroadcastsByType(BroadcastType type) {
    return _broadcasts.where((b) => b.type == type && !b.isExpired).toList();
  }

  /// 获取指定广播
  CommunityBroadcast? getBroadcastById(String broadcastId) {
    try {
      return _broadcasts.firstWhere((b) => b.id == broadcastId);
    } catch (e) {
      return null;
    }
  }

  /// 获取当前用户创建的广播
  List<CommunityBroadcast> get myBroadcasts {
    return _broadcasts
        .where((b) => b.authorId == _currentUserId && !b.isExpired)
        .toList();
  }

  // ==========================================================================
  // 广播创建与管理
  // ==========================================================================

  /// 创建社区广播
  ///
  /// 参数：
  /// - type: 广播类型（sos/danger/social/marketplace）
  /// - title: 标题
  /// - content: 内容描述
  /// - rangeKm: 广播范围（公里）
  /// - imageUrl: 图片 URL（可选）
  /// - expiryHours: 过期时间（小时，默认 6）
  ///
  /// 返回：
  /// - 广播 ID，失败返回 null
  Future<String?> createBroadcast({
    required BroadcastType type,
    required String title,
    required String content,
    required double rangeKm,
    String? imageUrl,
    int expiryHours = 6,
  }) async {
    try {
      // 1. 验证标题和内容
      if (title.trim().isEmpty || content.trim().isEmpty) {
        debugPrint('❌ 创建广播失败：标题或内容为空');
        return null;
      }

      // 2. 计算费用
      final cost = _calculateBroadcastCost(type);

      // 3. 扣除 Treats（如果需要）
      if (cost > 0) {
        if (!_currencyProvider.spendTreats(cost)) {
          debugPrint('❌ 创建广播失败：Treats 余额不足（需要 $cost）');
          return null;
        }
      }

      // 4. 获取当前位置
      final location = await _locationService.getCurrentLocation();

      // 5. 创建广播
      final now = DateTime.now();
      final broadcast = CommunityBroadcast(
        id: _generateId(),
        type: type,
        authorId: _currentUserId,
        authorName: '用户名', // TODO: 从 UserProvider 获取
        authorAvatar: 'assets/images/default_avatar.png', // TODO: 从 UserProvider 获取
        title: title.trim(),
        content: content.trim(),
        imageUrl: imageUrl,
        location: location,
        rangeKm: rangeKm,
        createdAt: now,
        expiresAt: now.add(Duration(hours: expiryHours)),
        treatsCost: cost,
      );

      // 6. 添加到列表
      _broadcasts.add(broadcast);

      // 7. 更新附近广播列表
      await refreshNearbyBroadcasts();

      // 8. 发送通知给范围内的用户
      _sendBroadcastNotification(broadcast);

      notifyListeners();

      debugPrint('✅ 广播创建成功: ${broadcast.id}');
      debugPrint('   类型: ${broadcast.typeName} ${broadcast.typeIcon}');
      debugPrint('   标题: ${broadcast.title}');
      debugPrint('   范围: ${broadcast.rangeKm}km');
      debugPrint('   费用: ${broadcast.treatsCost} Treats');
      debugPrint('   过期时间: ${broadcast.expiresAt}');

      return broadcast.id;
    } catch (e) {
      debugPrint('❌ 创建广播失败: $e');
      // 如果失败，退还 Treats
      final cost = _calculateBroadcastCost(type);
      if (cost > 0) {
        _currencyProvider.earnTreats(cost);
      }
      return null;
    }
  }

  /// 点赞广播
  Future<bool> likeBroadcast(String broadcastId) async {
    try {
      final broadcast = getBroadcastById(broadcastId);
      if (broadcast == null) {
        debugPrint('❌ 点赞失败：广播不存在');
        return false;
      }

      // 更新点赞数
      final updatedBroadcast = broadcast.copyWith(
        likeCount: broadcast.likeCount + 1,
      );

      final index = _broadcasts.indexWhere((b) => b.id == broadcastId);
      if (index != -1) {
        _broadcasts[index] = updatedBroadcast;
      }

      notifyListeners();
      debugPrint('✅ 点赞成功');
      return true;
    } catch (e) {
      debugPrint('❌ 点赞失败: $e');
      return false;
    }
  }

  /// 回复广播
  Future<bool> respondToBroadcast(String broadcastId) async {
    try {
      final broadcast = getBroadcastById(broadcastId);
      if (broadcast == null) {
        debugPrint('❌ 回复失败：广播不存在');
        return false;
      }

      // 更新回复数
      final updatedBroadcast = broadcast.copyWith(
        responseCount: broadcast.responseCount + 1,
      );

      final index = _broadcasts.indexWhere((b) => b.id == broadcastId);
      if (index != -1) {
        _broadcasts[index] = updatedBroadcast;
      }

      notifyListeners();
      debugPrint('✅ 回复成功');
      return true;
    } catch (e) {
      debugPrint('❌ 回复失败: $e');
      return false;
    }
  }

  /// 删除广播（仅作者可删除）
  Future<bool> deleteBroadcast(String broadcastId) async {
    try {
      final broadcast = getBroadcastById(broadcastId);
      if (broadcast == null) {
        debugPrint('❌ 删除失败：广播不存在');
        return false;
      }

      // 验证是否是作者
      if (broadcast.authorId != _currentUserId) {
        debugPrint('❌ 删除失败：无权限（仅作者可删除）');
        return false;
      }

      // 从列表中移除
      _broadcasts.removeWhere((b) => b.id == broadcastId);
      _nearbyBroadcasts.removeWhere((b) => b.id == broadcastId);

      notifyListeners();
      debugPrint('✅ 广播已删除');
      return true;
    } catch (e) {
      debugPrint('❌ 删除失败: $e');
      return false;
    }
  }

  // ==========================================================================
  // 查询与过滤
  // ==========================================================================

  /// 刷新附近的广播
  ///
  /// 参数：
  /// - radiusKm: 查询半径（默认 5km）
  /// - filterType: 过滤类型（可选）
  Future<void> refreshNearbyBroadcasts({
    double radiusKm = 5.0,
    BroadcastType? filterType,
  }) async {
    try {
      final currentLocation = await _locationService.getCurrentLocation();

      _nearbyBroadcasts.clear();
      _nearbyBroadcasts.addAll(
        _broadcasts.where((broadcast) {
          // 过滤已过期的
          if (broadcast.isExpired) return false;

          // 类型过滤
          if (filterType != null && broadcast.type != filterType) {
            return false;
          }

          // 计算距离
          final distance = _locationService.calculateDistance(
            currentLocation,
            broadcast.location,
          );

          // 检查是否在查询范围内
          // 注意：使用广播的 rangeKm 和查询半径的较小值
          final effectiveRange = broadcast.rangeKm < radiusKm
              ? broadcast.rangeKm
              : radiusKm;

          return distance <= effectiveRange;
        }).toList(),
      );

      // 按优先级和时间排序
      _nearbyBroadcasts.sort((a, b) {
        // SOS 和 danger 类型优先
        if (a.type == BroadcastType.sos && b.type != BroadcastType.sos) {
          return -1;
        }
        if (b.type == BroadcastType.sos && a.type != BroadcastType.sos) {
          return 1;
        }
        if (a.type == BroadcastType.danger && b.type != BroadcastType.danger) {
          return -1;
        }
        if (b.type == BroadcastType.danger && a.type != BroadcastType.danger) {
          return 1;
        }

        // 然后按时间排序（最新的在前）
        return b.createdAt.compareTo(a.createdAt);
      });

      notifyListeners();
      debugPrint('✅ 刷新附近广播: ${_nearbyBroadcasts.length} 个');
    } catch (e) {
      debugPrint('❌ 刷新附近广播失败: $e');
    }
  }

  /// 获取最新的 N 条广播（用于 Ticker）
  List<CommunityBroadcast> getRecentBroadcasts({
    int limit = 5,
    double radiusKm = 5.0,
  }) {
    // 先筛选附近的
    final nearby = _nearbyBroadcasts
        .where((b) => !b.isExpired)
        .take(limit)
        .toList();

    return nearby;
  }

  /// 清理过期的广播
  void cleanupExpiredBroadcasts() {
    final before = _broadcasts.length;
    _broadcasts.removeWhere((b) => b.isExpired);
    _nearbyBroadcasts.removeWhere((b) => b.isExpired);

    if (_broadcasts.length < before) {
      notifyListeners();
      debugPrint('✅ 清理过期广播: ${before - _broadcasts.length} 个');
    }
  }

  // ==========================================================================
  // 辅助方法
  // ==========================================================================

  /// 计算广播费用
  int _calculateBroadcastCost(BroadcastType type) {
    switch (type) {
      case BroadcastType.sos:
      case BroadcastType.danger:
        return 0; // 紧急类广播免费
      case BroadcastType.social:
      case BroadcastType.marketplace:
        return 50; // 社交和市场广播需要 50 Treats
    }
  }

  /// 发送广播通知
  void _sendBroadcastNotification(CommunityBroadcast broadcast) {
    // TODO: 实现通知服务集成
    debugPrint('📢 发送广播通知（${broadcast.rangeKm}km 范围）: ${broadcast.title}');
  }

  /// 获取广播类型的默认过期时间（小时）
  int getDefaultExpiryHours(BroadcastType type) {
    switch (type) {
      case BroadcastType.sos:
        return 48; // SOS 48小时
      case BroadcastType.danger:
        return 12; // 危险预警 12小时
      case BroadcastType.social:
        return 6; // 社交活动 6小时
      case BroadcastType.marketplace:
        return 24; // 市场信息 24小时
    }
  }
}
