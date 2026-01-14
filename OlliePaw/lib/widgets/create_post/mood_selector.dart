/*
  文件：widgets/create_post/mood_selector.dart
  说明：
  - 心情选择器组件
  - 可复用的横向滚动心情卡片选择器
  - 支持自定义心情选项

  优化（v2.5）：
  - 从 CreatePostScreen 中提取，提高代码复用性
  - 使用回调函数处理选择事件

  v3.0 更新 - 温暖UI设计：
  - 使用OrganicBlob组件替代方形卡片
  - 有机形状，更温暖友好的视觉效果
  - 柔和的pastel配色
*/
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../common/organic_blob.dart';

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

        // 心情选择器：有机形状blob卡片（v3.0 温暖设计）
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              final isSelected = selectedMood == mood['name'];

              // 为每个心情分配不同的blob颜色和变体
              final blobColor = _getMoodColor(mood['name']!, isSelected);
              final blobVariant = index % 7; // 循环使用7种blob形状

              return GestureDetector(
                onTap: () => onMoodSelected(mood['name']!),
                child: Container(
                  width: 85,
                  margin: const EdgeInsets.only(right: AppSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 有机blob形状
                      OrganicBlob.mood(
                        size: 65,
                        color: blobColor,
                        variant: blobVariant,
                        child: Text(
                          mood['emoji']!,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // 心情名称
                      Text(
                        mood['name']!,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 11,
                          color: isSelected ? AppColors.primaryOrange : AppColors.grey700,
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

  /// 根据心情名称获取对应的blob颜色
  ///
  /// 使用温暖的pastel色调，选中时饱和度更高
  Color _getMoodColor(String moodName, bool isSelected) {
    // 基础颜色映射（根据常见心情）
    final Map<String, Color> moodColorMap = {
      'Happy': AppColors.moodHappy,
      'Excited': AppColors.moodExcited,
      'Calm': AppColors.moodCalm,
      'Playful': AppColors.moodPlayful,
      'Sleepy': AppColors.moodSleepy,
      'Energetic': AppColors.moodEnergetic,
      'Love': AppColors.moodLove,
      'Nature': AppColors.moodNature,
    };

    // 获取基础颜色，如果没有匹配则使用默认橙色
    final baseColor = moodColorMap[moodName] ?? AppColors.primaryOrange;

    // 选中时使用完整颜色，未选中时使用更淡的版本
    return isSelected ? baseColor : baseColor.withValues(alpha: 0.3);
  }
}
