/*
  文件：widgets/common/playful_empty_state.dart
  说明：
  - 温暖友好的空状态组件
  - 使用有机blob形状和表情符号
  - 替代冷冰冰的空状态提示

  v3.0 新增 - 温暖UI设计：
  - 大型表情符号配有机blob背景
  - 友好的提示文案
  - 可选操作按钮
  - 使用温暖的配色和圆润设计

  使用示例：
  ```dart
  // 基本空状态
  PlayfulEmptyState(
    emoji: AppEmojis.emptyBox,
    title: 'No posts yet',
    message: 'Share your first moment with your pet!',
  )

  // 带操作按钮的空状态
  PlayfulEmptyState(
    emoji: AppEmojis.paw,
    title: 'No pets added',
    message: 'Add your first furry friend to get started',
    actionLabel: 'Add Pet',
    onAction: () => _navigateToAddPet(),
  )

  // 自定义颜色的空状态
  PlayfulEmptyState(
    emoji: AppEmojis.sleep,
    title: 'No activities today',
    message: 'Record your pet\'s first activity',
    blobColor: AppColors.moodSleepy,
  )
  ```
*/

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_emojis.dart';
import '../../core/theme/app_dimensions.dart';
import 'organic_blob.dart';
import 'app_button.dart';

/// 温暖友好的空状态组件
///
/// 使用有机blob形状和大型表情符号创建吸引人的空状态
class PlayfulEmptyState extends StatelessWidget {
  /// 表情符号
  final String emoji;

  /// 标题
  final String title;

  /// 描述消息
  final String message;

  /// 操作按钮文本（可选）
  final String? actionLabel;

  /// 操作按钮回调（可选）
  final VoidCallback? onAction;

  /// Blob背景颜色（可选，默认使用橙色）
  final Color? blobColor;

  /// Blob形状变体（0-6，默认0）
  final int blobVariant;

  /// 表情符号大小（默认80）
  final double emojiSize;

  /// Blob大小（默认140）
  final double blobSize;

  const PlayfulEmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.blobColor,
    this.blobVariant = 0,
    this.emojiSize = 80,
    this.blobSize = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.allXXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 表情符号 + 有机blob背景
            OrganicBlob.mood(
              size: blobSize,
              color: blobColor ?? AppColors.primaryOrange.withValues(alpha: 0.2),
              variant: blobVariant,
              child: Text(
                emoji,
                style: TextStyle(fontSize: emojiSize),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // 标题
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.grey800,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.sm),

            // 描述消息
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.grey600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // 操作按钮（如果提供）
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton.primary(
                label: actionLabel!,
                onPressed: onAction,
                size: AppButtonSize.large,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 预设的空状态组件工厂方法
///
/// 为常见场景提供快捷方式
class PlayfulEmptyStates {
  PlayfulEmptyStates._();

  /// 没有帖子
  static Widget noPosts({VoidCallback? onCreatePost}) {
    return PlayfulEmptyState(
      emoji: AppEmojis.camera,
      title: 'No posts yet',
      message: 'Share your first moment with your pet!',
      actionLabel: onCreatePost != null ? '${AppEmojis.add} Create Post' : null,
      onAction: onCreatePost,
      blobColor: AppColors.moodHappy,
      blobVariant: 1,
    );
  }

  /// 没有宠物
  static Widget noPets({VoidCallback? onAddPet}) {
    return PlayfulEmptyState(
      emoji: AppEmojis.paw,
      title: 'No pets added',
      message: 'Add your first furry friend to get started',
      actionLabel: onAddPet != null ? '${AppEmojis.add} Add Pet' : null,
      onAction: onAddPet,
      blobColor: AppColors.primaryOrange,
      blobVariant: 2,
    );
  }

  /// 没有活动
  static Widget noActivities({VoidCallback? onAddActivity}) {
    return PlayfulEmptyState(
      emoji: AppEmojis.sleep,
      title: 'No activities today',
      message: 'Record your pet\'s first activity of the day',
      actionLabel: onAddActivity != null ? '${AppEmojis.add} Add Activity' : null,
      onAction: onAddActivity,
      blobColor: AppColors.moodSleepy,
      blobVariant: 3,
    );
  }

  /// 没有健康记录
  static Widget noHealthRecords({VoidCallback? onAddRecord}) {
    return PlayfulEmptyState(
      emoji: AppEmojis.health,
      title: 'No health records',
      message: 'Keep track of your pet\'s health journey',
      actionLabel: onAddRecord != null ? '${AppEmojis.add} Add Record' : null,
      onAction: onAddRecord,
      blobColor: AppColors.categoryHealth,
      blobVariant: 4,
    );
  }

  /// 没有里程碑
  static Widget noMilestones({VoidCallback? onAddMilestone}) {
    return PlayfulEmptyState(
      emoji: AppEmojis.star,
      title: 'No milestones yet',
      message: 'Celebrate your pet\'s special moments',
      actionLabel: onAddMilestone != null ? '${AppEmojis.add} Add Milestone' : null,
      onAction: onAddMilestone,
      blobColor: AppColors.categoryMilestone,
      blobVariant: 5,
    );
  }

  /// 没有搜索结果
  static Widget noSearchResults({String? query}) {
    return PlayfulEmptyState(
      emoji: AppEmojis.search,
      title: 'No results found',
      message: query != null
          ? 'We couldn\'t find anything matching "$query"'
          : 'Try adjusting your search',
      blobColor: AppColors.moodCalm,
      blobVariant: 6,
    );
  }

  /// 通用空状态
  static Widget generic({
    required String emoji,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Color? blobColor,
    int blobVariant = 0,
  }) {
    return PlayfulEmptyState(
      emoji: emoji,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      blobColor: blobColor,
      blobVariant: blobVariant,
    );
  }
}

/// 小型空状态组件（用于卡片内部）
///
/// 更紧凑的版本，适用于空间有限的场景
class CompactEmptyState extends StatelessWidget {
  /// 表情符号
  final String emoji;

  /// 消息文本
  final String message;

  /// Blob颜色（可选）
  final Color? blobColor;

  const CompactEmptyState({
    super.key,
    required this.emoji,
    required this.message,
    this.blobColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.allLG,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 小型blob + 表情符号
          OrganicBlob.mood(
            size: 60,
            color: blobColor ?? AppColors.grey300,
            variant: 1,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 消息
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
