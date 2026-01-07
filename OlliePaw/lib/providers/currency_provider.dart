/*
  文件：providers/currency_provider.dart
  说明：
  - Treats 货币系统状态管理
  - 从原 AppState 拆分出来的货币相关功能
  - 负责 Treats 余额、收入、支出管理

  职责：
  - Treats 余额查询
  - Treats 消费验证
  - Treats 奖励发放
  - 交易历史记录（未来功能）
  - 数据持久化（v2.2）

  使用示例：
  ```dart
  // 查询余额
  final treats = context.watch<CurrencyProvider>().treats;

  // 消费 Treats
  final success = context.read<CurrencyProvider>().spendTreats(5);

  // 获得奖励
  context.read<CurrencyProvider>().earnTreats(20);
  ```
*/

import 'package:flutter/material.dart';
import '../services/persistence_service.dart';
import '../core/constants/game_constants.dart';

/// Treats 货币系统状态管理
///
/// 管理应用内货币系统，包括余额、收入、支出
class CurrencyProvider extends ChangeNotifier {
  final PersistenceService _persistence;

  CurrencyProvider(this._persistence) {
    _treats = _persistence.getTreats();
    // 通知监听器初始状态已加载
    notifyListeners();
  }
  // ==========================================================================
  // 私有状态字段
  // ==========================================================================

  /// Treats 奖励积分
  ///
  /// 用途：
  /// - 应用内货币系统
  /// - 用于 AI 功能消费
  /// - 完成任务获得奖励
  ///
  /// 获取方式：
  /// - 每日签到：+20 Treats
  /// - 完成挑战：+20-50 Treats
  ///
  /// 消耗方式：
  /// - AI 文案生成：-5 Treats
  /// - Bark Translator：-10 Treats
  /// - Growth Predictor：-20 Treats
  int _treats = GameBalance.initialTreats;

  /// 交易历史记录（未来功能）
  final List<TreatsTransaction> _transactions = [];

  // ==========================================================================
  // 公开访问器
  // ==========================================================================

  /// 获取当前 Treats 余额
  int get treats => _treats;

  /// 获取交易历史（未来功能）
  List<TreatsTransaction> get transactions => List.unmodifiable(_transactions);

  // ==========================================================================
  // 状态修改方法
  // ==========================================================================

  /// 消费 Treats
  ///
  /// 参数：
  /// - amount: 消费金额
  ///
  /// 返回值：
  /// - true: 消费成功（余额足够）
  /// - false: 消费失败（余额不足）
  ///
  /// 用途：
  /// - AI 功能调用前验证余额
  /// - 扣除消费金额
  ///
  /// 示例：
  /// ```dart
  /// if (!currencyProvider.spendTreats(5)) {
  ///   showDialog(...); // 显示余额不足提示
  ///   return;
  /// }
  /// // 继续执行功能
  /// ```
  bool spendTreats(int amount) {
    if (_treats >= amount) {
      _treats -= amount;
      _recordTransaction(-amount, 'AI 功能消费');
      try {
        _persistence.saveTreats(_treats);
      } catch (e) {
        // 如果持久化失败，回滚状态
        _treats += amount;
        debugPrint('[CurrencyProvider] Failed to save treats: $e');
        return false;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  /// 获得 Treats 奖励
  ///
  /// 参数：
  /// - amount: 奖励金额
  /// - reason: 奖励原因（可选，用于历史记录）
  ///
  /// 用途：
  /// - 每日签到奖励
  /// - 完成挑战奖励
  /// - 推广奖励等
  void earnTreats(int amount, {String reason = '奖励'}) {
    _treats += amount;
    _recordTransaction(amount, reason);
    try {
      _persistence.saveTreats(_treats);
    } catch (e) {
      debugPrint('[CurrencyProvider] Failed to save treats: $e');
      // 继续执行，但记录错误
    }
    notifyListeners();
  }

  /// 直接设置 Treats 余额（仅用于测试或管理员功能）
  ///
  /// 参数：
  /// - amount: 新余额
  ///
  /// 警告：生产环境应谨慎使用此方法
  void setTreats(int amount) {
    _treats = amount;
    notifyListeners();
  }

  /// 记录交易历史（内部方法）
  ///
  /// 参数：
  /// - amount: 交易金额（正数为收入，负数为支出）
  /// - reason: 交易原因
  void _recordTransaction(int amount, String reason) {
    _transactions.add(TreatsTransaction(
      amount: amount,
      reason: reason,
      timestamp: DateTime.now(),
      balanceAfter: _treats,
    ));

    // 保持历史记录数量在合理范围内
    if (_transactions.length > GameBalance.maxTreatsHistory) {
      _transactions.removeAt(0);
    }
  }

  /// 重置为初始状态
  ///
  /// 用途：登出时恢复初始余额
  void reset() {
    _treats = GameBalance.initialTreats;
    _transactions.clear();
    notifyListeners();
  }
}

/// Treats 交易记录（未来功能）
class TreatsTransaction {
  /// 交易金额（正数为收入，负数为支出）
  final int amount;

  /// 交易原因/描述
  final String reason;

  /// 交易时间
  final DateTime timestamp;

  /// 交易后余额
  final int balanceAfter;

  TreatsTransaction({
    required this.amount,
    required this.reason,
    required this.timestamp,
    required this.balanceAfter,
  });

  /// 是否为收入
  bool get isIncome => amount > 0;

  /// 是否为支出
  bool get isExpense => amount < 0;
}
