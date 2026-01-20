/*
  文件：widgets/home/category_button.dart
  说明：
  - 可复用的类别按钮组件
  - 用于HomeScreen的类别筛选
  - 支持选中/未选中状态
*/

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

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
        width: AppSizes.categoryButtonSize,
        height: AppSizes.categoryButtonSize,
        decoration: BoxDecoration(
          color: isSelected ? bgColor : AppColors.white,
          border: Border.all(
            color: isSelected ? textColor : AppColors.grey300,
            width: AppSizes.borderWidthNormal,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSelected ? textColor : AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
