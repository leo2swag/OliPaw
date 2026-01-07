/*
  文件：widgets/common/treats_badge.dart
  说明：
  - Treats 余额徽章组件
  - 自动从 AppState 读取 Treats 数据
  - 支持多种尺寸和显示模式
  - 统一替代所有重复的 Treats 徽章代码

  使用示例：
  ```dart
  // 默认中等尺寸
  TreatsBadge()

  // 大尺寸带标签
  TreatsBadge(
    size: TreatsBadgeSize.large,
    showLabel: true,
  )

  // 小尺寸
  TreatsBadge(size: TreatsBadgeSize.small)
  ```

  替换位置：
  - home_screen.dart (lines 163-184)
  - explore_screen.dart (lines 127-149)
  - profile_screen.dart (lines 216-226)
  - ai_assistant.dart (lines 289-318)
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../providers/currency_provider.dart';

/// Treats 余额徽章组件
///
/// 显示用户当前的 Treats 余额，自动从 CurrencyProvider 读取
/// 支持多种尺寸和显示模式
///
/// 特点：
/// - 自动响应 CurrencyProvider 更新
/// - 三种预设尺寸（small/medium/large）
/// - 可选显示 "Treats" 文字标签
/// - 统一的视觉风格
class TreatsBadge extends StatelessWidget {
  /// 徽章尺寸
  final TreatsBadgeSize size;

  /// 是否显示 "Treats" 文字标签
  final bool showLabel;

  const TreatsBadge({
    super.key,
    this.size = TreatsBadgeSize.medium,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, _) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.horizontalPadding,
            vertical: size.verticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppTheme.treatsYellow,
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 骨头图标
              Icon(
                LucideIcons.bone,
                size: size.iconSize,
                color: AppTheme.treatsOrange,
              ),
              SizedBox(width: size.spacing),
              // Treats 数量（可选带"Treats"标签）
              Text(
                showLabel ? '${currencyProvider.treats} Treats' : '${currencyProvider.treats}',
                style: TextStyle(
                  fontWeight: AppTheme.fontWeightExtraBold,
                  color: AppTheme.treatsOrange,
                  fontSize: size.fontSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Treats 徽章尺寸枚举
///
/// 定义三种预设尺寸，每种尺寸包含对应的图标、字体、间距配置
enum TreatsBadgeSize {
  /// 小尺寸
  ///
  /// 用于：紧凑空间、次要位置
  /// 图标：14px，字体：11px
  small(
    iconSize: 14.0,
    fontSize: 11.0,
    horizontalPadding: 8.0,
    verticalPadding: 4.0,
    spacing: 3.0,
  ),

  /// 中等尺寸（默认）
  ///
  /// 用于：常规显示
  /// 图标：16px，字体：13px
  medium(
    iconSize: 16.0,
    fontSize: 13.0,
    horizontalPadding: 12.0,
    verticalPadding: 6.0,
    spacing: 4.0,
  ),

  /// 大尺寸
  ///
  /// 用于：强调显示、主要位置
  /// 图标：18px，字体：15px
  large(
    iconSize: 18.0,
    fontSize: 15.0,
    horizontalPadding: 16.0,
    verticalPadding: 8.0,
    spacing: 6.0,
  );

  /// 图标大小
  final double iconSize;

  /// 字体大小
  final double fontSize;

  /// 水平内边距
  final double horizontalPadding;

  /// 垂直内边距
  final double verticalPadding;

  /// 图标与文字间距
  final double spacing;

  const TreatsBadgeSize({
    required this.iconSize,
    required this.fontSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.spacing,
  });
}
