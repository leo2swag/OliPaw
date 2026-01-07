/*
  文件：widgets/common/section_header.dart
  说明：
  - Section 标题组件
  - 用于页面分区标题 + 操作按钮
  - 统一的布局和样式

  使用示例：
  ```dart
  // 基本用法
  SectionHeader(
    title: 'Vaccine Records',
    actionLabel: 'Add',
    actionIcon: LucideIcons.plus,
    onActionPressed: () => _showAddVaccineDialog(),
  )

  // 自定义按钮颜色
  SectionHeader(
    title: 'Weight History',
    actionLabel: 'Add',
    onActionPressed: () => _showAddWeightDialog(),
    actionButtonColor: Colors.teal,
  )

  // 仅标题，无操作按钮
  SectionHeader(
    title: 'Recent Activities',
  )
  ```

  替换位置：
  - health_tracker.dart - Vaccine section (lines 116-143)
  - health_tracker.dart - Weight section (lines 157-184)
*/

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';

/// Section Header 组件
///
/// 用于页面分区的标题栏，支持添加操作按钮
///
/// 特点：
/// - 标题 + 操作按钮的标准布局
/// - 可自定义按钮颜色
/// - 可选的图标和标签
/// - 统一的样式和间距
class SectionHeader extends StatelessWidget {
  /// 标题文本
  final String title;

  /// 操作按钮文字（可选）
  final String? actionLabel;

  /// 操作按钮图标（可选，默认为 LucideIcons.plus）
  final IconData? actionIcon;

  /// 操作按钮回调（可选）
  final VoidCallback? onActionPressed;

  /// 按钮背景颜色（可选，默认使用 accentTeal）
  final Color? actionButtonColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.actionIcon,
    this.onActionPressed,
    this.actionButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 标题
        Text(
          title,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeXL,
            fontWeight: AppTheme.fontWeightBlack,
          ),
        ),

        // 操作按钮（可选）
        if (actionLabel != null && onActionPressed != null)
          ElevatedButton.icon(
            onPressed: onActionPressed,
            icon: Icon(
              actionIcon ?? LucideIcons.plus,
              size: 16,
            ),
            label: Text(actionLabel!),
            style: ElevatedButton.styleFrom(
              backgroundColor: actionButtonColor ?? AppTheme.accentTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceM,
                vertical: AppTheme.spaceS,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              elevation: 0,
            ),
          ),
      ],
    );
  }
}
