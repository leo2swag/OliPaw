/*
  文件：widgets/profile/profile_info_card.dart
  说明：
  - 个人资料信息卡片组件
  - 显示品种、性别和个性签名

  优化（v2.5）：
  - 从 ProfileScreen 中提取，提高代码复用性
*/
import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/constants/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/types.dart';
import '../common/app_card.dart';

/// 个人资料信息卡片
///
/// 显示宠物的品种、性别和个性签名
class ProfileInfoCard extends StatelessWidget {
  /// 宠物数据
  final Pet pet;

  const ProfileInfoCard({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppCard.soft(
        padding: AppSpacing.allXL,
        borderRadius: AppRadius.allXL,
        child: Column(
          children: [
            // 品种和性别
            Row(
              children: [
                _buildInfoColumn(pet.breed, "BREED"),
                _buildDivider(),
                _buildInfoColumn("Male", "GENDER"),
              ],
            ),
            const Divider(height: 30),

            // 个性签名
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  LucideIcons.quote,
                  color: AppColors.primaryOrange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pet.bio,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppColors.grey700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息列
  Widget _buildInfoColumn(String val, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            val,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFF14B8A6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分隔线
  Widget _buildDivider() => Container(
        width: 1,
        height: 30,
        color: AppColors.grey200,
      );
}
