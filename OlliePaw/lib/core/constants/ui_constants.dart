/*
  文件：core/constants/ui_constants.dart
  说明：
  - 集中管理UI相关的常量值
  - 包括尺寸、间距、圆角等
  - 确保UI一致性和可维护性

  优化 (v3.0):
  - 统一使用 AppDimensions (AppSpacing, AppRadius, AppSizes)
  - UIDimensions 作为向后兼容的别名
  - 新代码应直接使用 AppSpacing/AppRadius/AppSizes
*/

import '../theme/app_dimensions.dart';

/// UI 尺寸常量
///
/// 注意: 这是向后兼容层，新代码应使用:
/// - AppSpacing (间距)
/// - AppRadius (圆角)
/// - AppSizes (组件尺寸)
class UIDimensions {
  // 防止实例化
  UIDimensions._();

  // ==================== 圆角半径 ====================

  /// 超小圆角 (Extra Small Radius) - 8px
  /// 推荐: 使用 AppRadius.sm
  static const double radiusXS = AppRadius.sm;

  /// 小圆角 (Small Radius) - 12px
  /// 推荐: 使用 AppRadius.md
  static const double radiusS = AppRadius.md;

  /// 中等圆角 (Medium Radius) - 16px
  /// 推荐: 使用 AppRadius.lg
  static const double radiusM = AppRadius.lg;

  /// 大圆角 (Large Radius) - 20px
  /// 推荐: 使用 AppRadius.xl
  static const double radiusL = AppRadius.xl;

  /// 超大圆角 (Extra Large Radius) - 24px
  /// 推荐: 使用 AppRadius.xxl
  static const double radiusXL = AppRadius.xxl;

  /// 超超大圆角 (2XL Radius) - 32px
  /// 推荐: 使用 AppRadius.xxxxl
  static const double radius2XL = AppRadius.xxxxl;

  // ==================== 间距 ====================

  /// 超小间距 - 4px
  /// 推荐: 使用 AppSpacing.xs
  static const double spacingXS = AppSpacing.xs;

  /// 小间距 - 8px
  /// 推荐: 使用 AppSpacing.sm
  static const double spacingS = AppSpacing.sm;

  /// 中等间距 - 16px
  /// 推荐: 使用 AppSpacing.lg
  static const double spacingM = AppSpacing.lg;

  /// 大间距 - 24px
  /// 推荐: 使用 AppSpacing.xxl
  static const double spacingL = AppSpacing.xxl;

  /// 超大间距 - 32px
  /// 推荐: 使用 AppSpacing.xxxl
  static const double spacingXL = AppSpacing.xxxl;

  // ==================== 组件尺寸 ====================

  /// 类别按钮尺寸
  /// 推荐: 使用 AppSizes.categoryButtonSize
  static const double categoryButtonSize = AppSizes.categoryButtonSize;

  /// Fun Labs 卡片高度
  /// 推荐: 使用 AppSizes.funLabCardHeight
  static const double funLabCardHeight = AppSizes.funLabCardHeight;

  /// 标准按钮高度
  /// 推荐: 使用 AppSizes.buttonHeightLG
  static const double buttonHeight = AppSizes.buttonHeightXL;

  /// 图标尺寸 - 小
  /// 推荐: 使用 AppSizes.iconSM
  static const double iconSizeS = AppSizes.iconSM;

  /// 图标尺寸 - 中
  /// 推荐: 使用 AppSizes.iconLG
  static const double iconSizeM = AppSizes.iconLG;

  /// 图标尺寸 - 大
  /// 推荐: 使用 AppSizes.iconXXL
  static const double iconSizeL = AppSizes.iconXXL;

  // ==================== 图片缓存尺寸 ====================

  /// Feed 图片内存缓存宽度
  /// 推荐: 使用 AppSizes.feedImageMemCacheWidth
  static const int feedImageMemCacheWidth = AppSizes.feedImageMemCacheWidth;

  /// Feed 图片内存缓存高度
  /// 推荐: 使用 AppSizes.feedImageMemCacheHeight
  static const int feedImageMemCacheHeight = AppSizes.feedImageMemCacheHeight;

  /// Feed 图片磁盘缓存宽度
  /// 推荐: 使用 AppSizes.feedImageDiskCacheWidth
  static const int feedImageDiskCacheWidth = AppSizes.feedImageDiskCacheWidth;

  /// Feed 图片磁盘缓存高度
  /// 推荐: 使用 AppSizes.feedImageDiskCacheHeight
  static const int feedImageDiskCacheHeight = AppSizes.feedImageDiskCacheHeight;
}

/// UI 动画时长常量
class UIAnimations {
  // 防止实例化
  UIAnimations._();

  /// 快速动画 (150ms)
  static const Duration fast = Duration(milliseconds: 150);

  /// 标准动画 (300ms)
  static const Duration standard = Duration(milliseconds: 300);

  /// 慢速动画 (500ms)
  static const Duration slow = Duration(milliseconds: 500);
}

/// API 超时常量
class APITimeouts {
  // 防止实例化
  APITimeouts._();

  /// Gemini API 超时时间 (30秒)
  static const Duration geminiTimeout = Duration(seconds: 30);

  /// 标准 API 超时时间 (10秒)
  static const Duration standardTimeout = Duration(seconds: 10);

  /// 长时间操作超时 (60秒)
  static const Duration longTimeout = Duration(seconds: 60);
}
