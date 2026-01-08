/*
  文件：widgets/common/empty_state.dart
  说明：
  - 空状态展示组件
  - 用于列表/数据为空时的占位显示
  - 统一的视觉风格和交互提示

  使用示例：
  ```dart
  // 基本用法
  EmptyState(
    icon: Icons.vaccines,
    title: 'No vaccine records yet',
  )

  // 带副标题
  EmptyState(
    icon: LucideIcons.heartPulse,
    title: 'No health data',
    subtitle: 'Start tracking your pet\'s health by adding records',
  )

  // 自定义图标颜色和大小
  EmptyState(
    icon: Icons.photo_library,
    title: 'No photos yet',
    subtitle: 'Add your first memory',
    iconColor: Colors.orange,
    iconSize: 64.0,
  )
  ```

  替换位置：
  - health_tracker.dart - _buildEmptyState (lines 52-80)
  - comments_bottom_sheet.dart - _buildEmptyState (lines 295-325)
*/

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// 空状态展示组件
///
/// 用于数据列表为空时的占位显示
/// 提供统一的视觉风格和用户提示
///
/// 特点：
/// - 图标 + 标题 + 副标题的标准布局
/// - 可自定义图标颜色和大小
/// - 支持可选的操作按钮
/// - 居中显示，自带合适的内边距
/// - 文本自动居中对齐
///
/// v2.7 更新：
/// - 添加 action 按钮支持
/// - 使用 AppColors 和 AppSpacing 常量
class EmptyState extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 标题文本
  final String title;

  /// 副标题（可选）
  ///
  /// 用于提供额外的说明或操作提示
  final String? subtitle;

  /// 图标颜色（可选，默认使用 grey400）
  final Color? iconColor;

  /// 图标大小（默认 64px）
  final double iconSize;

  /// 操作按钮（可选）
  ///
  /// 用于提供用户可执行的操作（如"添加"、"重试"等）
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.iconSize = 64.0,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppColors.grey400,
            ),
            const SizedBox(height: AppSpacing.lg),

            // 标题
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.grey700,
              ),
              textAlign: TextAlign.center,
            ),

            // 副标题（可选）
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.grey500,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 操作按钮（可选）
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
