/*
  文件：theme/app_theme.dart
  说明：
  - 应用主题系统 - 统一管理所有设计规范
  - 包含：颜色、字体、间距、圆角、阴影、渐变等
  - 目的：消除硬编码值，提高可维护性和一致性

  使用示例：
  ```dart
  // 使用颜色
  backgroundColor: AppTheme.backgroundCream,

  // 使用字体大小
  fontSize: AppTheme.fontSizeL,

  // 使用间距
  padding: const EdgeInsets.all(AppTheme.spaceL),

  // 使用圆角
  borderRadius: BorderRadius.circular(AppTheme.radiusM),

  // 使用渐变
  gradient: AppTheme.gradientOrange,

  // 使用阴影
  boxShadow: AppTheme.shadowMedium,
  ```
*/

import 'package:flutter/material.dart';

/// 应用主题系统
///
/// 统一管理颜色、字体、间距、圆角等设计规范
/// 所有 UI 组件应使用此类中的常量，避免硬编码
class AppTheme {
  // ==========================================================================
  // 颜色系统 (Color System)
  // ==========================================================================

  // --------------------------------------------------------------------------
  // 主色调 - Orange (Primary Color)
  // 用于：主按钮、FAB、选中状态、强调元素
  // --------------------------------------------------------------------------

  /// 主橙色
  static const primaryOrange = Color(0xFFEA580C);

  /// 浅橙色
  static const primaryOrangeLight = Color(0xFFFB923C);

  /// 深橙色
  static const primaryOrangeDark = Color(0xFFD97706);

  // --------------------------------------------------------------------------
  // 辅助色 - Teal/Cyan (Accent Colors)
  // 用于：健康/护理功能、次要按钮
  // --------------------------------------------------------------------------

  /// 青绿色
  static const accentTeal = Color(0xFF14B8A6);

  /// 青色
  static const accentCyan = Color(0xFF10B981);

  /// 浅青色
  static const accentCyanLight = Color(0xFF00BCD4);

  // --------------------------------------------------------------------------
  // 辅助色 - Purple/Indigo (Accent Colors)
  // 用于：挑战/AI 功能、特殊元素
  // --------------------------------------------------------------------------

  /// 紫色
  static const accentPurple = Color(0xFF8B5CF6);

  /// 浅紫色
  static const accentPurpleLight = Color(0xFFD946EF);

  /// 靛蓝色
  static const accentIndigo = Color(0xFF6366F1);

  // --------------------------------------------------------------------------
  // 背景色 (Background Colors)
  // --------------------------------------------------------------------------

  /// 奶油色背景（应用主背景）
  static const backgroundCream = Color(0xFFFFFBEB);

  /// 浅奶油色背景
  static const backgroundCreamLight = Color(0xFFFFF4E6);

  /// 白色背景
  static const backgroundWhite = Color(0xFFFFFFFF);

  // --------------------------------------------------------------------------
  // Treats 奖励相关颜色 (Treats Colors)
  // --------------------------------------------------------------------------

  /// Treats 徽章背景色
  static const treatsYellow = Color(0xFFFFF4E6);

  /// Treats 文字/图标颜色
  static const treatsOrange = Color(0xFFD97706);

  // --------------------------------------------------------------------------
  // 灰度色 (Grey Shades)
  // --------------------------------------------------------------------------

  static final grey50 = Colors.grey.shade50;
  static final grey100 = Colors.grey.shade100;
  static final grey200 = Colors.grey.shade200;
  static final grey300 = Colors.grey.shade300;
  static final grey400 = Colors.grey.shade400;
  static final grey500 = Colors.grey.shade500;
  static final grey600 = Colors.grey.shade600;
  static final grey700 = Colors.grey.shade700;
  static final grey800 = Colors.grey.shade800;

  // ==========================================================================
  // 字体系统 (Typography System)
  // ==========================================================================

  // --------------------------------------------------------------------------
  // 字体大小 (Font Sizes)
  // --------------------------------------------------------------------------

  /// 超小字体 - 10px（用于标签、说明文字）
  static const fontSizeXS = 10.0;

  /// 小字体 - 11px（用于辅助文字）
  static const fontSizeS = 11.0;

  /// 小中字体 - 12px（用于次要文字）
  static const fontSizeSM = 12.0;

  /// 中字体 - 13px（用于正文）
  static const fontSizeM = 13.0;

  /// 中大字体 - 14px（用于重要正文）
  static const fontSizeML = 14.0;

  /// 大字体 - 16px（用于副标题）
  static const fontSizeL = 16.0;

  /// 超大字体 - 18px（用于小标题）
  static const fontSizeXL = 18.0;

  /// 2倍大字体 - 20px（用于标题）
  static const fontSize2XL = 20.0;

  /// 3倍大字体 - 24px（用于大标题）
  static const fontSize3XL = 24.0;

  /// 4倍大字体 - 26px（用于特大标题）
  static const fontSize4XL = 26.0;

  // --------------------------------------------------------------------------
  // 字重 (Font Weights)
  // --------------------------------------------------------------------------

  /// 常规字重 - 400
  static const fontWeightRegular = FontWeight.w400;

  /// 中等字重 - 600
  static const fontWeightMedium = FontWeight.w600;

  /// 粗体字重 - 700
  static const fontWeightBold = FontWeight.w700;

  /// 特粗字重 - 800
  static const fontWeightExtraBold = FontWeight.w800;

  /// 最粗字重 - 900
  static const fontWeightBlack = FontWeight.w900;

  // ==========================================================================
  // 间距系统 (Spacing System)
  // ==========================================================================

  /// 超小间距 - 4px
  static const spaceXS = 4.0;

  /// 小间距 - 8px
  static const spaceS = 8.0;

  /// 中间距 - 12px
  static const spaceM = 12.0;

  /// 大间距 - 16px
  static const spaceL = 16.0;

  /// 超大间距 - 20px
  static const spaceXL = 20.0;

  /// 2倍大间距 - 24px
  static const space2XL = 24.0;

  /// 3倍大间距 - 32px
  static const space3XL = 32.0;

  // ==========================================================================
  // 圆角系统 (Border Radius System)
  // ==========================================================================

  /// 小圆角 - 8px
  static const radiusS = 8.0;

  /// 中圆角 - 12px
  static const radiusM = 12.0;

  /// 大圆角 - 16px
  static const radiusL = 16.0;

  /// 超大圆角 - 20px
  static const radiusXL = 20.0;

  /// 2倍大圆角 - 24px
  static const radius2XL = 24.0;

  /// 3倍大圆角 - 30px
  static const radius3XL = 30.0;

  // ==========================================================================
  // 阴影系统 (Shadow System)
  // ==========================================================================

  /// 轻微阴影（用于卡片、按钮）
  ///
  /// 效果：黑色 4% 透明度，模糊 8px，偏移 (0, 2)
  static final shadowLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// 中等阴影（用于悬浮按钮、对话框）
  ///
  /// 效果：黑色 10% 透明度，模糊 12px，偏移 (0, 4)
  static final shadowMedium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// 强阴影（用于重要元素、浮层）
  ///
  /// 效果：黑色 15% 透明度，模糊 16px，偏移 (0, 6)
  static final shadowStrong = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // ==========================================================================
  // 渐变系统 (Gradient System)
  // ==========================================================================

  /// Orange 渐变（用于主按钮、FAB）
  ///
  /// 方向：左上到右下
  /// 颜色：浅橙色 → 主橙色
  static const gradientOrange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOrangeLight, primaryOrange],
  );

  /// Purple 渐变（用于挑战卡片）
  ///
  /// 颜色：紫色 → 浅紫色
  static const gradientPurple = LinearGradient(
    colors: [accentPurple, accentPurpleLight],
  );

  /// Teal 渐变（用于健康功能）
  ///
  /// 颜色：青绿色 → 青色
  static const gradientTeal = LinearGradient(
    colors: [accentTeal, accentCyan],
  );

  // ==========================================================================
  // 文本样式 (Text Styles)
  // ==========================================================================

  /// 大标题样式
  ///
  /// 用于：页面主标题
  /// 大小：24px，字重：900
  static const textStyleTitle = TextStyle(
    fontSize: fontSize3XL,
    fontWeight: fontWeightBlack,
  );

  /// 副标题样式
  ///
  /// 用于：Section 标题
  /// 大小：16px，字重：700
  static const textStyleSubtitle = TextStyle(
    fontSize: fontSizeL,
    fontWeight: fontWeightBold,
  );

  /// 正文样式
  ///
  /// 用于：常规文本
  /// 大小：13px，字重：400
  static const textStyleBody = TextStyle(
    fontSize: fontSizeM,
    fontWeight: fontWeightRegular,
  );

  /// 小文本样式
  ///
  /// 用于：辅助说明文字
  /// 大小：12px，颜色：grey600
  static TextStyle textStyleSmall = TextStyle(
    fontSize: fontSizeSM,
    color: grey600,
  );

  /// 标签样式
  ///
  /// 用于：分类标签、状态标签
  /// 大小：11px，字重：900，颜色：grey500，字间距：0.5
  static TextStyle textStyleLabel = TextStyle(
    fontSize: fontSizeS,
    fontWeight: fontWeightBlack,
    color: grey500,
    letterSpacing: 0.5,
  );

  // ==========================================================================
  // 其他常量 (Other Constants)
  // ==========================================================================

  /// 默认动画时长
  static const animationDuration = Duration(milliseconds: 200);

  /// 页面水平边距
  static const pagePadding = EdgeInsets.symmetric(horizontal: spaceL);

  /// 卡片内边距
  static const cardPadding = EdgeInsets.all(spaceL);
}
