/*
  文件：widgets/common/unified_create_dialog.dart
  说明：
  - 统一创建对话框
  - 合并发 Moments 和发广播功能
  - 包含分类选择器

  v3.2 - 统一创建入口
*/
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimensions.dart';
import '../../models/sos_types.dart';
import '../../screens/create_post_screen.dart';

/// 创建类型
enum CreateType {
  moment,      // 发 Moment
  broadcast,   // 发广播
}

/// 统一创建对话框
class UnifiedCreateDialog extends StatefulWidget {
  const UnifiedCreateDialog({super.key});

  @override
  State<UnifiedCreateDialog> createState() => _UnifiedCreateDialogState();
}

class _UnifiedCreateDialogState extends State<UnifiedCreateDialog> {
  CreateType _selectedType = CreateType.moment;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Container(
        padding: AppSpacing.allXXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            const Text(
              AppStrings.whatToShare,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 类型选择器
            _buildTypeSelector(),

            const SizedBox(height: AppSpacing.xxl),

            // 如果选择广播，显示广播类型
            if (_selectedType == CreateType.broadcast) ...[
              const Text(
                AppStrings.chooseBroadcastType,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildBroadcastTypes(),
              const SizedBox(height: AppSpacing.xl),
            ],

            // 底部按钮
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      AppStrings.cancel,
                      style: TextStyle(color: AppColors.textMedium),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: AppColors.white,
                      padding: AppSpacing.verticalMD,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: const Text(AppStrings.continue_),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建类型选择器
  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeCard(
            type: CreateType.moment,
            icon: Icons.photo_library,
            title: AppStrings.moment,
            subtitle: AppStrings.momentDesc,
            color: AppColors.primaryOrange,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildTypeCard(
            type: CreateType.broadcast,
            icon: Icons.campaign,
            title: AppStrings.broadcast,
            subtitle: AppStrings.broadcastDesc,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  /// 构建类型卡片
  Widget _buildTypeCard({
    required CreateType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: AppSpacing.allLG,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? AppSizes.borderWidthNormal : AppSizes.borderWidthThin,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: AppSizes.iconXXXL,
              color: isSelected ? color : AppColors.textMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? color : AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建广播类型选择器
  Widget _buildBroadcastTypes() {
    return Column(
      children: [
        _buildBroadcastTypeItem(
          type: BroadcastType.sos,
          icon: '🔴',
          title: AppStrings.sosType,
          subtitle: AppStrings.sosDesc,
          color: AppColors.error,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildBroadcastTypeItem(
          type: BroadcastType.danger,
          icon: '⚠️',
          title: AppStrings.dangerType,
          subtitle: AppStrings.dangerDesc,
          color: AppColors.warning,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildBroadcastTypeItem(
          type: BroadcastType.social,
          icon: '🟢',
          title: AppStrings.socialType,
          subtitle: AppStrings.socialDesc,
          color: AppColors.success,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildBroadcastTypeItem(
          type: BroadcastType.marketplace,
          icon: '🟡',
          title: AppStrings.marketplaceType,
          subtitle: AppStrings.marketplaceDesc,
          color: AppColors.warning,
        ),
      ],
    );
  }

  /// 构建广播类型选项
  Widget _buildBroadcastTypeItem({
    required BroadcastType type,
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.allMD,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.avatarLG,
            height: AppSizes.avatarLG,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 处理继续按钮
  void _handleContinue() {
    Navigator.pop(context);

    if (_selectedType == CreateType.moment) {
      // 跳转到发 Moment 页面
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreatePostScreen()),
      );
    } else {
      // 跳转到发广播页面
      Navigator.pushNamed(context, '/broadcast-create');
    }
  }
}
