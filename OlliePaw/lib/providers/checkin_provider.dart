/*
  文件：providers/checkin_provider.dart
  说明：
  - 每日签到系统状态管理
  - 从原 AppState 拆分出来的签到相关功能
  - 负责签到状态、连续签到天数、签到奖励

  职责：
  - 签到状态查询
  - 执行签到操作
  - 签到奖励发放
  - 连续签到统计（未来功能）
  - 数据持久化（v2.2）

  使用示例：
  ```dart
  // 查询今日是否已签到
  final isCheckedIn = context.watch<CheckInProvider>().isCheckedIn;

  // 执行签到
  context.read<CheckInProvider>().checkIn();

  // 获取连续签到天数
  final streak = context.watch<CheckInProvider>().consecutiveDays;
  ```
*/

import 'package:flutter/material.dart';
import '../services/persistence_service.dart';
import '../core/constants/game_constants.dart';

/// 每日签到系统状态管理
///
/// 管理签到状态和签到奖励
class CheckInProvider extends ChangeNotifier {
  final PersistenceService _persistence;

  CheckInProvider(this._persistence) {
    _lastCheckIn = _persistence.getLastCheckIn();
    _consecutiveDays = _persistence.getConsecutiveDays();
    // 通知监听器初始状态已加载
    notifyListeners();
  }
  // ==========================================================================
  // 私有状态字段
  // ==========================================================================

  /// 最后一次签到日期
  ///
  /// 格式：YYYY-MM-DD（例如："2024-12-28"）
  String? _lastCheckIn;

  /// 连续签到天数（未来功能）
  int _consecutiveDays = 0;

  /// 签到历史记录（未来功能）
  final List<String> _checkInHistory = [];

  // ==========================================================================
  // 常量配置
  // ==========================================================================
  // Note: 奖励金额已移至 GameBalance.dailyCheckInReward
  // ==========================================================================
  // 公开访问器
  // ==========================================================================

  /// 检查今日是否已签到
  ///
  /// 实现逻辑：
  /// 1. 获取今日日期（YYYY-MM-DD 格式）
  /// 2. 与 _lastCheckIn 对比
  /// 3. 相同则已签到，不同则未签到
  bool get isCheckedIn {
    final today = _getTodayString();
    return _lastCheckIn == today;
  }

  /// 获取连续签到天数
  int get consecutiveDays => _consecutiveDays;

  /// 获取签到历史
  List<String> get checkInHistory => List.unmodifiable(_checkInHistory);

  /// 获取最后签到日期
  String? get lastCheckInDate => _lastCheckIn;

  // ==========================================================================
  // 状态修改方法
  // ==========================================================================

  /// 执行签到
  ///
  /// 返回值：
  /// - true: 签到成功，发放奖励
  /// - false: 今日已签到，无法重复签到
  ///
  /// 效果：
  /// 1. 记录签到日期
  /// 2. 更新连续签到天数
  /// 3. 通知 UI 更新
  ///
  /// 注意：不在此方法中直接发放 Treats 奖励
  /// 调用者应监听返回值，然后调用 CurrencyProvider.earnTreats()
  bool checkIn() {
    // 检查今日是否已签到
    if (isCheckedIn) {
      return false;
    }

    final today = _getTodayString();

    // 更新连续签到天数
    if (_lastCheckIn != null) {
      final lastDate = DateTime.parse(_lastCheckIn!);
      final todayDate = DateTime.parse(today);
      final difference = todayDate.difference(lastDate).inDays;

      if (difference == 1) {
        // 连续签到
        _consecutiveDays++;
      } else {
        // 中断签到，重置连续天数
        _consecutiveDays = 1;
      }
    } else {
      // 首次签到
      _consecutiveDays = 1;
    }

    // 记录签到日期
    _lastCheckIn = today;
    _checkInHistory.add(today);

    // 保持历史记录在合理范围内
    if (_checkInHistory.length > GameBalance.maxCheckInHistory) {
      _checkInHistory.removeAt(0);
    }

    // 保存到本地存储
    _persistence.saveLastCheckIn(today);
    _persistence.saveConsecutiveDays(_consecutiveDays);

    notifyListeners();
    return true;
  }

  /// 重置签到状态
  ///
  /// 用途：登出时清空签到记录
  void reset() {
    _lastCheckIn = null;
    _consecutiveDays = 0;
    _checkInHistory.clear();
    notifyListeners();
  }

  /// 获取今天的日期字符串（YYYY-MM-DD 格式）
  String _getTodayString() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  /// 检查某个日期是否已签到（未来功能）
  ///
  /// 参数：
  /// - date: 日期字符串（YYYY-MM-DD）
  ///
  /// 返回值：true 表示该日期已签到
  bool hasCheckedInOn(String date) {
    return _checkInHistory.contains(date);
  }

  /// 获取本月签到天数（未来功能）
  int getMonthlyCheckInCount() {
    final now = DateTime.now();
    final thisMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    return _checkInHistory.where((date) => date.startsWith(thisMonth)).length;
  }
}
