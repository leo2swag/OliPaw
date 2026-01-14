/*
  文件：widgets/common/organic_blob.dart
  说明：
  - 有机形状装饰组件 (Organic Blob)
  - 灵感来自 Moodiary 的柔和、圆润美学
  - 用于创建温暖、友好的视觉元素

  使用示例：
  ```dart
  // 基本用法
  OrganicBlob(
    size: 120,
    color: AppColors.moodHappy,
    child: Text('😊', style: TextStyle(fontSize: 48)),
  )

  // 不规则形状
  OrganicBlob.irregular(
    width: 150,
    height: 120,
    color: AppColors.moodPlayful.withOpacity(0.3),
  )

  // 作为背景装饰
  Stack(
    children: [
      Positioned(
        top: -30,
        right: -40,
        child: OrganicBlob(
          size: 200,
          color: AppColors.moodCalm.withOpacity(0.2),
        ),
      ),
      // 您的内容...
    ],
  )
  ```

  更新于：v3.0 - 温暖UI设计
*/

import 'package:flutter/material.dart';

/// 有机形状装饰组件
///
/// 创建不规则的圆润形状，模拟手绘风格的blob
class OrganicBlob extends StatelessWidget {
  /// Blob 大小（正方形）
  final double? size;

  /// Blob 宽度（不规则形状）
  final double? width;

  /// Blob 高度（不规则形状）
  final double? height;

  /// Blob 颜色
  final Color color;

  /// 内部子组件（可选）
  final Widget? child;

  /// Blob 样式变化（0-6 种预设形状）
  final int variant;

  const OrganicBlob({
    super.key,
    this.size,
    this.width,
    this.height,
    required this.color,
    this.child,
    this.variant = 0,
  }) : assert(size != null || (width != null && height != null),
            'Either size or both width and height must be provided');

  /// 创建不规则形状的 blob
  factory OrganicBlob.irregular({
    required double width,
    required double height,
    required Color color,
    int variant = 0,
    Widget? child,
  }) {
    return OrganicBlob(
      width: width,
      height: height,
      color: color,
      variant: variant,
      child: child,
    );
  }

  /// 创建圆形 blob（用于心情选择器）
  factory OrganicBlob.mood({
    required double size,
    required Color color,
    int variant = 0,
    required Widget child,
  }) {
    return OrganicBlob(
      size: size,
      color: color,
      variant: variant,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = size ?? width!;
    final double h = size ?? height!;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: _getBlobBorderRadius(variant, w, h),
      ),
      child: child != null ? Center(child: child) : null,
    );
  }

  /// 根据变体返回不同的有机形状边界
  BorderRadius _getBlobBorderRadius(int variant, double w, double h) {
    // 确保变体在 0-6 范围内
    final v = variant % 7;

    switch (v) {
      case 0:
        // 温和的不规则圆形
        return BorderRadius.only(
          topLeft: Radius.circular(w * 0.6),
          topRight: Radius.circular(w * 0.4),
          bottomLeft: Radius.circular(w * 0.5),
          bottomRight: Radius.circular(w * 0.55),
        );
      case 1:
        // 水滴形状
        return BorderRadius.only(
          topLeft: Radius.circular(w * 0.7),
          topRight: Radius.circular(w * 0.3),
          bottomLeft: Radius.circular(w * 0.4),
          bottomRight: Radius.circular(w * 0.6),
        );
      case 2:
        // 云朵形状
        return BorderRadius.only(
          topLeft: Radius.circular(w * 0.5),
          topRight: Radius.circular(w * 0.6),
          bottomLeft: Radius.circular(w * 0.6),
          bottomRight: Radius.circular(w * 0.4),
        );
      case 3:
        // 柔和椭圆
        return BorderRadius.only(
          topLeft: Radius.circular(w * 0.4),
          topRight: Radius.circular(w * 0.5),
          bottomLeft: Radius.circular(w * 0.55),
          bottomRight: Radius.circular(w * 0.45),
        );
      case 4:
        // 有机豆形
        return BorderRadius.only(
          topLeft: Radius.circular(w * 0.65),
          topRight: Radius.circular(w * 0.45),
          bottomLeft: Radius.circular(w * 0.35),
          bottomRight: Radius.circular(w * 0.65),
        );
      case 5:
        // 不对称圆
        return BorderRadius.only(
          topLeft: Radius.circular(w * 0.5),
          topRight: Radius.circular(w * 0.7),
          bottomLeft: Radius.circular(w * 0.6),
          bottomRight: Radius.circular(w * 0.3),
        );
      case 6:
        // 波浪圆
        return BorderRadius.only(
          topLeft: Radius.circular(w * 0.55),
          topRight: Radius.circular(w * 0.4),
          bottomLeft: Radius.circular(w * 0.45),
          bottomRight: Radius.circular(w * 0.6),
        );
      default:
        // 默认为标准圆形
        return BorderRadius.circular(w * 0.5);
    }
  }
}

/// 装饰性 blob 背景
///
/// 用于在屏幕背景添加有机装饰元素
class DecorativeBlobs extends StatelessWidget {
  const DecorativeBlobs({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 左上角 blob
        Positioned(
          top: -40,
          left: -30,
          child: OrganicBlob(
            size: 180,
            color: const Color(0xFFFFD88C).withValues(alpha: 0.15),
            variant: 1,
          ),
        ),
        // 右上角 blob
        Positioned(
          top: -20,
          right: -50,
          child: OrganicBlob(
            size: 200,
            color: const Color(0xFFB8E6D5).withValues(alpha: 0.12),
            variant: 3,
          ),
        ),
        // 左下角 blob
        Positioned(
          bottom: -60,
          left: -40,
          child: OrganicBlob(
            size: 220,
            color: const Color(0xFFA3D5E8).withValues(alpha: 0.18),
            variant: 5,
          ),
        ),
        // 右下角 blob
        Positioned(
          bottom: -30,
          right: -45,
          child: OrganicBlob(
            size: 190,
            color: const Color(0xFFFFB3D9).withValues(alpha: 0.14),
            variant: 2,
          ),
        ),
      ],
    );
  }
}

/// Blob 装饰的卡片
///
/// 结合 blob 背景的温暖卡片设计
class BlobCard extends StatelessWidget {
  /// 卡片内容
  final Widget child;

  /// 卡片内边距
  final EdgeInsetsGeometry padding;

  /// 卡片背景色
  final Color? backgroundColor;

  /// Blob 装饰颜色
  final Color? blobColor;

  /// Blob 位置
  final Alignment blobAlignment;

  const BlobCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.backgroundColor,
    this.blobColor,
    this.blobAlignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF5E6D3),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Blob 装饰
          Positioned(
            top: blobAlignment == Alignment.topRight ? -20 : null,
            right: blobAlignment == Alignment.topRight ? -20 : null,
            bottom: blobAlignment == Alignment.bottomLeft ? -20 : null,
            left: blobAlignment == Alignment.bottomLeft ? -20 : null,
            child: OrganicBlob(
              size: 100,
              color: (blobColor ?? const Color(0xFFFFD88C)).withValues(alpha: 0.2),
              variant: 2,
            ),
          ),
          // 实际内容
          child,
        ],
      ),
    );
  }
}
