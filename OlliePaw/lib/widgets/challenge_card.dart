/*
  文件：widgets/challenge_card.dart
  说明：
  - 首页“每日挑战”卡片，点击跳转到发帖页（CreatePostScreen）。
  - 展示挑战的标题、描述与奖励（Treats）。
  注意：本文件仅添加中文注释，不改变逻辑。
*/
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/types.dart';
import '../screens/create_post_screen.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_dimensions.dart';

/// 每日挑战卡片：展示挑战信息，点击跳转发帖
class ChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const ChallengeCard({super.key, required this.challenge});

  @override
  /// 卡片布局：紧凑设计，突出任务内容
  Widget build(BuildContext context) {
    return GestureDetector(
      // 点击进入创建动态页面（鼓励完成挑战）
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: AppColors.challengeGradient,
          borderRadius: AppRadius.allLG,
          boxShadow: [BoxShadow(color: AppColors.challengePrimary.withValues(alpha: 0.25), blurRadius: AppSpacing.sm, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            // 任务图标
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.25),
                borderRadius: AppRadius.allMD,
              ),
              child: Text(challenge.icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: AppSpacing.md),

            // 任务内容（高亮显示）
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 任务描述
                  Text(
                    challenge.description,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.95),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // 奖励徽标
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.25),
                borderRadius: AppRadius.allMD,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.bone, size: AppSizes.iconXS + 2, color: AppColors.white),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    "${challenge.reward}",
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}