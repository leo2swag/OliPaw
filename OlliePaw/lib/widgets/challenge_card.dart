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
  /// 卡片布局：背景渐变 + 奖杯装饰 + 信息区 + 奖励徽标
  Widget build(BuildContext context) {
    return GestureDetector(
      // 点击进入创建动态页面（鼓励完成挑战）
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen())),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          gradient: AppColors.challengeGradient,
          borderRadius: AppRadius.allXL,
          boxShadow: [BoxShadow(color: AppColors.challengePrimary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            const Positioned(
              right: -10, top: -10,
              child: Opacity(
                opacity: 0.1,
                child: Icon(LucideIcons.trophy, size: 80, color: Colors.white),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: AppRadius.allMD,
                  ),
                  child: Text(challenge.icon, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("DAILY CHALLENGE", style: const TextStyle(color: AppColors.challengeTextLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text(challenge.title, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(challenge.description, style: TextStyle(color: AppColors.white.withOpacity(0.9), fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: AppRadius.allSM,
                  ),
                  child: Column(
                    children: [
                      const Text("REWARD", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.challengeTextLight)),
                      Row(
                        children: [
                          const Icon(LucideIcons.bone, size: 12, color: AppColors.white),
                          const SizedBox(width: 2),
                          Text("${challenge.reward}", style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}