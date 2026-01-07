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
import '../../models/types.dart';

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
              colors: [Colors.orange.shade300, Colors.orange.shade500],
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
          style: TextStyle(
            color: Colors.grey.shade600,
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
            _buildPillBadge(
              "🎂",
              ageText,
              const Color(0xFFFEF3C7),
              const Color(0xFFB45309),
            ),

            // 体重徽章（如果有体重记录）
            if (pet.weightHistory.isNotEmpty) ...[
              const SizedBox(width: 6),
              _buildPillBadge(
                null,
                "${pet.weightHistory.last.weight} kg",
                const Color(0xFFDBEAFE),
                const Color(0xFF1E40AF),
                icon: LucideIcons.scale,
              ),
            ]
          ],
        ),
      ],
    );
  }

  /// 构建徽章组件
  Widget _buildPillBadge(
    String? emoji,
    String text,
    Color bg,
    Color textCol, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: textCol.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) Text(emoji, style: const TextStyle(fontSize: 11)),
          if (icon != null) Icon(icon, size: 12, color: textCol),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 10,
              color: textCol,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
