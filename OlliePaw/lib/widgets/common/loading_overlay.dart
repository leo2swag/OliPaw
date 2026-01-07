/*
  文件：widgets/common/loading_overlay.dart
  说明：
  - 统一的加载遮罩组件
  - 用于显示异步操作的加载状态
  - 支持自定义消息和副标题

  使用示例：
  ```dart
  // 方式 1: 使用静态方法自动显示/关闭
  final result = await LoadingOverlay.show(
    context: context,
    message: 'Generating caption...',
    subtitle: 'This may take a few seconds',
    task: () => aiService.generateCaption(pet, activity),
  );

  // 方式 2: 手动控制
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => LoadingOverlay(
      message: 'Uploading image...',
      subtitle: 'Please wait',
    ),
  );
  // ... 执行异步操作
  Navigator.pop(context);
  ```

  替换位置：
  - explore_screen.dart - AI 功能加载
  - create_post_screen.dart - AI 文案生成
  - 所有使用 CircularProgressIndicator 对话框的地方
*/

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 加载遮罩组件
///
/// 显示带消息的加载指示器，阻止用户交互
class LoadingOverlay extends StatelessWidget {
  /// 主要消息文本
  final String message;

  /// 副标题（可选，通常用于提示预计时间）
  final String? subtitle;

  /// 是否显示进度指示器（默认 true）
  final bool showProgress;

  /// 自定义图标（可选，替代 CircularProgressIndicator）
  final Widget? customIcon;

  const LoadingOverlay({
    super.key,
    required this.message,
    this.subtitle,
    this.showProgress = true,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(AppTheme.space2XL),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.space2XL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 进度指示器或自定义图标
                if (customIcon != null)
                  customIcon!
                else if (showProgress)
                  const CircularProgressIndicator(),

                const SizedBox(height: AppTheme.spaceL),

                // 主消息
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeL,
                    fontWeight: AppTheme.fontWeightBold,
                  ),
                  textAlign: TextAlign.center,
                ),

                // 副标题
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.spaceS),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeS,
                      color: AppTheme.grey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // 静态辅助方法
  // ==========================================================================

  /// 显示加载遮罩并执行异步任务
  ///
  /// 参数：
  /// - context: 构建上下文
  /// - message: 加载消息
  /// - subtitle: 副标题（可选）
  /// - task: 要执行的异步任务
  ///
  /// 返回值：任务的返回值
  ///
  /// 特性：
  /// - 自动显示加载遮罩
  /// - 任务完成后自动关闭
  /// - 任务失败时也会关闭
  ///
  /// 示例：
  /// ```dart
  /// final caption = await LoadingOverlay.show(
  ///   context: context,
  ///   message: 'Generating caption...',
  ///   task: () => aiService.generateCaption(),
  /// );
  /// ```
  static Future<T?> show<T>({
    required BuildContext context,
    required Future<T> Function() task,
    required String message,
    String? subtitle,
  }) async {
    // 显示加载遮罩
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingOverlay(
        message: message,
        subtitle: subtitle,
      ),
    );

    try {
      // 执行任务
      final result = await task();

      // 关闭加载遮罩
      if (context.mounted) {
        Navigator.pop(context);
      }

      return result;
    } catch (e) {
      // 出错也要关闭加载遮罩
      if (context.mounted) {
        Navigator.pop(context);
      }
      rethrow; // 重新抛出异常，让调用者处理
    }
  }

  /// 显示带取消按钮的加载遮罩
  ///
  /// 参数：
  /// - context: 构建上下文
  /// - message: 加载消息
  /// - subtitle: 副标题（可选）
  /// - onCancel: 取消回调
  ///
  /// 用途：长时间运行的任务，允许用户取消
  static void showCancellable({
    required BuildContext context,
    required String message,
    String? subtitle,
    required VoidCallback onCancel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Container(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(AppTheme.space2XL),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.space2XL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppTheme.spaceL),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeL,
                      fontWeight: AppTheme.fontWeightBold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppTheme.spaceS),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeS,
                        color: AppTheme.grey600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppTheme.spaceL),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      onCancel();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
