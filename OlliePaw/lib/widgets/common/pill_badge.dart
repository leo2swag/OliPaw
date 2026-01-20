/*
  文件：widgets/common/pill_badge.dart
  说明：
  - 药丸形徽章组件
  - 用于显示状态、标签、年龄等信息
  - 支持 emoji 或 icon

  使用示例：
  ```dart
  // 年龄徽章
  PillBadge(
    emoji: '🎂',
    text: '3y 7m',
    backgroundColor: const Color(0xFFFEF3C7),
    textColor: const Color(0xFFB45309),
  )

  // 体重徽章
  PillBadge(
    icon: LucideIcons.scale,
    text: '29.5 kg',
    backgroundColor: const Color(0xFFDBEAFE),
    textColor: const Color(0xFF1E40AF),
  )

  // 使用主题颜色
  PillBadge.orange(
    emoji: '🎾',
    text: 'Playing',
  )
  ```

  替换位置：
  - profile_screen.dart - _buildPillBadge (lines 125-143)
  - 多处年龄/体重/状态显示
*/

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/constants/app_colors.dart';

/// 药丸形徽章组件
///
/// 用于显示状态、标签、数值等简短信息
/// 支持 emoji 或 icon 图标
///
/// 特点：
/// - 圆角药丸形状
/// - 支持 emoji 和 icon
/// - 自带阴影效果
/// - 预设主题色快捷构造函数
class PillBadge extends StatelessWidget {
  /// Emoji 图标（与 icon 二选一，emoji 优先）
  final String? emoji;

  /// Icon 图标（与 emoji 二选一）
  final IconData? icon;

  /// 文本内容
  final String text;

  /// 背景颜色
  final Color backgroundColor;

  /// 文字颜色
  final Color textColor;

  /// 是否显示阴影
  final bool showShadow;

  const PillBadge({
    super.key,
    this.emoji,
    this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.showShadow = true,
  });

  /// Orange 主题快捷构造函数
  ///
  /// 用于：主要状态、强调信息
  const PillBadge.orange({
    super.key,
    this.emoji,
    this.icon,
    required this.text,
    this.showShadow = true,
  })  : backgroundColor = AppColors.badgeOrangeBg,
        textColor = AppColors.badgeOrangeText;

  /// Blue 主题快捷构造函数
  ///
  /// 用于：体重、健康数据
  const PillBadge.blue({
    super.key,
    this.emoji,
    this.icon,
    required this.text,
    this.showShadow = true,
  })  : backgroundColor = AppColors.badgeBlueBg,
        textColor = AppColors.badgeBlueText;

  /// Green 主题快捷构造函数
  ///
  /// 用于：成功状态、正向数据
  const PillBadge.green({
    super.key,
    this.emoji,
    this.icon,
    required this.text,
    this.showShadow = true,
  })  : backgroundColor = AppColors.successBg,
        textColor = AppColors.success;

  /// Pink 主题快捷构造函数
  ///
  /// 用于：特殊事件、里程碑
  const PillBadge.pink({
    super.key,
    this.emoji,
    this.icon,
    required this.text,
    this.showShadow = true,
  })  : backgroundColor = AppColors.celebrationBg,
        textColor = AppColors.celebration;

  /// Grey 主题快捷构造函数
  ///
  /// 用于：次要信息、中性状态
  const PillBadge.grey({
    super.key,
    this.emoji,
    this.icon,
    required this.text,
    this.showShadow = true,
  })  : backgroundColor = AppColors.grey100,
        textColor = AppColors.grey700;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: textColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标部分（emoji 或 icon）
          if (emoji != null)
            Text(
              emoji!,
              style: const TextStyle(fontSize: 11),
            ),
          if (icon != null)
            Icon(
              icon,
              size: 12,
              color: textColor,
            ),
          // 如果有图标，添加间距
          if (emoji != null || icon != null) const SizedBox(width: 4),
          // 文本
          Text(
            text,
            style: TextStyle(
              fontWeight: AppTheme.fontWeightBlack,
              fontSize: AppTheme.fontSizeXS,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
