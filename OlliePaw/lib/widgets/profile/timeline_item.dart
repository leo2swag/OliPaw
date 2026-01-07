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
            child: _buildPillBadge(
              null,
              ageAtPost,
              const Color(0xFFFEF3C7),
              const Color(0xFFB45309),
            ),
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
                      color: Colors.orange.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 160,
                      color: Colors.orange.shade200.withValues(alpha: 0.5),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // 帖子卡片
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 日期
                      Text(
                        post.date,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // 图片（如果有）
                      if (post.imageUrl != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
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
                          color: Colors.black87,
                        ),
                      ),

                      // 点赞图标
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.favorite_border,
                          size: 16,
                          color: Colors.grey,
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

  /// 构建徽章组件
  Widget _buildPillBadge(
    String? emoji,
    String text,
    Color bg,
    Color textCol,
  ) {
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
