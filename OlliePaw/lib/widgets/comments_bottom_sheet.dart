/*
  文件：widgets/comments_bottom_sheet.dart
  说明：
  - 评论系统底部弹窗组件
  - 功能：
    1) 显示帖子的所有评论列表
    2) 支持发表新评论
    3) 支持点赞评论
    4) 显示评论时间和作者信息
  - 使用方式：通过 showModalBottomSheet 调用
  注意：当前使用模拟数据，待后端集成后替换为真实 API 调用
*/

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_dimensions.dart';
import '../models/types.dart';
import '../utils/snackbar_helper.dart';

/// 评论底部弹窗
///
/// 使用示例：
/// ```dart
/// showCommentsBottomSheet(
///   context: context,
///   post: post,
///   onCommentAdded: () {
///     // 更新评论数
///   },
/// );
/// ```
void showCommentsBottomSheet({
  required BuildContext context,
  required Post post,
  VoidCallback? onCommentAdded,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 允许全屏高度
    backgroundColor: Colors.transparent,
    builder: (context) => CommentsBottomSheet(
      post: post,
      onCommentAdded: onCommentAdded,
    ),
  );
}

/// 评论底部弹窗主组件
class CommentsBottomSheet extends StatefulWidget {
  final Post post;
  final VoidCallback? onCommentAdded;

  const CommentsBottomSheet({
    super.key,
    required this.post,
    this.onCommentAdded,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  // 文本输入控制器
  final TextEditingController _commentController = TextEditingController();
  // 焦点控制器（用于键盘管理）
  final FocusNode _focusNode = FocusNode();

  // 模拟评论数据列表
  late List<Comment> _comments;
  // 是否正在发送评论
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // 初始化模拟评论数据
    _loadMockComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 加载模拟评论数据
  /// 说明：在实际应用中，这里应该从后端 API 获取评论
  void _loadMockComments() {
    _comments = [
      Comment(
        id: 'c1',
        authorId: 'p3',
        authorName: 'Mochi the Cat',
        authorAvatar: 'https://picsum.photos/id/40/100/100',
        content: 'This is SO relatable! 😹',
        timestamp: '5m ago',
        likes: 12,
      ),
      Comment(
        id: 'c2',
        authorId: 'p4',
        authorName: 'Charlie',
        authorAvatar: 'https://picsum.photos/id/200/100/100',
        content: 'You\'re my hero! 🦸‍♂️',
        timestamp: '15m ago',
        likes: 8,
      ),
      Comment(
        id: 'c3',
        authorId: 'p1',
        authorName: 'Barnaby',
        authorAvatar: 'https://picsum.photos/id/1025/100/100',
        content: 'Living your best life! Keep it up! 🎉',
        timestamp: '1h ago',
        likes: 23,
      ),
    ];
  }

  /// 发送新评论
  /// 说明：
  /// - 验证输入不为空
  /// - 模拟网络延迟
  /// - 添加到评论列表
  /// - 清空输入框并收起键盘
  Future<void> _sendComment() async {
    final text = _commentController.text.trim();

    // 验证评论内容
    if (text.isEmpty) {
      SnackBarHelper.showWarning(context, AppStrings.fieldRequired);
      return;
    }

    setState(() => _isSending = true);

    // 模拟网络请求延迟（实际应用中调用 API）
    await Future.delayed(const Duration(milliseconds: 800));

    // 创建新评论对象
    final newComment = Comment(
      id: 'c${_comments.length + 1}',
      authorId: 'current_user',
      authorName: 'Barnaby', // 使用当前用户名
      authorAvatar: 'https://picsum.photos/id/1025/100/100',
      content: text,
      timestamp: 'Just now',
      likes: 0,
    );

    setState(() {
      // 将新评论插入列表顶部
      _comments.insert(0, newComment);
      _isSending = false;
      _commentController.clear();
    });

    // 收起键盘
    _focusNode.unfocus();

    // 显示成功提示
    if (mounted) {
      SnackBarHelper.showSuccess(
        context,
        AppStrings.commentAdded,
        duration: const Duration(seconds: 1),
      );

      // 通知外部评论数已增加
      widget.onCommentAdded?.call();
    }
  }

  /// 切换评论点赞状态
  void _toggleCommentLike(int index) {
    setState(() {
      final comment = _comments[index];
      comment.hasLiked = !comment.hasLiked;
      comment.likes += comment.hasLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7, // 初始高度占屏幕 70%
      minChildSize: 0.5,     // 最小高度 50%
      maxChildSize: 0.95,    // 最大高度 95%
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
        ),
        child: Column(
          children: [
            // 顶部拖拽指示条和标题
            _buildHeader(),

            const Divider(height: 1),

            // 评论列表区域（可滚动）
            Expanded(
              child: _comments.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: scrollController,
                      padding: AppSpacing.verticalLG,
                      itemCount: _comments.length,
                      itemBuilder: (context, index) => _buildCommentItem(index),
                    ),
            ),

            const Divider(height: 1),

            // 底部输入框
            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  /// 构建顶部标题栏
  /// 说明：包含拖拽指示条、评论数量显示、关闭按钮
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Column(
        children: [
          // 拖拽指示条
          Container(
            width: AppSizes.avatarLG,
            height: AppSpacing.xs,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(AppSpacing.xxs),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_comments.length} Barks',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.grey100,
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建空状态视图
  /// 说明：当没有评论时显示
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.messageCircle,
            size: AppSizes.iconXXXL,
            color: AppColors.grey300,
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            AppStrings.noComments,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.noCommentsDesc,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单条评论项
  /// 说明：
  /// - 显示作者头像、名字
  /// - 评论内容
  /// - 时间戳
  /// - 点赞按钮
  Widget _buildCommentItem(int index) {
    final comment = _comments[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 作者头像
          CircleAvatar(
            radius: AppSpacing.xl,
            backgroundImage: NetworkImage(comment.authorAvatar),
          ),
          const SizedBox(width: AppSpacing.md),

          // 评论内容区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 作者名和时间
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      comment.timestamp,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // 评论文本
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // 点赞按钮
                GestureDetector(
                  onTap: () => _toggleCommentLike(index),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        comment.hasLiked
                            ? LucideIcons.heart
                            : LucideIcons.heart,
                        size: AppSizes.iconSM,
                        color: comment.hasLiked
                            ? AppColors.error
                            : AppColors.textMedium,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${comment.likes}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: comment.hasLiked
                              ? AppColors.error
                              : AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部评论输入框
  /// 说明：
  /// - 文本输入框
  /// - 发送按钮（带加载状态）
  /// - 固定在底部，不随键盘滚动
  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 输入框
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.lightOrangeBg,
                borderRadius: AppRadius.allXXL,
              ),
              child: TextField(
                controller: _commentController,
                focusNode: _focusNode,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendComment(),
                decoration: const InputDecoration(
                  hintText: AppStrings.commentPlaceholder,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // 发送按钮
          GestureDetector(
            onTap: _isSending ? null : _sendComment,
            child: Container(
              width: AppSizes.buttonHeightMD,
              height: AppSizes.buttonHeightMD,
              decoration: BoxDecoration(
                gradient: _isSending
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.primaryOrange, AppColors.warning],
                      ),
                color: _isSending ? AppColors.grey300 : null,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const Padding(
                      padding: AppSpacing.allMD,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.white),
                      ),
                    )
                  : const Icon(
                      LucideIcons.send,
                      color: AppColors.white,
                      size: AppSizes.iconMD,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
