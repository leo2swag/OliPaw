/*
  文件：core/constants/pricing.dart
  说明：
  - Treats 定价配置
  - 统一管理所有功能的 Treats 消费金额
  - 便于调整价格和平衡经济系统

  使用示例：
  ```dart
  // 消费 Treats
  if (!currencyProvider.spendTreats(Pricing.aiCaptionGeneration)) {
    showInsufficientTreatsDialog();
  }

  // 发放奖励
  currencyProvider.earnTreats(Pricing.dailyCheckInReward);
  ```
*/

/// Treats 定价配置类
///
/// 集中管理所有功能的 Treats 价格
class Pricing {
  // 防止实例化
  Pricing._();

  // ==========================================================================
  // AI 功能定价
  // ==========================================================================

  /// AI 文案生成
  ///
  /// 功能：在创建帖子时生成宠物口吻的文案
  /// 位置：create_post_screen.dart
  static const int aiCaptionGeneration = 5;

  /// Bark Translator（汪/喵声翻译）
  ///
  /// 功能：将宠物叫声"翻译"为搞笑的人类语言
  /// 位置：explore_screen.dart
  static const int barkTranslator = 10;

  /// Growth Predictor（成长预测）
  ///
  /// 功能：AI 预测宠物的未来样子
  /// 位置：explore_screen.dart
  static const int growthPredictor = 20;

  // ==========================================================================
  // 奖励定价
  // ==========================================================================

  /// 完成挑战基础奖励
  ///
  /// 功能：完成每日挑战的基础奖励
  /// 位置：challenge_card.dart (未来功能)
  static const int challengeBaseReward = 20;

  /// 完成挑战额外奖励（困难挑战）
  ///
  /// 功能：完成高难度挑战的额外奖励
  /// 位置：challenge_card.dart (未来功能)
  static const int challengeBonusReward = 30;

  // ==========================================================================
  // 初始配置
  // ==========================================================================

  /// 新用户初始 Treats
  ///
  /// 功能：新用户注册时赠送的初始金额
  static const int initialTreats = 50;

  // ==========================================================================
  // 辅助方法
  // ==========================================================================

  /// 获取功能名称
  ///
  /// 参数：
  /// - price: Treats 价格
  ///
  /// 返回值：功能名称（用于显示）
  ///
  /// 注意：由于某些功能价格相同，返回值可能不唯一
  static String getFeatureName(int price) {
    if (price == aiCaptionGeneration) return 'AI Caption Generation';
    if (price == barkTranslator) return 'Bark Translator';
    if (price == growthPredictor) return 'Growth Predictor';
    if (price == 20) return 'Daily Check-in or Challenge'; // GameBalance.dailyCheckInReward
    return 'Unknown Feature';
  }

  /// 检查价格是否有效
  ///
  /// 参数：
  /// - price: 价格
  ///
  /// 返回值：true 表示价格大于 0
  static bool isValidPrice(int price) {
    return price > 0;
  }
}
