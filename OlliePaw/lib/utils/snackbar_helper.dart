/*
  文件：utils/snackbar_helper.dart
  说明：
  - 统一的 SnackBar 提示工具类
  - 提供一致的成功、错误、信息提示样式
  - 支持操作按钮和副标题

  用途：
  - 简化 SnackBar 调用代码
  - 统一提示样式
  - 便于全局修改提示风格

  更新于：v2.7 - UI/UX 优化
  - 添加图标和副标题支持
  - 使用 AppColors 确保一致性
  - 添加操作按钮支持

  v3.0 更新 - 温暖UI设计：
  - 使用更柔和的圆角（24px）
*/

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_dimensions.dart';

/// SnackBar 辅助工具类
///
/// 提供统一的提示样式和行为
class SnackBarHelper {
  // 防止实例化
  SnackBarHelper._();

  /// 显示成功消息
  ///
  /// [message] 主要消息文本
  /// [subtitle] 可选的副标题
  /// [duration] 显示时长，默认 2 秒
  static void showSuccess(
    BuildContext context,
    String message, {
    String? subtitle,
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message: message,
      subtitle: subtitle,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  /// 显示错误消息
  ///
  /// [message] 主要消息文本
  /// [subtitle] 可选的副标题（如错误详情）
  /// [action] 可选的操作按钮（如重试、查看详情）
  /// [duration] 显示时长，默认 3 秒
  static void showError(
    BuildContext context,
    String message, {
    String? subtitle,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      subtitle: subtitle,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
      action: action,
      duration: duration,
    );
  }

  /// 显示信息消息
  ///
  /// [message] 主要消息文本
  /// [subtitle] 可选的副标题
  /// [duration] 显示时长，默认 2 秒
  static void showInfo(
    BuildContext context,
    String message, {
    String? subtitle,
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message: message,
      subtitle: subtitle,
      backgroundColor: AppColors.primaryOrange,
      icon: Icons.info_outline,
      duration: duration,
    );
  }

  /// 显示警告消息
  ///
  /// [message] 主要消息文本
  /// [subtitle] 可选的副标题
  /// [duration] 显示时长，默认 3 秒
  static void showWarning(
    BuildContext context,
    String message, {
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      subtitle: subtitle,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_outlined,
      duration: duration,
    );
  }

  /// 显示普通提示（默认样式）
  ///
  /// [message] 提示消息
  /// [duration] 显示时长，默认 2 秒
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.grey700,
      icon: Icons.notifications_outlined,
      duration: duration,
    );
  }

  /// 内部方法：显示 SnackBar
  static void _show(
    BuildContext context, {
    required String message,
    String? subtitle,
    required Color backgroundColor,
    required IconData icon,
    SnackBarAction? action,
    required Duration duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        action: action,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.allMD, // v3.0: 更柔和的圆角
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
