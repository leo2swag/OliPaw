/*
  文件：widgets/common/tap_container.dart
  说明：
  - 可点击容器组件
  - 封装 GestureDetector + Container 常用模式
  - 减少重复代码

  使用示例：
  ```dart
  TapContainer(
    onTap: () => doSomething(),
    padding: EdgeInsets.all(16),
    borderRadius: AppRadius.allMD,
    color: AppColors.white,
    child: Text('Tap me'),
  )
  ```
*/

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// 可点击容器组件
///
/// 封装常见的 GestureDetector + Container 模式
class TapContainer extends StatelessWidget {
  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 子组件
  final Widget child;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 背景颜色
  final Color? color;

  /// 渐变背景
  final Gradient? gradient;

  /// 圆角
  final BorderRadiusGeometry? borderRadius;

  /// 边框
  final BoxBorder? border;

  /// 阴影
  final List<BoxShadow>? boxShadow;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  const TapContainer({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.width,
    this.height,
  });

  /// 卡片样式快捷构造
  TapContainer.card({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.width,
    this.height,
  })  : color = AppColors.white,
        gradient = null,
        borderRadius = AppRadius.allLG,
        border = null,
        boxShadow = AppColors.cardShadow;

  /// 圆形按钮样式
  const TapContainer.circle({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.child,
    this.color = AppColors.white,
    this.gradient,
    this.boxShadow,
    double size = 48,
  })  : padding = null,
        margin = null,
        borderRadius = null,
        border = null,
        width = size,
        height = size;

  @override
  Widget build(BuildContext context) {
    final isCircle = borderRadius == null && width == height && width != null;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          borderRadius: isCircle ? null : borderRadius,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          border: border,
          boxShadow: boxShadow,
        ),
        child: child,
      ),
    );
  }
}
