/*
  文件：widgets/common/app_card.dart
  说明：
  - 通用卡片容器组件
  - 封装常用的 Container + BoxDecoration 模式
  - 减少重复代码，保持 UI 一致性

  使用示例：
  ```dart
  // 默认样式
  AppCard(
    child: Text('Hello'),
  )

  // 自定义样式
  AppCard(
    padding: AppSpacing.allMD,
    borderRadius: AppRadius.allLG,
    color: AppColors.grey100,
    boxShadow: AppColors.lightShadow,
    child: Text('Custom card'),
  )
  ```
*/

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// 通用卡片容器组件
///
/// 封装常见的 Container + BoxDecoration 模式
/// 用于非交互式容器（交互式请使用 TapContainer）
class AppCard extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// 内边距（默认：AppSpacing.allLG）
  final EdgeInsetsGeometry padding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 背景颜色（默认：AppColors.white）
  final Color color;

  /// 渐变背景（优先于 color）
  final Gradient? gradient;

  /// 圆角（默认：AppRadius.allMD）
  final BorderRadiusGeometry? borderRadius;

  /// 边框
  final BoxBorder? border;

  /// 阴影（默认：AppColors.cardShadow）
  final List<BoxShadow>? boxShadow;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 对齐方式
  final AlignmentGeometry? alignment;

  /// 约束条件
  final BoxConstraints? constraints;

  /// 是否使用默认圆角
  final bool _useDefaultRadius;

  /// 阴影类型
  final _ShadowType _shadowType;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.allLG,
    this.margin,
    this.color = AppColors.white,
    this.gradient,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
  })  : _useDefaultRadius = true,
        _shadowType = _ShadowType.card;

  /// 轻量阴影卡片
  const AppCard.light({
    super.key,
    required this.child,
    this.padding = AppSpacing.allLG,
    this.margin,
    this.color = AppColors.white,
    this.gradient,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
  })  : boxShadow = null,
        _useDefaultRadius = true,
        _shadowType = _ShadowType.light;

  /// 柔和阴影卡片
  const AppCard.soft({
    super.key,
    required this.child,
    this.padding = AppSpacing.allLG,
    this.margin,
    this.color = AppColors.white,
    this.gradient,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
  })  : boxShadow = null,
        _useDefaultRadius = true,
        _shadowType = _ShadowType.soft;

  /// 无阴影卡片
  const AppCard.flat({
    super.key,
    required this.child,
    this.padding = AppSpacing.allLG,
    this.margin,
    this.color = AppColors.white,
    this.gradient,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
  })  : boxShadow = null,
        _useDefaultRadius = true,
        _shadowType = _ShadowType.none;

  /// 浮动阴影卡片（强调效果）
  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding = AppSpacing.allLG,
    this.margin,
    this.color = AppColors.white,
    this.gradient,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
  })  : boxShadow = null,
        _useDefaultRadius = true,
        _shadowType = _ShadowType.floating;

  List<BoxShadow>? get _resolvedShadow {
    if (boxShadow != null) return boxShadow;
    switch (_shadowType) {
      case _ShadowType.card:
        return AppColors.cardShadow;
      case _ShadowType.light:
        return AppColors.lightShadow;
      case _ShadowType.soft:
        return AppColors.softShadow;
      case _ShadowType.floating:
        return AppColors.floatingShadow;
      case _ShadowType.none:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      alignment: alignment,
      constraints: constraints,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: borderRadius ?? (_useDefaultRadius ? AppRadius.allMD : null),
        border: border,
        boxShadow: _resolvedShadow,
      ),
      child: child,
    );
  }
}

enum _ShadowType { card, light, soft, floating, none }
