/*
  文件：screens/broadcast_create_screen.dart
  说明：
  - 社区广播创建页面
  - 支持 4 种广播类型：
    1. SOS (免费) - 紧急寻宠
    2. Danger (免费) - 危险预警
    3. Social (50 Treats) - 社交活动
    4. Marketplace (50 Treats) - 闲置市场

  功能：
  - 类型选择器（带费用显示）
  - 标题和内容输入
  - 广播范围选择（1km/3km/5km/10km）
  - 过期时间选择
  - Treats 余额验证

  v2.9 - Pet SOS Feature
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../models/sos_types.dart';
import '../providers/broadcast_provider.dart';
import '../providers/currency_provider.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/common/app_button.dart';

/// 广播创建页面
class BroadcastCreateScreen extends StatefulWidget {
  const BroadcastCreateScreen({super.key});

  @override
  State<BroadcastCreateScreen> createState() => _BroadcastCreateScreenState();
}

class _BroadcastCreateScreenState extends State<BroadcastCreateScreen> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();

  BroadcastType _selectedType = BroadcastType.social;
  double _rangeKm = 5.0;
  int _expiryHours = 6;
  bool _isPublishing = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  /// 发布广播
  Future<void> _publishBroadcast() async {
    // 验证表单
    if (_titleCtrl.text.trim().isEmpty) {
      SnackBarHelper.showError(context, '请输入标题');
      return;
    }

    if (_contentCtrl.text.trim().isEmpty) {
      SnackBarHelper.showError(context, '请输入内容');
      return;
    }

    // 检查 Treats 余额
    final currencyProvider = context.read<CurrencyProvider>();
    final cost = _selectedType.cost;
    if (cost > 0 && currencyProvider.treats < cost) {
      SnackBarHelper.showError(context, 'Treats 余额不足！需要 $cost Treats');
      return;
    }

    setState(() => _isPublishing = true);

    final broadcastProvider = context.read<BroadcastProvider>();
    final broadcastId = await broadcastProvider.createBroadcast(
      type: _selectedType,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      rangeKm: _rangeKm,
      expiryHours: _expiryHours,
    );

    setState(() => _isPublishing = false);

    if (broadcastId != null && mounted) {
      SnackBarHelper.showSuccess(
        context,
        '广播发布成功！${cost > 0 ? "已扣除 $cost Treats" : ""}',
      );
      Navigator.pop(context);
    } else if (mounted) {
      SnackBarHelper.showError(context, '发布失败，请重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final cost = _selectedType.cost;

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '发布社区广播',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.lightOrangeBg,
                borderRadius: AppRadius.allSM,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wallet, size: 14, color: AppColors.darkOrange),
                  const SizedBox(width: 4),
                  Text(
                    '${currencyProvider.treats}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkOrange,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isPublishing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 类型选择器
                  const Text(
                    '广播类型',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTypeSelector(),
                  const SizedBox(height: 24),

                  // 标题输入
                  const Text(
                    '标题',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleCtrl,
                    maxLength: 50,
                    decoration: InputDecoration(
                      hintText: '简短描述你的广播...',
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 内容输入
                  const Text(
                    '内容',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contentCtrl,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: '详细描述...',
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 广播范围选择
                  const Text(
                    '广播范围',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRangeSelector(),
                  const SizedBox(height: 24),

                  // 过期时间选择
                  const Text(
                    '过期时间',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildExpirySelector(),
                  const SizedBox(height: 24),

                  // 费用提示
                  if (cost > 0) _buildCostNotice(cost, currencyProvider),
                  if (cost > 0) const SizedBox(height: 24),

                  // 发布按钮
                  AppButton.primary(
                    label: cost > 0 ? '发布广播 ($cost 🦴)' : '发布广播（免费）',
                    onPressed: _isPublishing ? null : _publishBroadcast,
                    fullWidth: true,
                    backgroundColor: _selectedType.color,
                    isLoading: _isPublishing,
                  ),
                ],
              ),
            ),
    );
  }

  /// 构建类型选择器
  Widget _buildTypeSelector() {
    return Column(
      children: BroadcastType.values.map((type) {
        final isSelected = _selectedType == type;
        final color = type.color;
        final icon = type.icon;
        final name = type.displayName;
        final description = type.description;
        final cost = type.cost;

        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected ? color : AppColors.grey200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? AppColors.lightShadow : [],
            ),
            child: Row(
              children: [
                // 图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),

                // 名称和描述
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),

                // 费用
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cost == 0
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: AppRadius.allSM,
                  ),
                  child: Text(
                    cost == 0 ? 'FREE' : '$cost 🦴',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cost == 0 ? AppColors.success : AppColors.warning,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建范围选择器
  Widget _buildRangeSelector() {
    final ranges = [1.0, 3.0, 5.0, 10.0];

    return Row(
      children: ranges.map((range) {
        final isSelected = _rangeKm == range;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _rangeKm = range),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryOrange : AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSelected ? AppColors.primaryOrange : AppColors.grey200,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${range.toInt()} km',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.white : AppColors.textMedium,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建过期时间选择器
  Widget _buildExpirySelector() {
    final Map<int, String> expiries = {
      1: '1小时',
      6: '6小时',
      12: '12小时',
      24: '24小时',
    };

    return Row(
      children: expiries.entries.map((entry) {
        final hours = entry.key;
        final label = entry.value;
        final isSelected = _expiryHours == hours;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _expiryHours = hours),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryOrange : AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSelected ? AppColors.primaryOrange : AppColors.grey200,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.white : AppColors.textMedium,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建费用提示
  Widget _buildCostNotice(int cost, CurrencyProvider currencyProvider) {
    final hasEnough = currencyProvider.treats >= cost;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasEnough ? AppColors.infoBg : AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            hasEnough ? Icons.info : Icons.warning,
            color: hasEnough ? AppColors.info : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasEnough
                  ? '发布此广播需要消耗 $cost Treats，您的余额为 ${currencyProvider.treats} Treats'
                  : 'Treats 余额不足！需要 $cost Treats，当前余额：${currencyProvider.treats} Treats',
              style: TextStyle(
                color: hasEnough ? AppColors.info : AppColors.error,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
