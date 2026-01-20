/*
  文件：widgets/profile/profile_header.dart
  说明：
  - 个人资料页头部组件
  - 包含头像、名字、品种和徽章

  优化（v2.5）：
  - 从 ProfileScreen 中提取，提高代码复用性
  - 使用工具方法处理年龄计算
*/
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../models/types.dart';
import '../common/pill_badge.dart';

/// 个人资料头部
///
/// 包含头像、名字、品种和年龄/体重徽章
class ProfileHeader extends StatelessWidget {
  /// 宠物数据
  final Pet pet;

  /// 年龄显示文本
  final String ageText;

  const ProfileHeader({
    super.key,
    required this.pet,
    required this.ageText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 头像
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primaryOrange.withValues(alpha: 0.7), AppColors.primaryOrange],
            ),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(pet.avatarUrl),
          ),
        ),
        const SizedBox(height: 8),

        // 名字
        Text(
          pet.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),

        // 品种
        Text(
          pet.breed,
          style: const TextStyle(
            color: AppColors.grey600,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),

        // 徽章（年龄 + 体重）
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 年龄徽章
            PillBadge.orange(emoji: "🎂", text: ageText),

            // 体重徽章（如果有体重记录）
            if (pet.weightHistory.isNotEmpty) ...[
              const SizedBox(width: 6),
              PillBadge.blue(
                icon: LucideIcons.scale,
                text: "${pet.weightHistory.last.weight} kg",
              ),
            ]
          ],
        ),
      ],
    );
  }
}
