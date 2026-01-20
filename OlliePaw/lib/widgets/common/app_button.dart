/*
  文件：widgets/common/app_button.dart
  说明：
  - 统一的按钮组件系统
  - 提供 Primary、Secondary、Outlined、Icon 等变体
  - 标准化按钮样式和尺寸
  - v3.0: 使用pill-shaped设计（完全圆角）营造温暖友好的感觉

  使用示例：
  ```dart
  // Primary 按钮（实心橙色）
  AppButton.primary(
    onPressed: _handleSubmit,
    label: 'Submit',
  )

  // Secondary 按钮（实心黑色）
  AppButton.secondary(
    onPressed: _handleLogin,
    label: 'Welcome Back',
  )

  // Outlined 按钮（边框按钮）
  AppButton.outlined(
    onPressed: _handleCancel,
    label: 'Cancel',
  )

  // 带图标的按钮
  AppButton.primary(
    onPressed: _handleAdd,
    label: 'Add Record',
    icon: LucideIcons.plus,
  )

  // 自定义颜色
  AppButton.primary(
    onPressed: _handleDelete,
    label: 'Delete',
    backgroundColor: Colors.red,
  )

  // 不同尺寸
  AppButton.primary(
    onPressed: _handleSubmit,
    label: 'Submit',
    size: AppButtonSize.large,
  )

  // Icon-only 按钮
  AppButton.icon(
    onPressed: _handleEdit,
    icon: LucideIcons.edit,
  )

  // 加载状态
  AppButton.primary(
    onPressed: _isLoading ? null : _handleSubmit,
    label: 'Submit',
    isLoading: _isLoading,
  )

  // 全宽按钮
  AppButton.primary(
    onPressed: _handleSubmit,
    label: 'Submit',
    fullWidth: true,
  )
  ```

  替换位置：
  - auth_screen.dart - Login/Register 按钮 (lines 173-180, 260-267)
  - create_post_screen.dart - Submit 按钮 (lines 162-167)
  - section_header.dart - Action 按钮 (lines 91-110)
*/

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/constants/app_colors.dart';

/// 按钮尺寸枚举
///
/// 定义三种标准按钮尺寸
enum AppButtonSize {
  /// 小尺寸：适用于紧凑空间
  small(
    horizontalPadding: 12.0,
    verticalPadding: 8.0,
    fontSize: AppTheme.fontSizeS,
    iconSize: 16.0,
  ),

  /// 中等尺寸：默认尺寸，最常用
  medium(
    horizontalPadding: 16.0,
    verticalPadding: 12.0,
    fontSize: AppTheme.fontSizeM,
    iconSize: 18.0,
  ),

  /// 大尺寸：适用于主要操作
  large(
    horizontalPadding: 24.0,
    verticalPadding: 16.0,
    fontSize: AppTheme.fontSizeL,
    iconSize: 20.0,
  );

  const AppButtonSize({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.fontSize,
    required this.iconSize,
  });

  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final double iconSize;
}

/// 统一的按钮组件
///
/// 提供多种按钮样式变体和尺寸配置
///
/// 特点：
/// - 多种预设样式（Primary、Secondary、Outlined、Icon）
/// - 三种标准尺寸（Small、Medium、Large）
/// - 支持图标 + 文字组合
/// - 支持加载状态
/// - 支持全宽布局
/// - 自动禁用状态样式
class AppButton extends StatelessWidget {
  /// 按钮文字（Icon-only 按钮可为空）
  final String? label;

  /// 按钮图标（可选）
  final IconData? icon;

  /// 点击回调（为 null 时按钮禁用）
  final VoidCallback? onPressed;

  /// 背景颜色
  final Color? backgroundColor;

  /// 前景颜色（文字和图标）
  final Color? foregroundColor;

  /// 边框颜色（仅 Outlined 样式使用）
  final Color? borderColor;

  /// 按钮尺寸
  final AppButtonSize size;

  /// 是否显示加载状态
  final bool isLoading;

  /// 是否全宽（占满父容器宽度）
  final bool fullWidth;

  /// 圆角半径（可选，默认使用 AppTheme.radiusL）
  final double? borderRadius;

  /// 是否为 Icon-only 按钮
  final bool iconOnly;

  const AppButton._({
    super.key,
    this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.fullWidth = false,
    this.borderRadius,
    this.iconOnly = false,
  });

  // ========================================
  // 命名构造函数：不同按钮样式
  // ========================================

  /// Primary 按钮（实心橙色）
  ///
  /// 用途：主要操作、提交、确认
  ///
  /// 参数：
  /// - label: 按钮文字（必填）
  /// - onPressed: 点击回调
  /// - icon: 可选图标
  /// - backgroundColor: 自定义背景色（默认橙色）
  /// - size: 按钮尺寸
  /// - isLoading: 是否显示加载状态
  /// - fullWidth: 是否全宽
  const AppButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    Color? backgroundColor,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
    double? borderRadius,
  }) : this._(
          key: key,
          label: label,
          icon: icon,
          onPressed: onPressed,
          backgroundColor: backgroundColor ?? AppTheme.primaryOrange,
          foregroundColor: AppColors.white,
          size: size,
          isLoading: isLoading,
          fullWidth: fullWidth,
          borderRadius: borderRadius,
        );

  /// Secondary 按钮（实心黑色）
  ///
  /// 用途：次要操作、深色背景上的按钮
  ///
  /// 参数：同 primary
  const AppButton.secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    Color? backgroundColor,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
    double? borderRadius,
  }) : this._(
          key: key,
          label: label,
          icon: icon,
          onPressed: onPressed,
          backgroundColor: backgroundColor ?? AppColors.black,
          foregroundColor: AppColors.white,
          size: size,
          isLoading: isLoading,
          fullWidth: fullWidth,
          borderRadius: borderRadius,
        );

  /// Outlined 按钮（边框按钮）
  ///
  /// 用途：取消、返回、次要操作
  ///
  /// 参数：
  /// - label: 按钮文字（必填）
  /// - onPressed: 点击回调
  /// - icon: 可选图标
  /// - borderColor: 边框颜色（默认灰色）
  /// - foregroundColor: 文字/图标颜色（默认灰色）
  /// - size: 按钮尺寸
  /// - isLoading: 是否显示加载状态
  /// - fullWidth: 是否全宽
  AppButton.outlined({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    Color? borderColor,
    Color? foregroundColor,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
    double? borderRadius,
  }) : this._(
          key: key,
          label: label,
          icon: icon,
          onPressed: onPressed,
          borderColor: borderColor ?? AppTheme.grey300,
          foregroundColor: foregroundColor ?? AppTheme.grey700,
          size: size,
          isLoading: isLoading,
          fullWidth: fullWidth,
          borderRadius: borderRadius,
        );

  /// Icon-only 按钮（图标按钮）
  ///
  /// 用途：工具栏、紧凑空间的操作按钮
  ///
  /// 参数：
  /// - icon: 图标（必填）
  /// - onPressed: 点击回调
  /// - backgroundColor: 背景颜色（默认透明）
  /// - foregroundColor: 图标颜色（默认灰色）
  /// - size: 按钮尺寸
  AppButton.icon({
    Key? key,
    required IconData icon,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    AppButtonSize size = AppButtonSize.medium,
    double? borderRadius,
  }) : this._(
          key: key,
          icon: icon,
          onPressed: onPressed,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor ?? AppTheme.grey700,
          size: size,
          iconOnly: true,
          borderRadius: borderRadius,
        );

  @override
  Widget build(BuildContext context) {
    // Icon-only 按钮使用 IconButton
    if (iconOnly) {
      return _buildIconButton();
    }

    // Outlined 按钮使用 OutlinedButton
    if (borderColor != null) {
      return _buildOutlinedButton();
    }

    // Primary/Secondary 使用 ElevatedButton
    return _buildElevatedButton();
  }

  /// 构建 Icon-only 按钮
  Widget _buildIconButton() {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: size.iconSize),
      color: foregroundColor,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppRadius.md, // v3.0: 更柔和的圆角
          ),
        ),
        padding: EdgeInsets.all(size.verticalPadding),
      ),
    );
  }

  /// 构建 Outlined 按钮
  Widget _buildOutlinedButton() {
    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor!, width: 1.5),
        foregroundColor: foregroundColor,
        padding: EdgeInsets.symmetric(
          horizontal: size.horizontalPadding,
          vertical: size.verticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppRadius.button, // v3.0: pill-shaped为温暖感
          ),
        ),
      ),
      child: _buildButtonContent(),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  /// 构建 Elevated 按钮（Primary/Secondary）
  Widget _buildElevatedButton() {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: EdgeInsets.symmetric(
          horizontal: size.horizontalPadding,
          vertical: size.verticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppRadius.button, // v3.0: pill-shaped为温暖友好
          ),
        ),
        elevation: 0,
        disabledBackgroundColor: backgroundColor?.withValues(alpha: 0.5),
        disabledForegroundColor: foregroundColor?.withValues(alpha: 0.5),
      ),
      child: _buildButtonContent(),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  /// 构建按钮内容（文字 + 图标 + 加载指示器）
  Widget _buildButtonContent() {
    // 加载状态：显示加载指示器
    if (isLoading) {
      return SizedBox(
        height: size.fontSize * 1.2,
        width: size.fontSize * 1.2,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? AppColors.white,
          ),
        ),
      );
    }

    // 有图标 + 文字：使用 Row 布局
    if (icon != null && label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: size.iconSize),
          const SizedBox(width: AppTheme.spaceS),
          Text(
            label!,
            style: TextStyle(
              fontSize: size.fontSize,
              fontWeight: AppTheme.fontWeightBold,
            ),
          ),
        ],
      );
    }

    // 仅文字
    if (label != null) {
      return Text(
        label!,
        style: TextStyle(
          fontSize: size.fontSize,
          fontWeight: AppTheme.fontWeightBold,
        ),
      );
    }

    // 仅图标（不应该到达这里，因为 iconOnly 会走 _buildIconButton）
    return Icon(icon, size: size.iconSize);
  }
}
