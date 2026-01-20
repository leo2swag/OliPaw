/*
  文件：widgets/profile/born_milestone.dart
  说明：
  - 出生里程碑组件
  - 显示在时间线底部的出生标记

  优化（v2.5）：
  - 从 ProfileScreen 中提取，提高代码复用性
*/
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// 出生里程碑
///
/// 时间线底部的出生标记
class BornMilestone extends StatelessWidget {
  /// 宠物名字
  final String petName;

  const BornMilestone({
    super.key,
    required this.petName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 出生标记点
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.celebration,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
        ),
        const SizedBox(width: 14),

        // 出生卡片
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.celebrationBg,
              borderRadius: AppRadius.allSM,
              border: Border.all(color: AppColors.celebrationBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: AppColors.celebration,
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Born",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.celebration,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Welcome to the world, $petName! 🎉",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.celebrationTextDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
