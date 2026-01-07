/*
  文件：core/constants/game_constants.dart
  说明：
  - 集中管理游戏化系统的常量值
  - 包括奖励、消耗、等级等
  - 确保游戏平衡和可维护性
*/

/// 游戏平衡常量
class GameBalance {
  // 防止实例化
  GameBalance._();

  // ==================== Treats 奖励 ====================

  /// 每日签到奖励
  static const int dailyCheckInReward = 20;

  /// 连续签到额外奖励 (每天)
  static const int consecutiveCheckInBonus = 5;

  /// 完成挑战奖励 (默认)
  static const int challengeReward = 50;

  // ==================== Treats 消耗 ====================

  /// AI 汪声翻译费用
  static const int barkTranslatorCost = 10;

  /// AI 成长预测费用
  static const int growthPredictorCost = 20;

  /// AI 时光机费用
  static const int timeMachineCost = 15;

  /// AI 健康建议费用
  static const int healthTipCost = 10;

  // ==================== 时间限制 ====================

  /// 连续签到判定天数 (1天)
  static const int consecutiveDaysThreshold = 1;

  /// 体重记录时间跨度 (2年)
  static const Duration weightHistoryDuration = Duration(days: 365 * 2);

  // ==================== 初始值 ====================

  /// 初始 Treats 余额
  static const int initialTreats = 50;

  /// 初始连续签到天数
  static const int initialConsecutiveDays = 0;

  // ==================== 数据限制 ====================

  /// Treats 历史记录最大条数
  static const int maxTreatsHistory = 100;

  /// 签到历史记录最大天数
  static const int maxCheckInHistory = 30;
}

/// 日期时间常量
class DateTimeConstants {
  // 防止实例化
  DateTimeConstants._();

  /// 疫苗记录最早日期
  static final DateTime vaccineFirstDate = DateTime(2000);

  /// 疫苗记录最晚日期
  static final DateTime vaccineLastDate = DateTime.now().add(const Duration(days: 365));

  /// 体重记录最早日期 (2年前)
  static final DateTime weightFirstDate = DateTime.now().subtract(GameBalance.weightHistoryDuration);

  /// 体重记录最晚日期 (今天)
  static final DateTime weightLastDate = DateTime.now();
}
