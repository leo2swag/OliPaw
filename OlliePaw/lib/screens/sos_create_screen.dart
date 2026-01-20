/*
  文件：screens/sos_create_screen.dart
  说明：
  - SOS 寻宠帖子创建页面
  - 从宠物档案自动填充信息
  - 最后出现位置选择
  - 悬赏金额设置

  功能：
  - 自动填充宠物信息（名字、品种、照片）
  - 位置选择器（从预定义位置选择）
  - 最后出现时间选择器
  - Treats 悬赏输入（最少 10）
  - 一键发布 SOS
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../models/types.dart';
import '../models/sos_types.dart';
import '../providers/sos_provider.dart';
import '../providers/pet_provider.dart';
import '../providers/currency_provider.dart';
import '../services/location_service.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/common/app_button.dart';

/// SOS 创建页面
class SOSCreateScreen extends StatefulWidget {
  const SOSCreateScreen({super.key});

  @override
  State<SOSCreateScreen> createState() => _SOSCreateScreenState();
}

class _SOSCreateScreenState extends State<SOSCreateScreen> {
  final TextEditingController _rewardCtrl = TextEditingController(text: '50');
  final LocationService _locationService = LocationService();

  String? _selectedLocationKey;
  DateTime _lastSeenTime = DateTime.now();
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    // 默认选择第一个位置
    if (_locationService.getAvailableLocations().isNotEmpty) {
      _selectedLocationKey = _locationService.getAvailableLocations().first.key;
    }
  }

  @override
  void dispose() {
    _rewardCtrl.dispose();
    super.dispose();
  }

  /// 发布 SOS
  Future<void> _publishSOS() async {
    final petProvider = context.read<PetProvider>();
    final sosProvider = context.read<SOSProvider>();
    final currencyProvider = context.read<CurrencyProvider>();

    // 获取当前宠物
    final pet = petProvider.currentPet;

    // 验证悬赏金额
    final reward = int.tryParse(_rewardCtrl.text) ?? 0;
    if (reward < 10) {
      if (!mounted) return;
      SnackBarHelper.showError(context, '悬赏金额至少为 10 Treats');
      return;
    }

    // 验证余额
    if (currencyProvider.treats < reward) {
      if (!mounted) return;
      SnackBarHelper.showError(context, 'Treats 余额不足');
      return;
    }

    // 验证位置选择
    if (_selectedLocationKey == null) {
      if (!mounted) return;
      SnackBarHelper.showError(context, '请选择最后出现位置');
      return;
    }

    setState(() => _isPublishing = true);

    try {
      // 设置选中的位置
      _locationService.setCurrentLocation(_selectedLocationKey!);

      // 创建 SOS
      final sosId = await sosProvider.createSOSPost(
        pet: pet,
        treatsReward: reward,
      );

      setState(() => _isPublishing = false);

      if (sosId != null && mounted) {
        SnackBarHelper.showSuccess(context, 'SOS 发布成功！已通知附近 3km 的用户');
        // 返回上一页
        Navigator.of(context).pop();
      } else if (mounted) {
        SnackBarHelper.showError(context, 'SOS 发布失败，请重试');
      }
    } catch (e) {
      setState(() => _isPublishing = false);
      if (!mounted) return;
      SnackBarHelper.showError(context, '发布失败: $e');
    }
  }

  /// 选择最后出现时间
  Future<void> _selectLastSeenTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastSeenTime,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrange,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_lastSeenTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primaryOrange,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _lastSeenTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final pet = petProvider.currentPet;
    final currencyProvider = context.watch<CurrencyProvider>();
    final locationsByCity = _locationService.getLocationsByCity();

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        backgroundColor: AppColors.screenBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '发布寻宠 SOS',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isPublishing
          ? const Center(child: CircularProgressIndicator())
          : _buildCreateForm(pet, currencyProvider, locationsByCity),
    );
  }

  /// 创建表单
  Widget _buildCreateForm(
    Pet pet,
    CurrencyProvider currencyProvider,
    Map<String, List<MapEntry<String, LocationData>>> locationsByCity,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 紧急提示
          _buildEmergencyBanner(),
          const SizedBox(height: 24),

          // 宠物信息卡片
          _buildPetInfoCard(pet),
          const SizedBox(height: 24),

          // 最后出现位置
          _buildLocationSelector(locationsByCity),
          const SizedBox(height: 20),

          // 最后出现时间
          _buildTimeSelector(),
          const SizedBox(height: 20),

          // 悬赏金额
          _buildRewardInput(currencyProvider),
          const SizedBox(height: 24),

          // 发布须知
          _buildNoticeCard(),
          const SizedBox(height: 32),

          // 发布按钮
          _buildPublishButton(),
        ],
      ),
    );
  }

  /// 紧急横幅
  Widget _buildEmergencyBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning, color: AppColors.error, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '紧急寻宠广播\n将立即通知附近 3km 内的所有用户',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 宠物信息卡片
  Widget _buildPetInfoCard(Pet pet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // 宠物照片
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: pet.gallery.isNotEmpty
                ? Image.network(
                    pet.gallery.first,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 16),

          // 宠物信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pet.breed,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_calculateAge(pet.birthDate)} 岁',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 占位符图片
  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.grey200,
      child: const Icon(
        Icons.pets,
        size: 40,
        color: AppColors.grey400,
      ),
    );
  }

  /// 位置选择器
  Widget _buildLocationSelector(
    Map<String, List<MapEntry<String, LocationData>>> locationsByCity,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最后出现位置',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppColors.lightShadow,
          ),
          child: Column(
            children: locationsByCity.entries.map((cityEntry) {
              return ExpansionTile(
                title: Text(
                  cityEntry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                children: cityEntry.value.map((location) {
                  final isSelected = _selectedLocationKey == location.key;
                  return ListTile(
                    title: Text(
                      location.value.addressName ?? location.value.city,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryOrange
                            : AppColors.textDark,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    leading: Icon(
                      Icons.location_on,
                      color: isSelected
                          ? AppColors.primaryOrange
                          : AppColors.grey400,
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryOrange,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLocationKey = location.key;
                      });
                    },
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 时间选择器
  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最后出现时间',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectLastSeenTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppColors.lightShadow,
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primaryOrange),
                const SizedBox(width: 12),
                Text(
                  _formatDateTime(_lastSeenTime),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.edit, size: 18, color: AppColors.textLight),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 悬赏输入
  Widget _buildRewardInput(CurrencyProvider currencyProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Treats 悬赏',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            Text(
              '余额: ${currencyProvider.treats} 🦴',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppColors.lightShadow,
          ),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard, color: AppColors.primaryOrange),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _rewardCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '输入悬赏金额（最少 10）',
                    hintStyle: TextStyle(color: AppColors.textLight),
                  ),
                ),
              ),
              const Text(
                '🦴',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '悬赏越高，找到的机会越大',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  /// 发布须知
  Widget _buildNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: AppColors.info, size: 20),
              SizedBox(width: 8),
              Text(
                '发布须知',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• 初始广播范围: 3 公里\n'
            '• 2小时后可扩展到 10 公里\n'
            '• SOS 帖子有效期: 48 小时\n'
            '• 找到宠物后，悬赏将发给提供有效线索的用户',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// 发布按钮
  Widget _buildPublishButton() {
    return AppButton.primary(
      label: '🚨 立即发布 SOS',
      onPressed: _isPublishing ? null : _publishSOS,
      fullWidth: true,
      backgroundColor: AppColors.error,
      isLoading: _isPublishing,
    );
  }

  /// 计算年龄
  String _calculateAge(String birthDate) {
    try {
      final birth = DateTime.parse(birthDate);
      final age = DateTime.now().difference(birth).inDays / 365;
      return age.toStringAsFixed(1);
    } catch (e) {
      return '未知';
    }
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
