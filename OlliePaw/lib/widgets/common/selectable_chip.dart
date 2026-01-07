/*
  文件：widgets/common/selectable_chip.dart
  说明：
  - 可选择芯片组件
  - 用于心情选择、分类选择等场景
  - 支持 emoji 或 icon 显示
  - 支持选中/未选中状态切换

  使用示例：
  ```dart
  // 带 emoji 的芯片
  SelectableChip(
    label: 'Happy',
    emoji: '😊',
    isSelected: _selectedMood == 'Happy',
    onTap: () => setState(() => _selectedMood = 'Happy'),
  )

  // 带 icon 的芯片
  SelectableChip(
    label: 'Walk',
    icon: LucideIcons.walk,
    isSelected: _selectedCategory == 'Walk',
    onTap: () => setState(() => _selectedCategory = 'Walk'),
  )

  // 自定义颜色
  SelectableChip(
    label: 'Special',
    emoji: '⭐',
    isSelected: true,
    selectedColor: Colors.purple,
    borderColor: Colors.purpleAccent,
    onTap: () {},
  )
  ```

  替换位置：
  - create_post_screen.dart - 心情选择器 (lines 196-237)
  - create_post_screen.dart - 分类选择器 (lines 414-457)
  - home_screen.dart - 分类按钮 (lines 242-252)
*/

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 可选择芯片组件
///
/// 用于单选或多选场景的芯片展示
/// 支持 emoji 或 icon 图标，并有选中/未选中两种视觉状态
///
/// 特点：
/// - 支持 emoji 和 icon 两种图标类型
/// - 选中状态有背景色和边框变化
/// - 三种预设尺寸（small/medium/large）
/// - 可自定义选中颜色和边框颜色
/// - 文本自动省略（过长时）
class SelectableChip extends StatelessWidget {
  /// 标签文本
  final String label;

  /// Emoji 图标（与 icon 二选一，emoji 优先）
  final String? emoji;

  /// Icon 图标（与 emoji 二选一）
  final IconData? icon;

  /// 是否选中
  final bool isSelected;

  /// 点击回调
  final VoidCallback? onTap;

  /// 芯片尺寸
  final SelectableChipSize size;

  /// 自定义选中背景颜色（可选，默认使用 primaryOrange）
  final Color? selectedColor;

  /// 自定义边框颜色（可选，默认使用 primaryOrange）
  final Color? borderColor;

  const SelectableChip({
    super.key,
    required this.label,
    this.emoji,
    this.icon,
    required this.isSelected,
    this.onTap,
    this.size = SelectableChipSize.medium,
    this.selectedColor,
    this.borderColor,
  }) : assert(
          emoji != null || icon != null,
          'SelectableChip: Must provide either emoji or icon',
        );

  @override
  Widget build(BuildContext context) {
    // 使用自定义颜色或默认 Orange 主题色
    final effectiveSelectedColor =
        selectedColor ?? AppTheme.primaryOrangeLight;
    final effectiveBorderColor = borderColor ?? AppTheme.primaryOrange;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.horizontalPadding,
          vertical: size.verticalPadding,
        ),
        decoration: BoxDecoration(
          // 选中：淡色背景，未选中：白色背景
          color: isSelected
              ? effectiveSelectedColor.withValues(alpha: 0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(size.borderRadius),
          border: Border.all(
            // 选中：彩色边框，未选中：灰色边框
            color: isSelected ? effectiveBorderColor : AppTheme.grey200,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标部分（emoji 或 icon）
            if (emoji != null)
              Text(
                emoji!,
                style: TextStyle(fontSize: size.iconSize),
              )
            else if (icon != null)
              Icon(
                icon,
                size: size.iconSize,
                color: isSelected ? effectiveBorderColor : AppTheme.grey600,
              ),
            SizedBox(width: size.spacing),
            // 标签文本
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: AppTheme.fontWeightBold,
                  fontSize: size.fontSize,
                  color: isSelected ? effectiveBorderColor : AppTheme.grey700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 芯片尺寸枚举
///
/// 定义三种预设尺寸，包含图标、字体、间距、圆角配置
enum SelectableChipSize {
  /// 小尺寸
  ///
  /// 用于：紧凑布局、较小的选择器
  /// 图标：14px，字体：10px，圆角：10px
  small(
    iconSize: 14.0,
    fontSize: 10.0,
    horizontalPadding: 8.0,
    verticalPadding: 6.0,
    spacing: 3.0,
    borderRadius: 10.0,
  ),

  /// 中等尺寸（默认）
  ///
  /// 用于：常规选择器
  /// 图标：16px，字体：12px，圆角：12px
  medium(
    iconSize: 16.0,
    fontSize: 12.0,
    horizontalPadding: 12.0,
    verticalPadding: 10.0,
    spacing: 4.0,
    borderRadius: 12.0,
  ),

  /// 大尺寸
  ///
  /// 用于：主要选择器、强调显示
  /// 图标：20px，字体：14px，圆角：14px
  large(
    iconSize: 20.0,
    fontSize: 14.0,
    horizontalPadding: 16.0,
    verticalPadding: 12.0,
    spacing: 6.0,
    borderRadius: 14.0,
  );

  /// 图标大小
  final double iconSize;

  /// 字体大小
  final double fontSize;

  /// 水平内边距
  final double horizontalPadding;

  /// 垂直内边距
  final double verticalPadding;

  /// 图标与文字间距
  final double spacing;

  /// 圆角大小
  final double borderRadius;

  const SelectableChipSize({
    required this.iconSize,
    required this.fontSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.spacing,
    required this.borderRadius,
  });
}
