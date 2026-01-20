/*
  文件：screens/home_screen.dart
  说明：
  - 应用首页，展示：
    1) 固定顶部区域（占页面1/4）：筛选标签 + 每日挑战
    2) 可滚动区域：社区动态列表（Moments Feed）
  - 通过 Provider 读取 PetProvider、CurrencyProvider、CheckInProvider 获取当前宠物信息、Treat 数量与签到状态。

  架构变更（v3.2）：
  - 固定顶部设计：Filters + Daily Challenge 不随内容滚动
  - 简化布局：移除广播ticker和SOS卡片（移至社区页面）
  - 专注 Moments：首页只展示社区动态
*/
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/mock_data.dart';
import '../widgets/feed_card.dart';
import '../widgets/challenge_card.dart';
import '../widgets/home/welcome_header.dart';
import '../widgets/common/treats_badge.dart';
import '../widgets/home/checkin_button.dart';
import '../widgets/home/category_button.dart';
import '../models/types.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_dimensions.dart';
import '../utils/snackbar_helper.dart';

/// 首页：固定顶部 + 可滚动 Moments
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 选中的筛选分类（可多选）
  final Set<PostCategory> _selected = {};

  // 性能优化: 缓存筛选结果，避免每次 build 都重新计算
  List<Post>? _cachedFilteredPosts;
  Set<PostCategory>? _lastSelectedFilter;

  /// 切换筛选分类
  void _toggleCategory(PostCategory category) {
    setState(() {
      if (_selected.contains(category)) {
        _selected.remove(category);
      } else {
        _selected.add(category);
      }
      // 清空缓存，强制下次重新计算
      _cachedFilteredPosts = null;
    });
  }

  /// 下拉刷新处理
  Future<void> _handleRefresh() async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));

    // 清空缓存，强制重新加载数据
    setState(() {
      _cachedFilteredPosts = null;
    });

    // 显示刷新成功提示
    if (mounted) {
      SnackBarHelper.showSuccess(
        context,
        AppStrings.feedRefreshed,
        duration: const Duration(seconds: 1),
      );
    }
  }

  /// 构建筛选后的帖子列表（性能优化 - 带缓存）
  List<Widget> _buildFilteredPosts() {
    // 检查缓存是否有效
    final filterChanged = _lastSelectedFilter == null ||
                         !_setEquals(_lastSelectedFilter!, _selected);

    if (_cachedFilteredPosts == null || filterChanged) {
      // 重新计算筛选结果
      _cachedFilteredPosts = MockData.posts
          .where((p) => _selected.isEmpty || _selected.contains(p.category))
          .toList();
      _lastSelectedFilter = Set.from(_selected);
    }

    return _cachedFilteredPosts!.map((post) => FeedCard(post: post)).toList();
  }

  /// 辅助方法: 比较两个 Set 是否相等
  bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    for (var item in a) {
      if (!b.contains(item)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            // ========== 固定顶部区域（紧凑设计） ==========
            Container(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.xxxxl),
                  bottomRight: Radius.circular(AppRadius.xxxxl),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 每日挑战卡片（固定在顶部区域下方）- 全宽设计
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: ChallengeCard(challenge: MockData.dailyChallenge),
                  ),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center, // Vertically aligns header with the button stack
                    children: [
                      // 1. Welcome Header (Left)
                      Expanded(
                        child: WelcomeHeader(),
                      ),

                      // 2. Buttons Stack (Right)
                      Column(
                        mainAxisSize: MainAxisSize.min, // Prevents column from taking full screen height
                        crossAxisAlignment: CrossAxisAlignment.end, // Aligns buttons to the right edge
                        children: [
                          TreatsBadge(),
                          SizedBox(height: 5), // Vertical space between buttons
                          CheckInButton(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 筛选标签（横向滚动）
                  SizedBox(
                    height: 55,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          CategoryButton(
                            emoji: "📸",
                            label: AppStrings.categoryPics,
                            bgColor: AppColors.categorySnapshotBg,
                            textColor: AppColors.categorySnapshot,
                            isSelected: _selected.contains(PostCategory.snapshot),
                            onTap: () => _toggleCategory(PostCategory.snapshot),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          CategoryButton(
                            emoji: "💤",
                            label: AppStrings.categorySleep,
                            bgColor: AppColors.categorySleepyBg,
                            textColor: AppColors.categorySleepy,
                            isSelected: _selected.contains(PostCategory.sleepy),
                            onTap: () => _toggleCategory(PostCategory.sleepy),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          CategoryButton(
                            emoji: "🌳",
                            label: AppStrings.categoryWalk,
                            bgColor: AppColors.categoryWalkBg,
                            textColor: AppColors.categoryWalk,
                            isSelected: _selected.contains(PostCategory.walk),
                            onTap: () => _toggleCategory(PostCategory.walk),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          CategoryButton(
                            emoji: "🎾",
                            label: AppStrings.categoryPlay,
                            bgColor: AppColors.categoryPlayBg,
                            textColor: AppColors.categoryPlay,
                            isSelected: _selected.contains(PostCategory.play),
                            onTap: () => _toggleCategory(PostCategory.play),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Clear Filters 按钮
                  if (_selected.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() {
                        _selected.clear();
                        _cachedFilteredPosts = null;
                      }),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.x, size: 12, color: AppColors.textMedium),
                          SizedBox(width: 4),
                          Text(
                            AppStrings.clearFilters,
                            style: TextStyle(
                              color: AppColors.textMedium,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ========== 可滚动区域：Moments Feed ==========
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: AppColors.primaryOrange,
                backgroundColor: AppColors.white,
                child: ListView(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.sm,
                    right: AppSpacing.sm,
                    bottom: 70,
                  ),
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    // 根据筛选分类过滤动态
                    ..._buildFilteredPosts(),
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
