/*
  文件：widgets/common/app_dialog.dart
  说明：
  - 统一的对话框包装组件
  - 标准化对话框样式和布局
  - 支持自定义图标、标题、内容和操作按钮

  使用示例：
  ```dart
  // 基本用法
  showDialog(
    context: context,
    builder: (context) => AppDialog(
      icon: LucideIcons.syringe,
      iconColor: Colors.teal,
      title: '添加疫苗记录',
      content: Form(
        child: Column(children: [...]),
      ),
      actions: [
        AppDialog.cancelButton(context),
        AppDialog.confirmButton(
          context,
          onPressed: _saveVaccine,
          label: '保存',
        ),
      ],
    ),
  )

  // 带滚动内容
  AppDialog(
    icon: LucideIcons.scale,
    iconColor: Colors.blue,
    title: '添加体重记录',
    scrollable: true,
    content: Column(children: [...]),
    actions: [...],
  )

  // 自定义宽度
  AppDialog(
    icon: LucideIcons.info,
    title: '提示',
    maxWidth: 500,
    content: Text('这是一个提示信息'),
    actions: [...],
  )
  ```

  替换位置：
  - add_vaccine_dialog.dart - Dialog 包装 (lines 164-301)
  - add_weight_dialog.dart - Dialog 包装 (lines 170-428)
*/

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 统一的对话框组件
///
/// 提供标准化的对话框样式和布局
///
/// 特点：
/// - 统一的圆角和阴影
/// - 标准化的标题布局（图标 + 文字）
/// - 可选的滚动内容区域
/// - 灵活的操作按钮配置
/// - 响应式最大宽度限制
class AppDialog extends StatelessWidget {
  /// 标题图标
  final IconData icon;

  /// 图标颜色（同时用于图标背景）
  final Color iconColor;

  /// 对话框标题
  final String title;

  /// 对话框内容部分
  final Widget content;

  /// 底部操作按钮列表
  final List<Widget>? actions;

  /// 是否启用内容区域滚动（默认 false）
  final bool scrollable;

  /// 对话框最大宽度（默认 400px）
  final double maxWidth;

  /// 内容区域顶部间距（默认 24px）
  final double contentTopPadding;

  /// 操作按钮区域顶部间距（默认 24px）
  final double actionsTopPadding;

  const AppDialog({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    this.actions,
    this.scrollable = false,
    this.maxWidth = 400,
    this.contentTopPadding = 24,
    this.actionsTopPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius2XL),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.all(AppTheme.space2XL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题区域（图标 + 标题文字）
            _buildHeader(),

            // 内容区域
            SizedBox(height: contentTopPadding),
            if (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  child: content,
                ),
              )
            else
              content,

            // 操作按钮区域
            if (actions != null && actions!.isNotEmpty) ...[
              SizedBox(height: actionsTopPadding),
              _buildActions(),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建标题区域
  ///
  /// 布局：[图标容器] + 间距 + [标题文字]
  Widget _buildHeader() {
    return Row(
      children: [
        // 图标容器
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: AppTheme.spaceM),
        // 标题文字
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeXL,
              fontWeight: AppTheme.fontWeightBlack,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建操作按钮区域
  ///
  /// 布局：居右对齐的按钮行
  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions!
          .map((action) => Padding(
                padding: const EdgeInsets.only(left: AppTheme.spaceS),
                child: action,
              ))
          .toList(),
    );
  }

  // ========================================
  // 静态工厂方法：常用按钮样式
  // ========================================

  /// 创建取消按钮
  ///
  /// 参数：
  /// - context: 构建上下文
  /// - label: 按钮文字（默认"取消"）
  /// - onPressed: 自定义回调（默认关闭对话框）
  ///
  /// 返回：灰色边框按钮
  static Widget cancelButton(
    BuildContext context, {
    String label = '取消',
    VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppTheme.grey300, width: 1.5),
        foregroundColor: AppTheme.grey700,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceL,
          vertical: AppTheme.spaceM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: AppTheme.fontWeightBold,
          fontSize: AppTheme.fontSizeM,
        ),
      ),
    );
  }

  /// 创建确认按钮
  ///
  /// 参数：
  /// - context: 构建上下文
  /// - onPressed: 点击回调（必填）
  /// - label: 按钮文字（默认"确认"）
  /// - color: 按钮颜色（默认主题橙色）
  ///
  /// 返回：实心彩色按钮
  static Widget confirmButton(
    BuildContext context, {
    required VoidCallback onPressed,
    String label = '确认',
    Color? color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppTheme.primaryOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceL,
          vertical: AppTheme.spaceM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: AppTheme.fontWeightBold,
          fontSize: AppTheme.fontSizeM,
        ),
      ),
    );
  }

  /// 创建删除按钮
  ///
  /// 参数：
  /// - context: 构建上下文
  /// - onPressed: 点击回调（必填）
  /// - label: 按钮文字（默认"删除"）
  ///
  /// 返回：红色实心按钮
  static Widget deleteButton(
    BuildContext context, {
    required VoidCallback onPressed,
    String label = '删除',
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceL,
          vertical: AppTheme.spaceM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: AppTheme.fontWeightBold,
          fontSize: AppTheme.fontSizeM,
        ),
      ),
    );
  }

  /// 创建文本按钮
  ///
  /// 参数：
  /// - context: 构建上下文
  /// - label: 按钮文字
  /// - onPressed: 点击回调（必填）
  /// - color: 文字颜色（默认主题橙色）
  ///
  /// 返回：纯文字按钮（无背景）
  static Widget textButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? AppTheme.primaryOrange,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceM,
          vertical: AppTheme.spaceS,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: AppTheme.fontWeightBold,
          fontSize: AppTheme.fontSizeM,
        ),
      ),
    );
  }
}
