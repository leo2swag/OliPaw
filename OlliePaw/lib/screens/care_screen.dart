/*
  文件：screens/care_screen.dart
  说明：
  - 照护中心：包含两个 Tab：
    1) Health Track：健康追踪（HealthTracker 小部件）
    2) PawPal AI：AI 助手（AiAssistant 小部件）
  - 使用 TabController 控制 TabBar 与 TabBarView 的联动。

  架构变更（v2.0）：
  - 从 AppState 迁移到 PetProvider
  - PetProvider: 获取当前宠物信息
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/pet_provider.dart';
import '../widgets/health_tracker.dart';
import '../widgets/ai_assistant.dart';

/// 照护中心：健康追踪与 AI 助手入口
class CareScreen extends StatefulWidget {
  const CareScreen({super.key});

  @override
  State<CareScreen> createState() => _CareScreenState();
}

/// 照护中心 State：
/// - 混入 SingleTickerProviderStateMixin 为 TabController 提供 vsync
class _CareScreenState extends State<CareScreen> with SingleTickerProviderStateMixin {
  // 控制两个 Tab 的切换
  late TabController _tabController;

  @override
  /// 初始化 TabController
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  /// 构建页面：
  /// - 顶部 AppBar + 自定义 TabBar
  /// - TabBarView 内容包含健康追踪与 AI 助手
  Widget build(BuildContext context) {
    final pet = context.watch<PetProvider>().currentPet;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBEB),
        elevation: 0,
        title: const Text("Care Center", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 现代化的 Tab 选择器：渐变背景 + 动画指示器
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade400, Colors.cyan.shade300],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              labelColor: Colors.teal.shade700,
              unselectedLabelColor: Colors.white,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.heartPulse, size: 18),
                      SizedBox(width: 8),
                      Text("Health Track"),
                    ],
                  ),
                ),
                Tab(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.bot, size: 18),
                      SizedBox(width: 8),
                      Text("PawPal AI"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab 内容：
          // - HealthTracker：展示健康指标、图表等
          // - AiAssistant：AI 对话/建议界面
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                HealthTracker(pet: pet),
                AiAssistant(pet: pet),
              ],
            ),
          ),
        ],
      ),
    );
  }
}