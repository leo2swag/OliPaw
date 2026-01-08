/*
  文件：widgets/create_post/category_selector.dart
  说明：
  - 分类选择器组件
  - 可复用的水平分类选择器
  - 支持自定义分类选项

  优化（v2.5）：
  - 从 CreatePostScreen 中提取，提高代码复用性
  - 使用回调函数处理选择事件
*/
import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';

/// 分类选择器
///
/// 水平布局的分类选择器
class CategorySelector extends StatelessWidget {
  /// 分类选项列表
  final List<Map<String, String>> categories;

  /// 当前选中的分类
  final String selectedCategory;

  /// 分类选择回调
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CATEGORY 标题
        const Text(
          "CATEGORY",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),

        // 分类选择器：单行布局
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: categories.map((category) {
            final isSelected = selectedCategory == category['name'];
            return Flexible(
              child: GestureDetector(
                onTap: () => onCategorySelected(category['name']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.orange.shade100 : Colors.white,
                    borderRadius: AppRadius.allMD,
                    border: Border.all(
                      color: isSelected ? Colors.orange.shade300 : Colors.grey.shade200,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category['emoji']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          category['name']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isSelected ? Colors.orange.shade800 : Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
