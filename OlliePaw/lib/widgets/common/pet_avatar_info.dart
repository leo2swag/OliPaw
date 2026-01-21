/*
  文件：widgets/common/pet_avatar_info.dart
  说明：
  - 宠物头像信息组件
  - 显示头像 + 名称 + 副标题的常用布局
  - 可选操作按钮

  使用示例：
  ```dart
  // 基本用法
  PetAvatarInfo(
    avatarUrl: pet.avatarUrl,
    name: pet.name,
    subtitle: pet.breed,
  )

  // 带操作按钮
  PetAvatarInfo(
    avatarUrl: pet.avatarUrl,
    name: pet.name,
    subtitle: pet.breed,
    actionLabel: 'View',
    onActionTap: () => navigateTo(pet),
  )
  ```
*/

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import 'tap_container.dart';

/// 宠物头像信息组件
///
/// 显示头像 + 名称 + 副标题的常用布局
/// 可选添加操作按钮
class PetAvatarInfo extends StatelessWidget {
  /// 头像URL
  final String avatarUrl;

  /// 名称
  final String name;

  /// 副标题（品种、位置等）
  final String? subtitle;

  /// 头像半径（默认20）
  final double avatarRadius;

  /// 操作按钮标签
  final String? actionLabel;

  /// 操作按钮点击回调
  final VoidCallback? onActionTap;

  /// 操作按钮背景色
  final Color actionBgColor;

  /// 操作按钮文字色
  final Color actionTextColor;

  const PetAvatarInfo({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.subtitle,
    this.avatarRadius = 20,
    this.actionLabel,
    this.onActionTap,
    this.actionBgColor = AppColors.lightOrangeBg,
    this.actionTextColor = AppColors.primaryOrange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 头像
        CircleAvatar(
          radius: avatarRadius,
          backgroundImage: NetworkImage(avatarUrl),
        ),
        const SizedBox(width: AppSpacing.sm),

        // 名称和副标题
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),

        // 操作按钮
        if (actionLabel != null)
          TapContainer(
            onTap: onActionTap,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: actionBgColor,
            borderRadius: AppRadius.allXL,
            child: Text(
              actionLabel!,
              style: TextStyle(
                color: actionTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
