/*
  文件：screens/explore_screen.dart
  说明：
  - 社区页面（原探索页面），包含：
    1) 广播对话框：大型滚动容器，内容向上循环播放
    2) Nearby SOS：附近寻宠信息
    3) Fun Labs：有趣功能入口
    4) Suggested Pals：推荐好友列表

  架构变更（v3.2）：
  - 改名为"社区"页面
  - 广播改为大对话框，内容向上循环滚动
  - 移除顶部FAB，将发布功能移到统一创建按钮
  - 保留现有 Fun Labs 和 Suggested Pals
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/pet_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/sos_provider.dart';
import '../providers/broadcast_provider.dart';
import '../utils/mock_data.dart';
import '../models/types.dart';
import '../services/gemini_service.dart';
import '../services/location_service.dart';
import '../widgets/common/loading_overlay.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/app_dimensions.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/common/app_dialog.dart';
import '../widgets/common/pet_avatar_info.dart';
import '../widgets/common/fun_lab_card.dart';
import 'profile_screen.dart';

/// 社区页面：广播、SOS、Fun Labs、推荐好友
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _search = "";
  final GeminiService _ai = GeminiService();
  final PageController _broadcastPageController = PageController();
  int _currentBroadcastIndex = 0;

  @override
  void initState() {
    super.initState();
    // 启动自动翻页
    _startAutoPage();
  }

  @override
  void dispose() {
    _broadcastPageController.dispose();
    super.dispose();
  }

  /// 自动翻页广播内容 - 每次只显示一条，自动切换
  void _startAutoPage() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || !_broadcastPageController.hasClients) return;

      // 切换到下一页
      _currentBroadcastIndex++;

      _broadcastPageController.animateToPage(
        _currentBroadcastIndex,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      ).then((_) {
        if (mounted) {
          _startAutoPage(); // 继续下一轮
        }
      });
    });
  }

  /// 汪声翻译
  void _showBarkTranslator(BuildContext context, Pet pet) async {
    final currencyProvider = context.read<CurrencyProvider>();
    if (!currencyProvider.spendTreats(GameBalance.barkTranslatorCost)) {
      SnackBarHelper.showWarning(context, "${AppStrings.notEnoughTreats} Need ${GameBalance.barkTranslatorCost} Treats!");
      return;
    }

    final translation = await LoadingOverlay.show(
      context: context,
      message: AppStrings.translatingBark,
      subtitle: AppStrings.listeningToDog,
      task: () => _ai.translatePetSound(pet),
    );

    if (context.mounted && translation != null) {
      showDialog(
        context: context,
        builder: (ctx) => AppDialog(
          icon: LucideIcons.mic,
          iconColor: AppColors.primaryOrange,
          title: AppStrings.barkTranslator,
          content: Text(translation),
          actions: [
            AppDialog.textButton(ctx, label: "Cute!", onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      );
    }
  }

  /// 成长预测
  void _showTimeMachine(BuildContext context, Pet pet) async {
    final currencyProvider = context.read<CurrencyProvider>();
    if (!currencyProvider.spendTreats(GameBalance.growthPredictorCost)) {
      SnackBarHelper.showWarning(context, "${AppStrings.notEnoughTreats} Need ${GameBalance.growthPredictorCost} Treats!");
      return;
    }

    final prediction = await LoadingOverlay.show(
      context: context,
      message: AppStrings.predictingFuture,
      subtitle: AppStrings.consultingCrystalBall,
      task: () => _ai.predictFutureSelf(pet),
    );

    if (context.mounted && prediction != null) {
      showDialog(
        context: context,
        builder: (ctx) => AppDialog(
          icon: LucideIcons.hourglass,
          iconColor: AppColors.info,
          title: "Future Revealed",
          content: Text(prediction),
          actions: [
            AppDialog.textButton(ctx, label: AppStrings.close, onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pets = MockData.otherPets.where((p) => p.name.toLowerCase().contains(_search.toLowerCase())).toList();
    final myPet = context.read<PetProvider>().currentPet;

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 页面标题
              const Text("社区", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: AppSpacing.lg),

              // ========== 广播大对话框（向上循环滚动） ==========
              const Text("📢 Community Broadcasts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              Consumer<BroadcastProvider>(
                builder: (ctx, broadcastProvider, _) {
                  final broadcasts = broadcastProvider.nearbyBroadcasts;

                  if (broadcasts.isEmpty) {
                    return Container(
                      height: 160,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppRadius.allXL,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.messageSquare, size: 40, color: AppColors.textLight),
                            SizedBox(height: 8),
                            Text(
                              "No broadcasts yet...",
                              style: TextStyle(color: AppColors.textMedium, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // 每次只显示一条广播 - 使用 PageView
                  return Container(
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryOrange.withValues(alpha: 0.1),
                          AppColors.success.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppRadius.allXL,
                      border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.3), width: 2),
                    ),
                    child: PageView.builder(
                      controller: _broadcastPageController,
                      scrollDirection: Axis.vertical,
                      itemCount: broadcasts.length * 100, // 循环播放
                      itemBuilder: (ctx, i) {
                        final broadcast = broadcasts[i % broadcasts.length];
                        return Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: AppRadius.allLG,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.grey300.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 类型图标
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: broadcast.typeColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    broadcast.typeIcon,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // 内容
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      broadcast.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      broadcast.content,
                                      style: const TextStyle(
                                        color: AppColors.textMedium,
                                        fontSize: 13,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ========== Nearby SOS ==========
              const Text("🚨 ${AppStrings.nearbySOS}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              Consumer<SOSProvider>(
                builder: (ctx, sosProvider, _) {
                  final nearbyPosts = sosProvider.nearbySOSPosts;

                  if (nearbyPosts.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppRadius.allLG,
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.checkCircle, color: AppColors.success, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "No lost pets nearby - all safe! 🎉",
                              style: TextStyle(color: AppColors.textMedium, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: nearbyPosts.length,
                      itemBuilder: (ctx, i) {
                        final sos = nearbyPosts[i];
                        final distance = LocationService().calculateDistance(
                          LocationService.mockLocations['beijing_cbd']!,
                          sos.lastSeenLocation,
                        );

                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/sos-detail', arguments: sos.id),
                          child: Container(
                            width: 240,
                            margin: EdgeInsets.only(right: AppSpacing.sm, left: i == 0 ? 0 : 0),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: AppRadius.allLG,
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 2),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: AppRadius.allXS,
                                  child: Image.network(
                                    sos.petPhotoUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 70,
                                        height: 70,
                                        color: AppColors.screenBg,
                                        child: const Icon(LucideIcons.dog, color: AppColors.textLight),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        sos.petName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        sos.petBreed,
                                        style: const TextStyle(
                                          color: AppColors.textMedium,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${distance.toStringAsFixed(1)} km",
                                        style: const TextStyle(
                                          color: AppColors.textLight,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ========== Fun Labs ==========
              const Text("⚡ ${AppStrings.funLabs}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: FunLabCard.gradient(
                      icon: LucideIcons.hourglass,
                      title: AppStrings.growthPredictor,
                      onTap: () => _showTimeMachine(context, myPet),
                      gradient: LinearGradient(
                        colors: [AppColors.info, AppColors.info.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FunLabCard.outlined(
                      icon: LucideIcons.mic,
                      title: AppStrings.barkTranslator,
                      onTap: () => _showBarkTranslator(context, myPet),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ========== Suggested Pals ==========
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("✨ ${AppStrings.suggestedPals}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  // 搜索图标
                  IconButton(
                    icon: const Icon(LucideIcons.search, size: 20),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AppDialog(
                          icon: LucideIcons.search,
                          iconColor: AppColors.info,
                          title: "Search Friends",
                          content: TextField(
                            onChanged: (val) => setState(() => _search = val),
                            decoration: const InputDecoration(hintText: "Enter pet name..."),
                          ),
                          actions: [
                            AppDialog.textButton(ctx, label: AppStrings.close, onPressed: () => Navigator.pop(ctx)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (ctx, i) {
                    final pet = pets[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(pet: pet))),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppRadius.allLG,
                        ),
                        child: PetAvatarInfo(
                          avatarUrl: pet.avatarUrl,
                          name: pet.name,
                          subtitle: pet.breed,
                          actionLabel: "View",
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
