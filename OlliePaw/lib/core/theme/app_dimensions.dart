/*
  文件：core/theme/app_dimensions.dart
  说明：
  - 应用尺寸常量定义
  - 统一管理间距、圆角、尺寸等数值
  - 消除硬编码魔法数字

  优化（v2.5）：
  - 集中管理所有尺寸定义
  - 语义化命名，提高代码可读性
  - 便于响应式适配

  使用示例：
  ```dart
  // 替代：const SizedBox(height: 16)
  SizedBox(height: AppSpacing.md)

  // 替代：BorderRadius.circular(12)
  BorderRadius.circular(AppRadius.md)

  // 替代：const EdgeInsets.all(16)
  const EdgeInsets.all(AppSpacing.md)
  ```
*/

import 'package:flutter/material.dart';

/// 应用间距常量
///
/// 统一管理所有间距值
class AppSpacing {
  // 防止实例化
  AppSpacing._();

  // ==========================================================================
  // 基础间距
  // ==========================================================================

  /// 超超小间距 - 2px
  ///
  /// 用途：紧密元素间距
  static const double xxs = 2.0;

  /// 超小间距 - 4px
  ///
  /// 用途：图标与文本间距、紧密布局
  static const double xs = 4.0;

  /// 小间距 - 8px
  ///
  /// 用途：小组件内部间距
  static const double sm = 8.0;

  /// 中间距 - 12px
  ///
  /// 用途：组件间距
  static const double md = 12.0;

  /// 标准间距 - 16px（最常用）
  ///
  /// 用途：卡片内边距、组件间距
  static const double lg = 16.0;

  /// 大间距 - 20px
  ///
  /// 用途：区块间距
  static const double xl = 20.0;

  /// 超大间距 - 24px
  ///
  /// 用途：大区块间距、分组间距
  static const double xxl = 24.0;

  /// 巨大间距 - 32px
  ///
  /// 用途：页面级间距
  static const double xxxl = 32.0;

  /// 超巨大间距 - 48px
  ///
  /// 用途：大型分隔区域
  static const double xxxxl = 48.0;

  // ==========================================================================
  // 特定用途间距
  // ==========================================================================

  /// 页面水平边距
  ///
  /// 用途：页面左右 padding
  static const double pagePadding = lg;

  /// 页面垂直边距
  ///
  /// 用途：页面上下 padding
  static const double pageVerticalPadding = lg;

  /// 卡片内边距
  ///
  /// 用途：卡片内部 padding
  static const double cardPadding = lg;

  /// 按钮内边距 - 水平
  ///
  /// 用途：按钮左右 padding
  static const double buttonPaddingH = xl;

  /// 按钮内边距 - 垂直
  ///
  /// 用途：按钮上下 padding
  static const double buttonPaddingV = md;

  /// 输入框内边距 - 水平
  static const double inputPaddingH = lg;

  /// 输入框内边距 - 垂直
  static const double inputPaddingV = md;

  /// 列表项间距
  ///
  /// 用途：ListView item 之间的间距
  static const double listItemSpacing = md;

  /// 区块间距
  ///
  /// 用途：大区块之间的间距
  static const double sectionSpacing = xxl;

  // ==========================================================================
  // EdgeInsets 快捷方式
  // ==========================================================================

  /// 全方向 XXS 间距
  static const EdgeInsets allXXS = EdgeInsets.all(xxs);

  /// 全方向 XS 间距
  static const EdgeInsets allXS = EdgeInsets.all(xs);

  /// 全方向 SM 间距
  static const EdgeInsets allSM = EdgeInsets.all(sm);

  /// 全方向 MD 间距
  static const EdgeInsets allMD = EdgeInsets.all(md);

  /// 全方向 LG 间距（最常用）
  static const EdgeInsets allLG = EdgeInsets.all(lg);

  /// 全方向 XL 间距
  static const EdgeInsets allXL = EdgeInsets.all(xl);

  /// 全方向 XXL 间距
  static const EdgeInsets allXXL = EdgeInsets.all(xxl);

  /// 水平 LG 间距
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);

  /// 垂直 LG 间距
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);

  /// 水平 MD 间距
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);

  /// 垂直 MD 间距
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);

  /// 页面标准边距
  static const EdgeInsets page = EdgeInsets.all(pagePadding);

  /// 卡片标准边距
  static const EdgeInsets card = EdgeInsets.all(cardPadding);

  /// 按钮标准边距
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: buttonPaddingH,
    vertical: buttonPaddingV,
  );

  /// 输入框标准边距
  static const EdgeInsets input = EdgeInsets.symmetric(
    horizontal: inputPaddingH,
    vertical: inputPaddingV,
  );
}

/// 应用圆角常量
///
/// 统一管理所有圆角值
class AppRadius {
  // 防止实例化
  AppRadius._();

  // ==========================================================================
  // 基础圆角 (v3.0: 更柔和圆润)
  // ==========================================================================

  /// 无圆角
  static const double none = 0.0;

  /// 超小圆角 - 8px (加倍柔和)
  ///
  /// 用途：小徽章、标签
  static const double xs = 8.0;

  /// 小圆角 - 16px (更圆润)
  ///
  /// 用途：按钮、输入框
  static const double sm = 16.0;

  /// 中圆角 - 24px (v3.0 新标准)
  ///
  /// 用途：卡片、容器 - 温暖友好
  static const double md = 24.0;

  /// 大圆角 - 32px (更有机)
  ///
  /// 用途：大卡片、对话框
  static const double lg = 32.0;

  /// 超大圆角 - 40px (blob感)
  ///
  /// 用途：特殊容器、有机形状
  static const double xl = 40.0;

  /// 巨大圆角 - 48px (极柔和)
  ///
  /// 用途：底部弹窗、大型卡片
  static const double xxl = 48.0;

  /// 超巨大圆角 - 56px
  ///
  /// 用途：特殊有机设计
  static const double xxxl = 56.0;

  /// 超超巨大圆角 - 64px
  ///
  /// 用途：极大型容器、装饰性元素
  static const double xxxxl = 64.0;

  /// 完全圆角 - 999px (pill shape)
  ///
  /// 用途：药丸形按钮、圆形容器
  static const double full = 999.0;

  // ==========================================================================
  // 特定用途圆角 (v3.0: pill-shaped & organic)
  // ==========================================================================

  /// 按钮圆角 - 药丸形状
  static const double button = full; // pill-shaped for warmth

  /// 输入框圆角 - 柔和
  static const double input = md; // 24px

  /// 卡片圆角 - 温暖
  static const double card = md; // 24px standard

  /// 对话框圆角 - 大
  static const double dialog = lg; // 32px

  /// 底部弹窗圆角 - 极柔和
  static const double bottomSheet = xxl; // 48px

  /// 徽章圆角 - 有机
  static const double badge = xl; // 40px

  /// 头像圆角 - 完全圆形
  static const double avatar = full;

  // ==========================================================================
  // BorderRadius 快捷方式
  // ==========================================================================

  /// 全方向 XS 圆角
  static BorderRadius get allXS => BorderRadius.circular(xs);

  /// 全方向 SM 圆角
  static BorderRadius get allSM => BorderRadius.circular(sm);

  /// 全方向 MD 圆角（最常用）
  static BorderRadius get allMD => BorderRadius.circular(md);

  /// 全方向 LG 圆角
  static BorderRadius get allLG => BorderRadius.circular(lg);

  /// 全方向 XL 圆角
  static BorderRadius get allXL => BorderRadius.circular(xl);

  /// 全方向 XXL 圆角
  static BorderRadius get allXXL => BorderRadius.circular(xxl);

  /// 完全圆角
  static BorderRadius get allFull => BorderRadius.circular(full);

  /// 仅顶部圆角 - MD
  static BorderRadius get topMD => const BorderRadius.only(
        topLeft: Radius.circular(md),
        topRight: Radius.circular(md),
      );

  /// 仅顶部圆角 - LG
  static BorderRadius get topLG => const BorderRadius.only(
        topLeft: Radius.circular(lg),
        topRight: Radius.circular(lg),
      );

  /// 仅顶部圆角 - XXL
  static BorderRadius get topXXL => const BorderRadius.only(
        topLeft: Radius.circular(xxl),
        topRight: Radius.circular(xxl),
      );

  /// 仅顶部圆角 - XXXL (用于底部弹窗)
  static BorderRadius get topXXXL => const BorderRadius.only(
        topLeft: Radius.circular(xxxl),
        topRight: Radius.circular(xxxl),
      );

  /// 仅底部圆角 - MD
  static BorderRadius get bottomMD => const BorderRadius.only(
        bottomLeft: Radius.circular(md),
        bottomRight: Radius.circular(md),
      );

  /// 仅底部圆角 - LG
  static BorderRadius get bottomLG => const BorderRadius.only(
        bottomLeft: Radius.circular(lg),
        bottomRight: Radius.circular(lg),
      );
}

/// 应用尺寸常量
///
/// 统一管理组件尺寸
class AppSizes {
  // 防止实例化
  AppSizes._();

  // ==========================================================================
  // 图标尺寸
  // ==========================================================================

  /// 超小图标 - 12px
  static const double iconXS = 12.0;

  /// 小图标 - 16px
  static const double iconSM = 16.0;

  /// 中图标 - 20px（最常用）
  static const double iconMD = 20.0;

  /// 大图标 - 24px
  static const double iconLG = 24.0;

  /// 超大图标 - 28px
  static const double iconXL = 28.0;

  /// 巨大图标 - 32px
  static const double iconXXL = 32.0;

  /// 超巨大图标 - 48px
  static const double iconXXXL = 48.0;

  // ==========================================================================
  // 头像尺寸
  // ==========================================================================

  /// 小头像 - 24px
  static const double avatarSM = 24.0;

  /// 中头像 - 32px
  static const double avatarMD = 32.0;

  /// 大头像 - 40px
  static const double avatarLG = 40.0;

  /// 超大头像 - 48px
  static const double avatarXL = 48.0;

  /// 巨大头像 - 64px
  static const double avatarXXL = 64.0;

  /// 超巨大头像 - 96px
  static const double avatarXXXL = 96.0;

  // ==========================================================================
  // 按钮尺寸
  // ==========================================================================

  /// 小按钮高度
  static const double buttonHeightSM = 32.0;

  /// 中按钮高度
  static const double buttonHeightMD = 40.0;

  /// 大按钮高度
  static const double buttonHeightLG = 48.0;

  /// 超大按钮高度
  static const double buttonHeightXL = 56.0;

  // ==========================================================================
  // 输入框尺寸
  // ==========================================================================

  /// 输入框高度
  static const double inputHeight = 48.0;

  // ==========================================================================
  // 其他尺寸
  // ==========================================================================

  /// AppBar 高度
  static const double appBarHeight = 56.0;

  /// BottomNavigationBar 高度
  static const double bottomNavHeight = 60.0;

  /// 卡片高度 - 小
  static const double cardHeightSM = 100.0;

  /// 卡片高度 - 中
  static const double cardHeightMD = 150.0;

  /// 卡片高度 - 大
  static const double cardHeightLG = 200.0;

  // ==========================================================================
  // 特殊组件尺寸
  // ==========================================================================

  /// 类别按钮尺寸 (Home screen category buttons)
  static const double categoryButtonSize = 90.0;

  /// Fun Labs 卡片高度 (Explore screen AI features)
  static const double funLabCardHeight = 120.0;

  // ==========================================================================
  // 图片缓存尺寸
  // ==========================================================================

  /// Feed 图片内存缓存宽度
  static const int feedImageMemCacheWidth = 800;

  /// Feed 图片内存缓存高度
  static const int feedImageMemCacheHeight = 800;

  /// Feed 图片磁盘缓存宽度
  static const int feedImageDiskCacheWidth = 1000;

  /// Feed 图片磁盘缓存高度
  static const int feedImageDiskCacheHeight = 1000;

  // ==========================================================================
  // 线条粗细
  // ==========================================================================

  /// 分隔线粗细
  static const double dividerThickness = 1.0;

  /// 边框粗细 - 细
  static const double borderWidthThin = 1.0;

  /// 边框粗细 - 标准
  static const double borderWidthNormal = 2.0;

  /// 边框粗细 - 粗
  static const double borderWidthThick = 3.0;
}
