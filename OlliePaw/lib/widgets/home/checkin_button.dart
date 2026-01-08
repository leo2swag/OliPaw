/*
  文件：widgets/home/checkin_button.dart
  说明：
  - 每日签到按钮组件
  - 使用 Selector 优化性能，只在签到状态变化时重建
  - 处理签到逻辑和 Treats 奖励发放

  性能优化（v2.3）：
  - 使用 Selector 监听签到状态
  - 独立处理点击事件，不触发父组件重建
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/checkin_provider.dart';
import '../../providers/currency_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/constants/game_constants.dart';

/// 每日签到按钮
///
/// 仅在签到状态变化时重建
class CheckInButton extends StatelessWidget {
  const CheckInButton({super.key});

  void _handleCheckIn(BuildContext context) {
    final checkInProvider = context.read<CheckInProvider>();
    final currencyProvider = context.read<CurrencyProvider>();

    final success = checkInProvider.checkIn();
    if (success) {
      // 发放签到奖励
      currencyProvider.earnTreats(
        GameBalance.dailyCheckInReward,
        reason: '每日签到',
      );

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '签到成功！获得 ${GameBalance.dailyCheckInReward} Treats 🎉',
          ),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<CheckInProvider, bool>(
      selector: (_, provider) => provider.isCheckedIn,
      builder: (context, isCheckedIn, child) {
        return GestureDetector(
          onTap: isCheckedIn ? null : () => _handleCheckIn(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: UIDimensions.spacingM, vertical: UIDimensions.spacingS),
            decoration: BoxDecoration(
              color: isCheckedIn ? AppColors.checkedInBg : AppColors.primaryOrange,
              borderRadius: BorderRadius.circular(UIDimensions.radiusL),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCheckedIn ? LucideIcons.check : LucideIcons.sparkles,
                  size: 14,
                  color: isCheckedIn ? AppColors.checkedInText : AppColors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'Daily Check-in (+${GameBalance.dailyCheckInReward})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isCheckedIn ? AppColors.checkedInText : AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
