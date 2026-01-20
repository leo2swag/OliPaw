/*
  文件：widgets/broadcast/broadcast_ticker.dart
  说明：
  - 社区广播滚动条（Ticker/Marquee）
  - 显示附近 5km 内的最新广播
  - 水平滚动展示

  功能：
  - 自动滚动显示多条广播
  - 按类型颜色编码
  - 点击查看详情
  - 最多显示 5 条最新广播

  使用示例：
  ```dart
  // 在 Home Screen 顶部添加
  BroadcastTicker(
    onBroadcastTap: (broadcast) {
      // 导航到详情页
    },
  )
  ```
*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimensions.dart';
import '../../models/sos_types.dart';
import '../../providers/broadcast_provider.dart';

/// 广播滚动条组件
class BroadcastTicker extends StatefulWidget {
  /// 广播点击回调
  final Function(CommunityBroadcast)? onBroadcastTap;

  /// 查询半径（公里）
  final double radiusKm;

  /// 最大显示数量
  final int maxCount;

  const BroadcastTicker({
    super.key,
    this.onBroadcastTap,
    this.radiusKm = 5.0,
    this.maxCount = 5,
  });

  @override
  State<BroadcastTicker> createState() => _BroadcastTickerState();
}

class _BroadcastTickerState extends State<BroadcastTicker> {
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    // 延迟启动自动滚动，给用户时间看第一条
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _startAutoScroll();
      }
    });

    // 刷新附近广播
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BroadcastProvider>().refreshNearbyBroadcasts(
            radiusKm: widget.radiusKm,
          );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  /// 启动自动滚动
  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isHovering && _scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        final nextScroll = currentScroll + 200; // 每次滚动 200px

        if (nextScroll >= maxScroll) {
          // 滚动到头了，回到开始
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _scrollController.animateTo(
            nextScroll,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  /// 停止自动滚动（用户触摸时）
  void _stopAutoScroll() {
    setState(() => _isHovering = true);
    _autoScrollTimer?.cancel();
  }

  /// 恢复自动滚动
  void _resumeAutoScroll() {
    setState(() => _isHovering = false);
    _startAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    final broadcastProvider = context.watch<BroadcastProvider>();
    final broadcasts = broadcastProvider.getRecentBroadcasts(
      limit: widget.maxCount,
      radiusKm: widget.radiusKm,
    );

    // 如果没有广播，返回空容器
    if (broadcasts.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTapDown: (_) => _stopAutoScroll(),
      onTapUp: (_) => _resumeAutoScroll(),
      onTapCancel: _resumeAutoScroll,
      child: Container(
        height: AppSizes.inputHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: AppSpacing.sm,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.horizontalLG,
          itemCount: broadcasts.length,
          separatorBuilder: (context, index) => Container(
            width: AppSizes.dividerThickness,
            height: AppSpacing.xxl,
            margin: AppSpacing.horizontalLG,
            color: AppColors.grey200,
          ),
          itemBuilder: (context, index) {
            final broadcast = broadcasts[index];
            return _buildBroadcastItem(broadcast);
          },
        ),
      ),
    );
  }

  /// 构建单条广播项
  Widget _buildBroadcastItem(CommunityBroadcast broadcast) {
    final color = _getBroadcastColor(broadcast.type);
    final icon = broadcast.typeIcon;

    return InkWell(
      onTap: () => widget.onBroadcastTap?.call(broadcast),
      child: Container(
        padding: AppSpacing.horizontalMD,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 类型图标
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: AppSpacing.sm),

            // 标题
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                broadcast.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // 内容预览
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                broadcast.content,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取广播类型对应的颜色
  Color _getBroadcastColor(BroadcastType type) {
    switch (type) {
      case BroadcastType.sos:
      case BroadcastType.danger:
        return AppColors.error;
      case BroadcastType.social:
        return AppColors.success;
      case BroadcastType.marketplace:
        return AppColors.warning;
    }
  }
}

/// 紧凑版广播卡片（用于列表显示）
class BroadcastCard extends StatelessWidget {
  final CommunityBroadcast broadcast;
  final VoidCallback? onTap;

  const BroadcastCard({
    super.key,
    required this.broadcast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getBroadcastColor(broadcast.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.allLG,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: AppColors.lightShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部
            Row(
              children: [
                // 类型图标
                Container(
                  padding: AppSpacing.allSM,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    broadcast.typeIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // 类型和标题
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        broadcast.typeName,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        broadcast.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 内容
            Text(
              broadcast.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMedium,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),

            // 底部信息
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: AppSizes.iconXS,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    broadcast.location.addressName ?? broadcast.location.city,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatRelativeTime(broadcast.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),

            // 互动数据
            if (broadcast.likeCount > 0 || broadcast.responseCount > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (broadcast.likeCount > 0) ...[
                    const Icon(
                      Icons.favorite,
                      size: AppSizes.iconXS,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${broadcast.likeCount}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                  ],
                  if (broadcast.responseCount > 0) ...[
                    const Icon(
                      Icons.comment,
                      size: AppSizes.iconXS,
                      color: AppColors.primaryOrange,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${broadcast.responseCount}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBroadcastColor(BroadcastType type) {
    switch (type) {
      case BroadcastType.sos:
      case BroadcastType.danger:
        return AppColors.error;
      case BroadcastType.social:
        return AppColors.success;
      case BroadcastType.marketplace:
        return AppColors.warning;
    }
  }

  String _formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return AppStrings.justNow;
    } else if (difference.inMinutes < 60) {
      return AppStrings.timeAgo(difference.inMinutes, AppStrings.minutesAgo);
    } else if (difference.inHours < 24) {
      return AppStrings.timeAgo(difference.inHours, AppStrings.hoursAgo);
    } else {
      return AppStrings.timeAgo(difference.inDays, AppStrings.daysAgo);
    }
  }
}
