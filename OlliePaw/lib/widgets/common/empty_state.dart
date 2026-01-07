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
import '../../theme/app_theme.dart';

/// 空状态展示组件
///
/// 用于数据列表为空时的占位显示
/// 提供统一的视觉风格和用户提示
///
/// 特点：
/// - 图标 + 标题 + 副标题的标准布局
/// - 可自定义图标颜色和大小
/// - 居中显示，自带合适的内边距
/// - 文本自动居中对齐
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

  /// 图标大小（默认 48px）
  final double iconSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.iconSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space3XL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppTheme.grey400,
            ),
            const SizedBox(height: AppTheme.spaceL),

            // 标题
            Text(
              title,
              style: TextStyle(
                fontSize: AppTheme.fontSizeL,
                fontWeight: AppTheme.fontWeightBold,
                color: AppTheme.grey700,
              ),
              textAlign: TextAlign.center,
            ),

            // 副标题（可选）
            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.spaceS),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: AppTheme.fontSizeSM,
                  color: AppTheme.grey500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
