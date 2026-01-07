/*
  文件：core/theme/app_colors.dart
  说明：
  - 应用颜色常量定义
  - 统一管理所有颜色，便于主题切换和维护
  - 消除硬编码颜色值（Color(0xFFxxxxxx)）

  优化（v2.5）：
  - 集中管理所有颜色定义
  - 语义化命名，提高代码可读性
  - 便于实现暗色模式

  使用示例：
  ```dart
  // 替代：const Color(0xFFFB923C)
  Container(color: AppColors.primary)

  // 替代：Colors.grey[300]
  Divider(color: AppColors.grey300)

  // 替代：const Color(0xFFDCFCE7)
  Container(color: AppColors.successLight)
  ```
*/

import 'package:flutter/material.dart';

/// 应用颜色定义
///
/// 集中管理所有颜色常量
class AppColors {
  // 防止实例化
  AppColors._();

  // ==========================================================================
  // 主题色
  // ==========================================================================

  /// 主色调 - Orange
  ///
  /// 用途：主要按钮、强调内容、Treats 相关
  static const Color primary = Color(0xFFFB923C);

  /// 主色调 - 浅色
  ///
  /// 用途：背景色、卡片背景
  static const Color primaryLight = Color(0xFFFED7AA);

  /// 主色调 - 超浅色
  ///
  /// 用途：背景、选中状态背景
  static const Color primaryExtraLight = Color(0xFFFFF4E6);

  /// 主色调 - 深色
  ///
  /// 用途：深色文本、强调边框
  static const Color primaryDark = Color(0xFFEA580C);

  /// 主色调 - 更深
  ///
  /// 用途：选中文本、悬停状态
  static const Color primaryDarker = Color(0xFFD97706);

  // ==========================================================================
  // 功能色
  // ==========================================================================

  /// 成功色 - Green
  ///
  /// 用途：成功提示、签到完成、正向反馈
  static const Color success = Color(0xFF16A34A);

  /// 成功色 - 浅色
  ///
  /// 用途：成功背景、签到按钮背景
  static const Color successLight = Color(0xFFDCFCE7);

  /// 成功色 - 深色
  ///
  /// 用途：成功文本
  static const Color successDark = Color(0xFF15803D);

  /// 警告色 - Amber
  ///
  /// 用途：警告提示、注意事项
  static const Color warning = Color(0xFFF59E0B);

  /// 警告色 - 浅色
  static const Color warningLight = Color(0xFFFEF3C7);

  /// 错误色 - Red
  ///
  /// 用途：错误提示、删除操作、危险操作
  static const Color error = Color(0xFFDC2626);

  /// 错误色 - 浅色
  static const Color errorLight = Color(0xFFFEE2E2);

  /// 信息色 - Blue
  ///
  /// 用途：提示信息、链接
  static const Color info = Color(0xFF3B82F6);

  /// 信息色 - 浅色
  static const Color infoLight = Color(0xFFDBEAFE);

  // ==========================================================================
  // 中性色（灰度）
  // ==========================================================================

  /// 纯白色
  static const Color white = Color(0xFFFFFFFF);

  /// 纯黑色
  static const Color black = Color(0xFF000000);

  /// 灰度 50 - 最浅灰
  ///
  /// 用途：背景、分隔线
  static const Color grey50 = Color(0xFFFAFAFA);

  /// 灰度 100
  ///
  /// 用途：背景、输入框背景
  static const Color grey100 = Color(0xFFF3F4F6);

  /// 灰度 200
  ///
  /// 用途：边框、分隔线
  static const Color grey200 = Color(0xFFE5E7EB);

  /// 灰度 300
  ///
  /// 用途：边框、禁用状态
  static const Color grey300 = Color(0xFFD1D5DB);

  /// 灰度 400
  ///
  /// 用途：占位符文本、次要图标
  static const Color grey400 = Color(0xFF9CA3AF);

  /// 灰度 500
  ///
  /// 用途：次要文本、图标
  static const Color grey500 = Color(0xFF6B7280);

  /// 灰度 600
  ///
  /// 用途：次要文本
  static const Color grey600 = Color(0xFF4B5563);

  /// 灰度 700
  ///
  /// 用途：主要文本
  static const Color grey700 = Color(0xFF374151);

  /// 灰度 800
  ///
  /// 用途：标题文本
  static const Color grey800 = Color(0xFF1F2937);

  /// 灰度 900 - 最深灰
  ///
  /// 用途：主标题、强调文本
  static const Color grey900 = Color(0xFF111827);

  // ==========================================================================
  // 特定功能色
  // ==========================================================================

  /// Treats 图标颜色
  static const Color treatsIcon = Color(0xFFD97706);

  /// Treats 背景颜色
  static const Color treatsBackground = Color(0xFFFFF4E6);

  /// 签到按钮 - 已签到
  static const Color checkedIn = success;

  /// 签到按钮背景 - 已签到
  static const Color checkedInBackground = successLight;

  /// 签到按钮 - 未签到
  static const Color notCheckedIn = primary;

  // ==========================================================================
  // UI 组件色
  // ==========================================================================

  /// 背景色 - 主背景
  ///
  /// 用途：页面主背景
  static const Color background = Color(0xFFFFFBEB);

  /// 背景色 - 卡片
  ///
  /// 用途：卡片背景
  static const Color cardBackground = white;

  /// 文本色 - 主要
  ///
  /// 用途：正文文本
  static const Color textPrimary = Color(0xFF000000);

  /// 文本色 - 次要
  ///
  /// 用途：次要信息、辅助文本
  static const Color textSecondary = grey600;

  /// 文本色 - 禁用
  ///
  /// 用途：禁用状态文本
  static const Color textDisabled = grey400;

  /// 边框色 - 默认
  ///
  /// 用途：输入框、卡片边框
  static const Color border = grey200;

  /// 边框色 - 焦点
  ///
  /// 用途：聚焦状态边框
  static const Color borderFocus = primary;

  /// 分隔线颜色
  static const Color divider = grey200;

  // ==========================================================================
  // 特殊组件色
  // ==========================================================================

  /// AI 助手 - 渐变开始
  static const Color aiGradientStart = Color(0xFF818CF8); // Indigo 400

  /// AI 助手 - 渐变结束
  static const Color aiGradientEnd = Color(0xFFC084FC); // Purple 400

  /// AI 助手 - 消息气泡（用户）
  static const Color aiUserBubble = Color(0xFFFBBF24); // Amber 400

  /// AI 助手 - 消息气泡（AI）
  static const Color aiBotBubble = white;

  /// 视频相关颜色 - 主色
  static const Color video = Color(0xFF3B82F6); // Blue 500

  /// 视频相关颜色 - 浅色背景
  static const Color videoLight = Color(0xFFDBEAFE); // Blue 100

  /// 图片相关颜色 - 主色
  static const Color image = primary;

  /// 图片相关颜色 - 浅色背景
  static const Color imageLight = primaryExtraLight;

  // ==========================================================================
  // 半透明色（用于阴影、遮罩）
  // ==========================================================================

  /// 黑色半透明 - 5%
  static const Color black5 = Color(0x0D000000);

  /// 黑色半透明 - 8%
  static const Color black8 = Color(0x14000000);

  /// 黑色半透明 - 10%
  static const Color black10 = Color(0x1A000000);

  /// 黑色半透明 - 20%
  static const Color black20 = Color(0x33000000);

  /// 黑色半透明 - 30%
  static const Color black30 = Color(0x4D000000);

  /// 黑色半透明 - 50%
  static const Color black50 = Color(0x80000000);

  /// 白色半透明 - 10%
  static const Color white10 = Color(0x1AFFFFFF);

  /// 白色半透明 - 20%
  static const Color white20 = Color(0x33FFFFFF);

  /// 白色半透明 - 30%
  static const Color white30 = Color(0x4DFFFFFF);

  /// 白色半透明 - 50%
  static const Color white50 = Color(0x80FFFFFF);

  /// 白色半透明 - 90%
  static const Color white90 = Color(0xE6FFFFFF);

  // ==========================================================================
  // 渐变定义
  // ==========================================================================

  /// 主题橙色渐变
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), primary],
  );

  /// AI 助手渐变
  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [aiGradientStart, aiGradientEnd],
  );

  /// 用户消息渐变
  static const LinearGradient userMessageGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), primary],
  );

  // ==========================================================================
  // 辅助方法
  // ==========================================================================

  /// 根据亮度获取对比文本颜色
  ///
  /// 参数：
  /// - backgroundColor: 背景颜色
  ///
  /// 返回值：黑色或白色文本颜色
  static Color getContrastText(Color backgroundColor) {
    // 计算相对亮度
    final luminance = backgroundColor.computeLuminance();
    // 亮度 > 0.5 使用黑色文本，否则使用白色文本
    return luminance > 0.5 ? black : white;
  }

  /// 获取颜色的半透明版本
  ///
  /// 参数：
  /// - color: 原始颜色
  /// - opacity: 不透明度（0.0 - 1.0）
  static Color withAlpha(Color color, double opacity) {
    return color.withValues(alpha: opacity.clamp(0.0, 1.0));
  }
}
