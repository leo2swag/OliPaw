/*
  文件：screens/explore_screen.dart
  说明：
  - 探索页面，包含：
    1) 搜索框：按宠物名称过滤推荐列表；
    2) Fun Labs：有趣功能入口，如"成长预测"（调用 GeminiService）；
    3) 推荐好友列表：可跳转到 Profile 页面。

  架构变更（v2.0）：
  - 从 AppState 迁移到专用 Providers
  - PetProvider: 获取当前宠物信息
  - CurrencyProvider: 扣除 Treats 费用
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/pet_provider.dart';
import '../providers/currency_provider.dart';
import '../utils/mock_data.dart';
import '../models/types.dart';
import '../services/gemini_service.dart';
import '../widgets/common/loading_overlay.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/ui_constants.dart';
import '../core/constants/game_constants.dart';
import 'profile_screen.dart';

/// 探索页面：搜索、AI 小实验、推荐好友
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

/// 探索页面 State：管理搜索关键字与 AI 服务实例
class _ExploreScreenState extends State<ExploreScreen> {
  // 搜索关键字
  // _ai：Gemini AI 服务，用于生成“成长预测”文案
  String _search = "";
  final GeminiService _ai = GeminiService();

  /// 汪声翻译：
  /// - 消耗 10 Treats
  /// - 展示可爱的对话框
  void _showBarkTranslator(BuildContext context, Pet pet) async {
    final currencyProvider = context.read<CurrencyProvider>();
    if (!currencyProvider.spendTreats(GameBalance.barkTranslatorCost)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Need ${GameBalance.barkTranslatorCost} Treats!")));
      return;
    }

    final translation = await LoadingOverlay.show(
      context: context,
      message: 'Translating bark...',
      subtitle: 'Listening carefully 🐾',
      task: () => _ai.translatePetSound(pet),
    );

    if (context.mounted && translation != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.categoryPlayBg,
          title: const Text("🗣️ Bark Translator"),
          content: Text(translation),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cute!"))
          ],
        ),
      );
    }
  }

  /// 触发"成长预测"功能：
  /// - 消耗 20 Treats，不足则提示
  /// - 展示加载框，请求 GeminiService 生成预测内容
  /// - 完成后关闭加载框并展示结果对话框
  void _showTimeMachine(BuildContext context, Pet pet) async {
    final currencyProvider = context.read<CurrencyProvider>();
    if (!currencyProvider.spendTreats(GameBalance.growthPredictorCost)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Need ${GameBalance.growthPredictorCost} Treats!")));
      return;
    }

    final prediction = await LoadingOverlay.show(
      context: context,
      message: 'Predicting future...',
      subtitle: 'Consulting the crystal ball 🔮',
      task: () => _ai.predictFutureSelf(pet),
    );

    if (context.mounted && prediction != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.infoBg,
          title: const Text("🔮 Future Revealed"),
          content: Text(prediction),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))
          ],
        ),
      );
    }
  }

  @override
  /// 构建页面：
  /// - 读取其他宠物并按关键字过滤
  /// - 顶部为搜索与 Fun Labs，底部为推荐列表
  Widget build(BuildContext context) {
    final pets = MockData.otherPets.where((p) => p.name.toLowerCase().contains(_search.toLowerCase())).toList();
    final myPet = context.read<PetProvider>().currentPet;

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UIDimensions.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Discover", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  Consumer<CurrencyProvider>(
                    builder: (ctx, currencyProvider, _) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.lightOrangeBg,
                        borderRadius: BorderRadius.circular(UIDimensions.radiusL),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.bone, size: 16, color: AppColors.darkOrange),
                          const SizedBox(width: 4),
                          Text(
                            "${currencyProvider.treats}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
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
              const SizedBox(height: UIDimensions.spacingM),
              TextField(
                onChanged: (val) => setState(() => _search = val),
                decoration: InputDecoration(
                  hintText: "Search for friends...",
                  prefixIcon: const Icon(LucideIcons.search, color: AppColors.primaryOrange),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: UIDimensions.spacingL),
              const Text("⚡ Fun Labs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: UIDimensions.spacingS),
              Row(
                children: [
                  // Fun Lab：成长预测（AI）
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showTimeMachine(context, myPet),
                      child: Container(
                        height: UIDimensions.funLabCardHeight,
                        padding: const EdgeInsets.all(UIDimensions.spacingM),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.indigo, Colors.blue]),
                          borderRadius: BorderRadius.circular(UIDimensions.radiusL),
                          boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 10)],
                        ),
                        child: Stack(
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(LucideIcons.hourglass, color: AppColors.white),
                                Text("Growth Predictor", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: UIDimensions.spacingS, vertical: UIDimensions.spacingXS),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(UIDimensions.radiusS),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.bone, size: 12, color: AppColors.white),
                                    SizedBox(width: 4),
                                    Text("${GameBalance.growthPredictorCost}", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: UIDimensions.spacingS),
                  // 预留的 Fun Lab：汪声翻译（UI 占位，无逻辑）
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showBarkTranslator(context, myPet),
                      child: Container(
                        height: UIDimensions.funLabCardHeight,
                        padding: const EdgeInsets.all(UIDimensions.spacingM),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(UIDimensions.radiusL),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [BoxShadow(color: AppColors.primaryOrange.withValues(alpha: 0.15), blurRadius: 8)],
                        ),
                        child: Stack(
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(LucideIcons.mic, color: AppColors.primaryOrange),
                                Text("Bark Translator", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: UIDimensions.spacingS, vertical: UIDimensions.spacingXS),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(UIDimensions.radiusS),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.bone, size: 12, color: AppColors.primaryOrange),
                                    SizedBox(width: 4),
                                    Text("${GameBalance.barkTranslatorCost}", style: TextStyle(color: AppColors.darkOrange, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIDimensions.spacingL),
              const Text("✨ Suggested Pals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: UIDimensions.spacingS),
              // 推荐好友列表：按名称过滤后的 otherPets
              Expanded(
                child: ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (ctx, i) {
                    final pet = pets[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(pet: pet))),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: UIDimensions.spacingS),
                        padding: const EdgeInsets.all(UIDimensions.spacingS),
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(UIDimensions.radiusM)),
                        child: Row(
                          children: [
                            CircleAvatar(backgroundImage: NetworkImage(pet.avatarUrl)),
                            const SizedBox(width: UIDimensions.spacingS),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(pet.breed, style: const TextStyle(color: AppColors.textMedium, fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: UIDimensions.spacingS, vertical: 6),
                              decoration: BoxDecoration(color: AppColors.lightOrangeBg, borderRadius: BorderRadius.circular(UIDimensions.radiusL)),
                              child: const Text("Visit", style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                            )
                          ],
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