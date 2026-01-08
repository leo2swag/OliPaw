/*
  文件：widgets/create_post/mood_selector.dart
  说明：
  - 心情选择器组件
  - 可复用的横向滚动心情卡片选择器
  - 支持自定义心情选项

  优化（v2.5）：
  - 从 CreatePostScreen 中提取，提高代码复用性
  - 使用回调函数处理选择事件
*/
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// 心情选择器
///
/// 横向滚动的心情卡片选择器
class MoodSelector extends StatelessWidget {
  /// 心情选项列表
  final List<Map<String, String>> moods;

  /// 当前选中的心情
  final String selectedMood;

  /// 心情选择回调
  final ValueChanged<String> onMoodSelected;

  const MoodSelector({
    super.key,
    required this.moods,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // VIBE CHECK 标题
        const Text(
          "VIBE CHECK",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.grey500,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),

        // 心情选择器：简洁的横向滚动卡片
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              final isSelected = selectedMood == mood['name'];
              return GestureDetector(
                onTap: () => onMoodSelected(mood['name']!),
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.lightOrangeBg : AppColors.white,
                    borderRadius: AppRadius.allMD,
                    border: Border.all(
                      color: isSelected ? AppColors.primaryOrange : AppColors.grey200,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        mood['emoji']!,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood['name']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: isSelected ? AppColors.darkOrange : AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
