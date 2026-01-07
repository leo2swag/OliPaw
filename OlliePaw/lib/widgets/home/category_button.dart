/*
  文件：widgets/home/category_button.dart
  说明：
  - 可复用的类别按钮组件
  - 用于HomeScreen的类别筛选
  - 支持选中/未选中状态
*/

import 'package:flutter/material.dart';
import '../../core/constants/ui_constants.dart';

/// 类别按钮组件
///
/// 用于显示类别图标和标签，支持选中状态
class CategoryButton extends StatelessWidget {
  /// 类别表情符号
  final String emoji;

  /// 类别标签
  final String label;

  /// 背景颜色 (选中时)
  final Color bgColor;

  /// 文本颜色 (选中时)
  final Color textColor;

  /// 是否选中
  final bool isSelected;

  /// 点击回调
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.emoji,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: UIDimensions.categoryButtonSize,
        height: UIDimensions.categoryButtonSize,
        decoration: BoxDecoration(
          color: isSelected ? bgColor : Colors.white,
          border: Border.all(
            color: isSelected ? textColor : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(UIDimensions.radiusL),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: UIDimensions.spacingXS),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? textColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
