/*
  文件：widgets/home/treats_badge.dart
  说明：
  - Treats 余额徽章组件
  - 使用 Selector 优化性能，只在 Treats 余额变化时重建
  - 用于首页顶部的 Treats 显示

  性能优化（v2.3）：
  - 使用 Selector 替代 watch()
  - 仅监听 treats 字段，减少不必要的重建
  - 独立组件，不影响其他部分
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/currency_provider.dart';

/// Treats 余额徽章
///
/// 显示当前 Treats 余额，仅在余额变化时重建
class TreatsBadge extends StatelessWidget {
  const TreatsBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CurrencyProvider, int>(
      selector: (_, provider) => provider.treats,
      builder: (context, treats, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.bone,
                size: 16,
                color: Color(0xFFD97706),
              ),
              const SizedBox(width: 4),
              Text(
                '$treats Treats',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
