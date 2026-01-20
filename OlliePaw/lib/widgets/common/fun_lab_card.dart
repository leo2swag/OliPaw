/*
  文件：widgets/common/fun_lab_card.dart
  说明：
  - Fun Labs 功能卡片组件
  - 用于展示 AI 功能入口

  使用示例：
  ```dart
  FunLabCard(
    icon: LucideIcons.hourglass,
    title: 'Growth Predictor',
    onTap: () => showTimeMachine(),
    gradient: LinearGradient(...),
  )
  ```
*/

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// Fun Labs 功能卡片
///
/// 用于展示 AI 功能入口
/// 支持渐变背景或纯色背景
class FunLabCard extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 标题
  final String title;

  /// 点击回调
  final VoidCallback onTap;

  /// 渐变背景（优先使用）
  final Gradient? gradient;

  /// 背景色（gradient为空时使用）
  final Color? backgroundColor;

  /// 边框色（背景为白色时显示）
  final Color? borderColor;

  /// 图标颜色
  final Color iconColor;

  /// 文字颜色
  final Color textColor;

  /// 卡片高度
  final double height;

  const FunLabCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.gradient,
    this.backgroundColor,
    this.borderColor,
    this.iconColor = AppColors.white,
    this.textColor = AppColors.white,
    this.height = 100,
  });

  /// 渐变背景样式
  const FunLabCard.gradient({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required Gradient this.gradient,
    this.height = 100,
  })  : backgroundColor = null,
        borderColor = null,
        iconColor = AppColors.white,
        textColor = AppColors.white;

  /// 白色背景样式
  const FunLabCard.outlined({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = AppColors.primaryOrange,
    this.height = 100,
  })  : gradient = null,
        backgroundColor = AppColors.white,
        borderColor = AppColors.border,
        textColor = AppColors.textDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? backgroundColor : null,
          borderRadius: AppRadius.allXL,
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: iconColor),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
