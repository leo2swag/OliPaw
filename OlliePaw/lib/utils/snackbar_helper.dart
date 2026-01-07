/*
  文件：utils/snackbar_helper.dart
  说明：
  - SnackBar 通知工具类
  - 统一管理应用中的所有提示消息
  - 提供成功、错误、信息等不同类型的提示

  用途：
  - 简化 SnackBar 调用代码
  - 统一提示样式
  - 便于全局修改提示风格
*/

import 'package:flutter/material.dart';

/// SnackBar 通知工具类
///
/// 提供简洁的 API 来显示各种类型的提示消息
class SnackBarHelper {
  SnackBarHelper._(); // 防止实例化

  /// 显示成功提示
  ///
  /// 参数：
  /// - context: BuildContext
  /// - message: 提示消息
  /// - duration: 显示时长（默认 2 秒）
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 显示错误提示
  ///
  /// 参数：
  /// - context: BuildContext
  /// - message: 错误消息
  /// - duration: 显示时长（默认 3 秒）
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 显示信息提示
  ///
  /// 参数：
  /// - context: BuildContext
  /// - message: 信息消息
  /// - duration: 显示时长（默认 2 秒）
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 显示警告提示
  ///
  /// 参数：
  /// - context: BuildContext
  /// - message: 警告消息
  /// - duration: 显示时长（默认 2 秒）
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 显示普通提示（默认样式）
  ///
  /// 参数：
  /// - context: BuildContext
  /// - message: 提示消息
  /// - duration: 显示时长（默认 2 秒）
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
