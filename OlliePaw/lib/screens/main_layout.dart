/*
  文件：screens/main_layout.dart
  说明：
  - 应用主布局，包含底部导航（BottomAppBar + FAB 凹口）与五个入口：
    0 首页 Home
    1 探索 Explore
    2 中间创建按钮（独立路由，不占据 tab）
    3 健康/照护 Care
    4 个人 Profile
  - FAB（中间 + 号）点击后跳转到创建发布页面 CreatePostScreen。
  注意：本文件仅添加中文注释，不改变逻辑。
*/
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'care_screen.dart';
import 'profile_screen.dart';
import '../widgets/common/unified_create_dialog.dart';

/// 主布局：包含底部导航与中心悬浮按钮
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

/// 主布局状态：
/// - 管理当前选中的底部导航索引
/// - 维护对应的页面列表（中间位置使用占位）
class _MainLayoutState extends State<MainLayout> {
  // 当前选中的���部导航索引
  int _currentIndex = 0;
  
  // 对应底部导航的页面集合（中间使用 SizedBox 占位，给 FAB 腾出空间）
  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const SizedBox(), // Placeholder for center button
    const CareScreen(),
    const ProfileScreen(),
  ];

  /// 处理中间 + 号按钮点击：打开统一创建对话框
  void _onFabPressed() {
    showDialog(
      context: context,
      builder: (context) => const UnifiedCreateDialog(),
    );
  }

  @override
  /// 构建 Scaffold：
  /// - body：展示当前索引对应页面
  /// - FAB：居中悬浮按钮用于发帖
  /// - BottomAppBar：预留中间凹口给 FAB
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      // 居中的悬浮按钮（发帖入口）- 方形设计
      floatingActionButton: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(top: AppSpacing.xl),
        decoration: BoxDecoration(
          borderRadius: AppRadius.allLG,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryOrange, AppColors.darkOrange],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withValues(alpha: 0.4),
              blurRadius: AppSpacing.md,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _onFabPressed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.allLG),
          child: const Icon(LucideIcons.plus, color: AppColors.white, size: AppSizes.iconXL),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        // 使用带凹口的矩形，配合中间的 FAB
        shape: const CircularNotchedRectangle(),
        notchMargin: AppSpacing.sm,
        height: 70,
        color: AppColors.white,
        elevation: 8,
        shadowColor: AppColors.black.withValues(alpha: 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(icon: LucideIcons.home, isSelected: _currentIndex == 0, onTap: () => setState(() => _currentIndex = 0)),
            _NavBarItem(icon: LucideIcons.search, isSelected: _currentIndex == 1, onTap: () => setState(() => _currentIndex = 1)),
            const SizedBox(width: 48), // 中间���白用于 FAB 凹��� 
            _NavBarItem(icon: LucideIcons.heartPulse, isSelected: _currentIndex == 3, onTap: () => setState(() => _currentIndex = 3)),
            _NavBarItem(icon: LucideIcons.user, isSelected: _currentIndex == 4, onTap: () => setState(() => _currentIndex = 4)),
          ],
        ),
      ),
    );
  }
}

/// 底部导航项（私有）：图标 + 选中小圆点
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({required this.icon, required this.isSelected, required this.onTap});

  @override
  /// 简单的点击区域：图标 + 选中态下的小圆点
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppColors.primaryOrange : AppColors.grey400, size: AppSizes.iconXL),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.xs),
              width: 5, height: 5,
              decoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle),
            )
        ],
      ),
    );
  }
}