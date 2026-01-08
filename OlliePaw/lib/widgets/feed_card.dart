/*
  文件：widgets/feed_card.dart
  说明：
  - 社区动态卡片：展示作者信息、内容、图片、互动操作等。
  - 支持“点赞（Treats）”本地切换，广告帖带特别样式。
  注意：本文件仅添加中文注释，不改变逻辑。
*/
import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/types.dart';
import 'comments_bottom_sheet.dart';

/// 动态卡片：展示帖子与交互操作
class FeedCard extends StatefulWidget {
  final Post post;
  final bool isOwner;

  const FeedCard({super.key, required this.post, this.isOwner = false});

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> with SingleTickerProviderStateMixin {
  // 本地点赞计数与状态
  late int likes;
  bool hasLiked = false;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    likes = widget.post.likes;

    // 点赞动画控制器
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      hasLiked = !hasLiked;
      likes += hasLiked ? 1 : -1;
    });

    if (hasLiked) {
      _likeAnimationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        // 广告帖使用淡黄色背景
        color: widget.post.isAd ? const Color(0xFFFFFBEB) : Colors.white,
        borderRadius: AppRadius.allXXL,
        border: Border.all(
          color: widget.post.isAd ? Colors.amber.shade200 : AppColors.grey100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.post.authorAvatar),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.post.authorName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (widget.post.isAd)
                             // 广告帖带认证/推广徽章
                             const Padding(
                               padding: EdgeInsets.only(left: 4),
                               child: Icon(LucideIcons.badgeCheck, size: 16, color: Colors.blue),
                             )
                        ],
                      ),
                      if (widget.post.location != null)
                        Row(
                          children: [
                            const Icon(LucideIcons.mapPin, size: 12, color: AppColors.grey500),
                            const SizedBox(width: 4),
                            Text(widget.post.location!, style: const TextStyle(fontSize: 12, color: AppColors.grey500)),
                          ],
                        )
                    ],
                  ),
                ),
                const Icon(LucideIcons.moreHorizontal, color: AppColors.grey500),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.post.mood != null)
                  // 当前心��标签（紫色系）
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: AppRadius.allSM,
                    ),
                    child: Text("Current Mood: ${widget.post.mood}", 
                      style: TextStyle(color: Colors.purple.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                Text(widget.post.content, style: const TextStyle(fontSize: 15, height: 1.4)),
              ],
            ),
          ),
          
          const SizedBox(height: 12),

          if (widget.post.imageUrl != null)
            SizedBox(
              height: 320,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: widget.post.imageUrl!,
                fit: BoxFit.cover,
                // 性能优化：限制内存缓存大小，减少内存占用
                memCacheWidth: 800,
                memCacheHeight: 800,
                // 加载状态优化（v2.5）
                placeholder: (context, url) => Container(
                  color: AppColors.grey100,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.grey500,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.grey200,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.image,
                        size: 48,
                        color: AppColors.grey500,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: AppColors.grey500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                maxWidthDiskCache: 1000,
                maxHeightDiskCache: 1000,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // 点赞（Treats）按钮：本地切换状态并计数，带动画效果
                    ScaleTransition(
                      scale: _likeScaleAnimation,
                      child: _ActionButton(
                        icon: LucideIcons.bone,
                        label: "$likes Treats",
                        isActive: hasLiked,
                        activeColor: Colors.orange,
                        onTap: _toggleLike,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _ActionButton(
                      icon: LucideIcons.messageCircle,
                      label: "${widget.post.comments} Barks",
                      onTap: () {
                        // 打开评论底部弹窗
                        showCommentsBottomSheet(
                          context: context,
                          post: widget.post,
                          onCommentAdded: () {
                            // 评论数增加（使用 copyWith 因为 comments 是 final）
                            // 注意：这只是 UI 层的临时更新
                            // 在真实的 Firebase 环境中，应使用 FieldValue.increment()
                            // setState(() {
                            //   widget.post = widget.post.copyWith(
                            //     comments: widget.post.comments + 1,
                            //   );
                            // });
                            // TODO: 实现 Firestore FieldValue.increment() 更新
                          },
                        );
                      },
                    ),
                  ],
                ),
                const Icon(LucideIcons.share2, color: AppColors.grey500),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// 底部操作按钮（私有）：图标 + 标签 + 点击反馈
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color activeColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.activeColor = Colors.blue,
  });

  @override
  /// 使用圆形背景与小字体标签的紧凑操作按钮
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? activeColor.withValues(alpha:0.1) : AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: isActive ? activeColor : AppColors.grey500),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}