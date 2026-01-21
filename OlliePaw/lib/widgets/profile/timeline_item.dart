/*
  文件：widgets/profile/timeline_item.dart
  说明：
  - 时间轴条目组件
  - 显示宠物成长时间线上的帖子

  优化（v2.5）：
  - 从 ProfileScreen 中提取，提高代码复用性
*/
import 'package:flutter/material.dart';
import '../../models/types.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/constants/app_colors.dart';
import '../common/pill_badge.dart';
import '../common/app_card.dart';

/// 时间轴条目
///
/// 显示时间线上的单个帖子
class TimelineItem extends StatelessWidget {
  /// 帖子数据
  final Post post;

  /// 年龄显示文本
  final String ageAtPost;

  /// 是否是最后一项（控制底部线条显示）
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.post,
    required this.ageAtPost,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 年龄徽章
          Padding(
            padding: const EdgeInsets.only(left: 28, bottom: 6),
            child: PillBadge.orange(text: ageAtPost),
          ),

          // 时间线内容
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 时间线指示器
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 160,
                      color: AppColors.lightOrangeBg,
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // 帖子卡片
              Expanded(
                child: AppCard.flat(
                  padding: AppSpacing.allMD,
                  borderRadius: AppRadius.allSM,
                  border: Border.all(color: AppColors.grey200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 日期
                      Text(
                        post.date,
                        style: const TextStyle(
                          color: AppColors.grey500,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // 图片（如果有）
                      if (post.imageUrl != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: AppRadius.allXS,
                          child: Image.network(
                            post.imageUrl!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],

                      // 内容
                      const SizedBox(height: 8),
                      Text(
                        post.content,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                      ),

                      // 点赞图标
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.favorite_border,
                          size: 16,
                          color: AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
