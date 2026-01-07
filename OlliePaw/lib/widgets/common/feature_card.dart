/*
  文件：widgets/common/feature_card.dart
  说明：
  - 功能卡片组件
  - 用于 Explore 页面的功能展示
  - 支持渐变背景或纯色背景
  - 显示 Treats 消耗成本

  使用示例：
  ```dart
  // 使用渐变背景
  FeatureCard(
    title: 'Growth Predictor',
    icon: Icons.show_chart,
    costInTreats: 10,
    gradient: AppTheme.gradientPurple,
    onTap: () => _showGrowthPredictor(),
  )

  // 使用纯色背景
  FeatureCard(
    title: 'Bark Translator',
    icon: Icons.pets,
    costInTreats: 5,
    backgroundColor: Colors.blue,
    onTap: () => _showBarkTranslator(),
  )
  ```

  替换位置：
  - explore_screen.dart - Growth Predictor 卡片 (lines 169-213)
  - explore_screen.dart - Bark Translator 卡片 (lines 216-261)
*/

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 功能卡片组件
///
/// 用于展示应用功能，显示图标、标题和 Treats 成本
/// 支持渐变背景或纯色背景
///
/// 特点：
/// - 支持渐变或纯色背景
/// - 右上角显示 Treats 成本徽章
/// - 统一的阴影和圆角
/// - 点击交互
class FeatureCard extends StatelessWidget {
  /// 标题
  final String title;

  /// 图标
  final IconData icon;

  /// Treats 消耗成本
  final int costInTreats;

  /// 背景渐变（可选，与 backgroundColor 二选一，优先使用 gradient）
  final Gradient? gradient;

  /// 背景颜色（可选，与 gradient 二选一）
  final Color? backgroundColor;

  /// 点击回调
  final VoidCallback? onTap;

  /// 图标大小（默认 32px）
  final double iconSize;

  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.costInTreats,
    this.gradient,
    this.backgroundColor,
    this.onTap,
    this.iconSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceL),
        decoration: BoxDecoration(
          gradient: gradient,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: AppTheme.shadowMedium,
        ),
        child: Stack(
          children: [
            // 主内容（图标 + 标题）
            Row(
              children: [
                // 图标
                Icon(
                  icon,
                  color: Colors.white,
                  size: iconSize,
                ),
                const SizedBox(width: AppTheme.spaceM),
                // 标题
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTheme.fontSizeL,
                      fontWeight: AppTheme.fontWeightBold,
                    ),
                  ),
                ),
              ],
            ),

            // Treats 成本徽章（右上角）
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceS,
                  vertical: AppTheme.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 骨头 emoji
                    const Text(
                      '🦴',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 3),
                    // Treats 数量
                    Text(
                      '$costInTreats',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: AppTheme.fontWeightBold,
                        fontSize: AppTheme.fontSizeS,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
