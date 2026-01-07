/*
  文件：widgets/common/chat_bubble.dart
  说明：
  - 聊天气泡组件
  - 用于 AI 助手对话界面
  - 支持用户消息和 AI 回复两种样式

  使用示例：
  ```dart
  // 用户消息气泡
  ChatBubble.user(
    message: 'How can I help my dog lose weight?',
  )

  // AI 回复气泡
  ChatBubble.assistant(
    message: 'Regular exercise and portion control are key...',
  )

  // 自定义头像
  ChatBubble.user(
    message: 'Hello!',
    avatarEmoji: '👤',
  )

  ChatBubble.assistant(
    message: 'Hi there!',
    avatarEmoji: '🩺',
  )

  // 加载状态
  ChatBubble.assistant(
    message: '',
    isLoading: true,
  )

  // 完整对话示例
  ListView(
    children: [
      ChatBubble.user(message: 'What should I feed my puppy?'),
      ChatBubble.assistant(
        message: 'High-quality puppy food with proper nutrients...',
      ),
      ChatBubble.user(message: 'How often should I feed them?'),
      ChatBubble.assistant(
        message: '',
        isLoading: true,
      ),
    ],
  )
  ```

  替换位置：
  - 未来用于 AI 兽医聊天界面
  - explore_screen.dart - Bark Translator 结果显示
  - 可扩展用于任何对话式 UI
*/

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 聊天消息类型
enum ChatMessageType {
  /// 用户消息
  user,

  /// AI 助手消息
  assistant,
}

/// 聊天气泡组件
///
/// 用于显示对话界面中的消息
///
/// 特点：
/// - 支持用户和 AI 两种消息样式
/// - 自动布局对齐（用户消息右对齐，AI 左对齐）
/// - 可选头像显示
/// - 支持加载状态（显示输入动画）
/// - 自适应宽度（最大 80% 屏幕宽度）
class ChatBubble extends StatelessWidget {
  /// 消息内容
  final String message;

  /// 消息类型
  final ChatMessageType type;

  /// 是否显示加载状态（仅 AI 消息有效）
  final bool isLoading;

  /// 头像 emoji（可选，默认根据类型自动选择）
  final String? avatarEmoji;

  /// 是否显示头像（默认 true）
  final bool showAvatar;

  /// 时间戳文字（可选）
  final String? timestamp;

  const ChatBubble._({
    super.key,
    required this.message,
    required this.type,
    this.isLoading = false,
    this.avatarEmoji,
    this.showAvatar = true,
    this.timestamp,
  });

  // ========================================
  // 命名构造函数：不同消息类型
  // ========================================

  /// 用户消息气泡
  ///
  /// 样式：
  /// - 橙色背景
  /// - 白色文字
  /// - 右对齐
  /// - 默认头像 🧑
  ///
  /// 参数：
  /// - message: 消息内容（必填）
  /// - avatarEmoji: 自定义头像（可选）
  /// - showAvatar: 是否显示头像（默认 true）
  /// - timestamp: 时间戳（可选）
  const ChatBubble.user({
    Key? key,
    required String message,
    String? avatarEmoji,
    bool showAvatar = true,
    String? timestamp,
  }) : this._(
          key: key,
          message: message,
          type: ChatMessageType.user,
          avatarEmoji: avatarEmoji,
          showAvatar: showAvatar,
          timestamp: timestamp,
        );

  /// AI 助手消息气泡
  ///
  /// 样式：
  /// - 浅灰色背景
  /// - 深色文字
  /// - 左对齐
  /// - 默认头像 🤖
  ///
  /// 参数：
  /// - message: 消息内容（加载时可为空字符串）
  /// - isLoading: 是否显示加载状态（默认 false）
  /// - avatarEmoji: 自定义头像（可选）
  /// - showAvatar: 是否显示头像（默认 true）
  /// - timestamp: 时间戳（可选）
  const ChatBubble.assistant({
    Key? key,
    required String message,
    bool isLoading = false,
    String? avatarEmoji,
    bool showAvatar = true,
    String? timestamp,
  }) : this._(
          key: key,
          message: message,
          type: ChatMessageType.assistant,
          isLoading: isLoading,
          avatarEmoji: avatarEmoji,
          showAvatar: showAvatar,
          timestamp: timestamp,
        );

  @override
  Widget build(BuildContext context) {
    final isUser = type == ChatMessageType.user;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceL,
        vertical: AppTheme.spaceS,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 消息：头像在左侧
          if (!isUser && showAvatar) _buildAvatar(),
          if (!isUser && showAvatar) const SizedBox(width: AppTheme.spaceS),

          // 消息气泡
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(),
                // 时间戳
                if (timestamp != null) ...[
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(
                    timestamp!,
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeXS,
                      color: AppTheme.grey500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 用户消息：头像在右侧
          if (isUser && showAvatar) const SizedBox(width: AppTheme.spaceS),
          if (isUser && showAvatar) _buildAvatar(),
        ],
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    final defaultEmoji = type == ChatMessageType.user ? '🧑' : '🤖';
    final emoji = avatarEmoji ?? defaultEmoji;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: type == ChatMessageType.user
            ? AppTheme.primaryOrange.withValues(alpha: 0.1)
            : AppTheme.grey100,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  /// 构建消息气泡
  Widget _buildMessageBubble() {
    final isUser = type == ChatMessageType.user;

    // 颜色配置
    final backgroundColor = isUser ? AppTheme.primaryOrange : AppTheme.grey100;
    final textColor = isUser ? Colors.white : AppTheme.grey800;

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 300, // 约 75% 的手机屏幕宽度
        minWidth: 60,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceM,
        vertical: AppTheme.spaceS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isUser ? AppTheme.radiusL : AppTheme.radiusS),
          topRight: Radius.circular(isUser ? AppTheme.radiusS : AppTheme.radiusL),
          bottomLeft: const Radius.circular(AppTheme.radiusL),
          bottomRight: const Radius.circular(AppTheme.radiusL),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isLoading ? _buildLoadingIndicator(textColor) : _buildMessageText(textColor),
    );
  }

  /// 构建消息文本
  Widget _buildMessageText(Color textColor) {
    return Text(
      message,
      style: TextStyle(
        color: textColor,
        fontSize: AppTheme.fontSizeM,
        height: 1.4,
      ),
    );
  }

  /// 构建加载指示器（输入动画）
  Widget _buildLoadingIndicator(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TypingDot(color: color, delay: 0),
        const SizedBox(width: 4),
        _TypingDot(color: color, delay: 150),
        const SizedBox(width: 4),
        _TypingDot(color: color, delay: 300),
      ],
    );
  }
}

/// 输入动画圆点组件
///
/// 用于显示 AI 正在输入的动画效果
class _TypingDot extends StatefulWidget {
  final Color color;
  final int delay; // 延迟毫秒数

  const _TypingDot({
    required this.color,
    required this.delay,
  });

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 延迟启动动画
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
