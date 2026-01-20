/*
  文件：screens/sos_detail_screen.dart
  说明：
  - SOS 详情页面
  - 显示走失宠物的完整信息
  - 线索列表展示
  - 提交线索功能
  - 扩大搜索范围功能（主人专用）

  功能：
  - 查看 SOS 详细信息
  - 浏览所有线索
  - 提交新线索
  - 扩大搜索范围（2小时后）
  - 标记宠物已找到（主人专用）
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../models/sos_types.dart';
import '../providers/sos_provider.dart';
import '../providers/currency_provider.dart';
import '../services/location_service.dart';
import '../utils/navigation_helper.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/common/app_button.dart';

/// SOS 详情页面
class SOSDetailScreen extends StatefulWidget {
  final String sosId;

  const SOSDetailScreen({
    super.key,
    required this.sosId,
  });

  @override
  State<SOSDetailScreen> createState() => _SOSDetailScreenState();
}

class _SOSDetailScreenState extends State<SOSDetailScreen> {
  final TextEditingController _clueCtrl = TextEditingController();
  final TextEditingController _expandRewardCtrl = TextEditingController(text: '50');
  bool _isSubmittingClue = false;
  bool _isExpanding = false;

  @override
  void dispose() {
    _clueCtrl.dispose();
    _expandRewardCtrl.dispose();
    super.dispose();
  }

  /// 提交线索
  Future<void> _submitClue() async {
    final sosProvider = context.read<SOSProvider>();

    final clueText = _clueCtrl.text.trim();
    if (clueText.isEmpty) {
      SnackBarHelper.showError(context, '请输入线索描述');
      return;
    }

    setState(() => _isSubmittingClue = true);

    try {
      final success = await sosProvider.submitClue(
        sosId: widget.sosId,
        description: clueText,
      );

      setState(() => _isSubmittingClue = false);

      if (success && mounted) {
        _clueCtrl.clear();
        SnackBarHelper.showSuccess(context, '线索提交成功！感谢您的帮助');
      } else if (mounted) {
        SnackBarHelper.showError(context, '线索提交失败，请重试');
      }
    } catch (e) {
      setState(() => _isSubmittingClue = false);
      if (!mounted) return;
      SnackBarHelper.showError(context, '提交失败: $e');
    }
  }

  /// 扩大搜索范围
  Future<void> _expandSearchRadius() async {
    final sosProvider = context.read<SOSProvider>();
    final currencyProvider = context.read<CurrencyProvider>();

    final additionalReward = int.tryParse(_expandRewardCtrl.text) ?? 0;
    if (additionalReward < 10) {
      SnackBarHelper.showError(context, '增加悬赏至少 10 Treats');
      return;
    }

    if (currencyProvider.treats < additionalReward) {
      SnackBarHelper.showError(context, 'Treats 余额不足');
      return;
    }

    setState(() => _isExpanding = true);

    try {
      final success = await sosProvider.expandSearchRadius(
        widget.sosId,
        additionalReward,
      );

      setState(() => _isExpanding = false);

      if (success && mounted) {
        SnackBarHelper.showSuccess(context, '搜索范围已扩大到 10km！已通知更多用户');
        Navigator.of(context).pop(); // 关闭对话框
      } else if (mounted) {
        SnackBarHelper.showError(context, '扩大范围失败，请检查条件');
      }
    } catch (e) {
      setState(() => _isExpanding = false);
      if (!mounted) return;
      SnackBarHelper.showError(context, '操作失败: $e');
    }
  }

  /// 标记为已找到
  Future<void> _markAsFound() async {
    final sosProvider = context.read<SOSProvider>();

    final confirmed = await NavigationHelper.showConfirmDialog(
      context,
      title: '确认找到宠物？',
      message: '确认后将关闭此 SOS 帖子并发放悬赏',
    );

    if (!confirmed || !mounted) return;

    try {
      final success = await sosProvider.resolveSOSPost(widget.sosId);

      if (success && mounted) {
        SnackBarHelper.showSuccess(context, '太好了！宠物已找到 🎉');
        Navigator.of(context).pop(); // 返回上一页
      } else if (mounted) {
        SnackBarHelper.showError(context, '操作失败，请重试');
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, '操作失败: $e');
    }
  }

  /// 显示扩大范围对话框
  void _showExpandDialog(SOSPost sos) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('扩大搜索范围'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '将搜索范围从 3km 扩大到 10km',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _expandRewardCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: '增加悬赏金额',
                hintText: '输入额外悬赏（最少 10）',
                suffixText: '🦴 Treats',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '当前悬赏: ${sos.treatsReward} Treats',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: _isExpanding ? null : _expandSearchRadius,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: _isExpanding
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('确认扩大'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sosProvider = context.watch<SOSProvider>();
    final sos = sosProvider.getSOSById(widget.sosId);
    final clues = sosProvider.getCluesForSOS(widget.sosId);
    final locationService = LocationService();

    if (sos == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.screenBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text('SOS 帖子不存在'),
        ),
      );
    }

    // 计算距离
    final currentLocation = locationService.getAvailableLocations().first.value;
    final distance = locationService.calculateDistance(
      currentLocation,
      sos.lastSeenLocation,
    );

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        backgroundColor: AppColors.screenBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SOS 详情',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // 分享按钮
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.textDark),
            onPressed: () {
              // TODO: 实现分享功能
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 紧急横幅
            _buildEmergencyBanner(sos),

            // 宠物信息卡片
            _buildPetInfoCard(sos, distance, locationService),

            // 主人操作按钮（仅主人可见）
            if (_isOwner(sos)) _buildOwnerActions(sos),

            // 线索提交区域
            _buildClueSubmission(),

            // 线索列表
            _buildCluesList(clues, locationService, currentLocation),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  /// 检查是否是主人
  bool _isOwner(SOSPost sos) {
    // TODO: 从 UserProvider 获取当前用户 ID
    return sos.ownerId == 'user_001';
  }

  /// 紧急横幅
  Widget _buildEmergencyBanner(SOSPost sos) {
    Color bannerColor;
    String bannerText;
    IconData bannerIcon;

    switch (sos.priority) {
      case SOSPriority.emergency:
        bannerColor = AppColors.error;
        bannerText = '🚨 紧急！刚刚走失';
        bannerIcon = Icons.warning;
        break;
      case SOSPriority.urgent:
        bannerColor = AppColors.warning;
        bannerText = '⚠️ 加急寻找中';
        bannerIcon = Icons.error_outline;
        break;
      case SOSPriority.normal:
        bannerColor = AppColors.info;
        bannerText = '📢 寻找中';
        bannerIcon = Icons.info_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: bannerColor),
      ),
      child: Row(
        children: [
          Icon(bannerIcon, color: bannerColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bannerText,
                  style: TextStyle(
                    color: bannerColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '搜索范围: ${sos.searchRadiusKm.toStringAsFixed(0)} km',
                  style: TextStyle(
                    color: bannerColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 宠物信息卡片
  Widget _buildPetInfoCard(
    SOSPost sos,
    double distance,
    LocationService locationService,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // 宠物照片
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.network(
              sos.petPhotoUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: AppColors.grey200,
                  child: const Icon(
                    Icons.pets,
                    size: 64,
                    color: AppColors.grey400,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // 宠物名字
          Text(
            sos.petName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),

          // 品种
          Text(
            sos.petBreed,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 20),

          // 信息行
          _buildInfoRow(
            Icons.location_on,
            '最后出现',
            sos.lastSeenLocation.addressName ?? sos.lastSeenLocation.city,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time,
            '时间',
            _formatRelativeTime(sos.lastSeenTime),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.straighten,
            '距离您',
            locationService.formatDistance(distance),
          ),
          const SizedBox(height: 20),

          // 悬赏信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.card_giftcard,
                  color: AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '悬赏: ${sos.treatsReward} 🦴 Treats',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),

          // 特征标签
          if (sos.petCharacteristics.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '特征:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sos.petCharacteristics.map((char) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: AppRadius.allMD,
                  ),
                  child: Text(
                    char,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// 信息行
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryOrange),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMedium,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// 主人操作按钮
  Widget _buildOwnerActions(SOSPost sos) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppColors.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '主人操作',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          // 扩大范围按钮
          if (sos.canExpandRadius)
            AppButton.primary(
              label: '扩大搜索范围到 10km',
              onPressed: () => _showExpandDialog(sos),
              fullWidth: true,
              icon: Icons.zoom_out_map,
            ),

          if (sos.canExpandRadius) const SizedBox(height: 12),

          // 标记为已找到按钮
          AppButton.primary(
            label: '✅ 宠物已找到',
            onPressed: _markAsFound,
            fullWidth: true,
            backgroundColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  /// 线索提交区域
  Widget _buildClueSubmission() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppColors.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates, color: AppColors.primaryOrange),
              SizedBox(width: 8),
              Text(
                '提供线索',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _clueCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '描述您看到的情况...\n例如：刚刚在公园看到类似的狗',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          AppButton.primary(
            label: '提交线索',
            onPressed: _isSubmittingClue ? null : _submitClue,
            fullWidth: true,
            isLoading: _isSubmittingClue,
            icon: Icons.send,
          ),
        ],
      ),
    );
  }

  /// 线索列表
  Widget _buildCluesList(
    List<ClueReport> clues,
    LocationService locationService,
    LocationData currentLocation,
  ) {
    if (clues.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.textLight,
              ),
              SizedBox(height: 12),
              Text(
                '暂无线索',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '成为第一个提供线索的人',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '线索记录 (${clues.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...clues.map((clue) {
            final distance = locationService.calculateDistance(
              currentLocation,
              clue.location,
            );
            return _buildClueCard(clue, distance, locationService);
          }),
        ],
      ),
    );
  }

  /// 线索卡片
  Widget _buildClueCard(
    ClueReport clue,
    double distance,
    LocationService locationService,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppColors.lightShadow,
        border: clue.helpful
            ? Border.all(color: AppColors.success, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clue.reporterName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      _formatRelativeTime(clue.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (clue.helpful)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: AppRadius.allSM,
                  ),
                  child: const Text(
                    '✓ 有帮助',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 线索描述
          Text(
            clue.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // 位置信息
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.textMedium,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  clue.location.addressName ?? clue.location.city,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ),
              Text(
                locationService.formatDistance(distance),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 格式化相对时间
  String _formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小时前';
    } else {
      return '${difference.inDays} 天前';
    }
  }
}
