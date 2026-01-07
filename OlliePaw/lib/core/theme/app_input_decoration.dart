/*
  文件：core/theme/app_input_decoration.dart
  说明：
  - 统一的输入框装饰样式
  - 提供多种预设装饰工厂方法
  - 消除重复的 InputDecoration 代码

  用途：
  - 替代所有重复的 InputDecoration 配置
  - 确保整个应用的输入框样式一致
  - 便于全局修改输入框样式

  使用示例：
  ```dart
  // 标准输入框
  TextFormField(
    decoration: AppInputDecoration.standard(
      labelText: 'Email',
      hintText: 'Enter your email',
      prefixIcon: Icons.email_outlined,
    ),
  )

  // 多行文本输入
  TextFormField(
    maxLines: 3,
    decoration: AppInputDecoration.textArea(
      labelText: 'Bio',
      hintText: 'Tell us about yourself',
    ),
  )
  ```
*/

import 'package:flutter/material.dart';

/// 应用输入框装饰样式
///
/// 提供统一的 InputDecoration 配置，确保整个应用的输入框样式一致
class AppInputDecoration {
  AppInputDecoration._(); // 防止实例化

  // ==================== 样式常量 ====================

  /// 边框圆角半径
  static const double borderRadius = 12.0;

  /// 填充颜色
  static final Color fillColor = Colors.grey.shade50;

  /// 边框颜色
  static final Color borderColor = Colors.grey.shade300;

  /// 聚焦边框颜色
  static const Color focusedBorderColor = Color(0xFFFB923C); // 橙色

  /// 错误边框颜色
  static const Color errorBorderColor = Colors.red;

  // ==================== 工厂方法 ====================

  /// 标准输入框装饰
  ///
  /// 使用场景：大部分文本输入场景
  ///
  /// 参数：
  /// - labelText: 标签文字（显示在输入框上方）
  /// - hintText: 提示文字（输入框为空时显示）
  /// - prefixIcon: 前缀图标
  /// - suffixIcon: 后缀图标（如密码可见性切换）
  static InputDecoration standard({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: focusedBorderColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorBorderColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorBorderColor, width: 2),
      ),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  /// 多行文本输入装饰
  ///
  /// 使用场景：简介、评论等多行文本输入
  ///
  /// 与 standard 的区别：
  /// - 移除了 prefixIcon（多行输入不适合图标）
  /// - 调整了 contentPadding 以适应多行文本
  static InputDecoration textArea({
    required String labelText,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: focusedBorderColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorBorderColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorBorderColor, width: 2),
      ),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      alignLabelWithHint: true, // 标签对齐多行文本顶部
    );
  }

  /// 紧凑型输入框装饰
  ///
  /// 使用场景：对话框、底部抽屉等空间受限的场景
  ///
  /// 与 standard 的区别：
  /// - 减小了 contentPadding
  /// - 适合小型表单
  static InputDecoration compact({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: focusedBorderColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorBorderColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorBorderColor, width: 2),
      ),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true, // 更紧凑的布局
    );
  }
}
