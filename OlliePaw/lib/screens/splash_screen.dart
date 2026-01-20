/*
  文件：screens/splash_screen.dart
  说明：
  - 应用启动页，展示简单的品牌动画与加载条。
  - 使用 AnimationController 实现图标的缩放动画，2 秒钟往返重复。
  - 约 2.5 秒后调用 AuthProvider.finishSplash() 告知应用可以进入下一阶段。

  架构变更（v2.0）：
  - 从 AppState 迁移到 AuthProvider
  - AuthProvider 负责启动流程控制
*/
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// 启动页：展示应用品牌与加载进度的过场页面
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// 启动页 State：
/// - 混入 SingleTickerProviderStateMixin 以提供 vsync 给动画控制器
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // 动画控制器与缩放动画曲线
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  /// 初始化动画控制与延时跳转逻辑
  void initState() {
    super.initState();
    // 创建 2 秒的 AnimationController，并绑定到当前 State 作为 vsync
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    // 让动画往返重复（缩放往返）
    _controller.repeat(reverse: true);

    // 启动后延时 2.5 秒，通知 AuthProvider 结束 Splash 进入下一阶段
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.read<AuthProvider>().finishSplash();
      }
    });
  }

  @override
  /// 释放动画控制器资源，避免内存泄漏
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  /// 构建启动页 UI：
  /// - 背景使用彩色模糊圆形装饰
  /// - 中心区域为缩放动画 Logo、标题与简易加载条
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: Stack(
        children: [
          // 背景圆形光斑（使用阴影模拟模糊效果）
          Positioned(top: 100, left: 50, child: _BlurBlob(color: AppColors.warning.withValues(alpha: 0.4), size: 150)),
          Positioned(bottom: 100, right: 50, child: _BlurBlob(color: AppColors.challengeSecondary.withValues(alpha: 0.4), size: 200)),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadius.allLG,
                      boxShadow: [BoxShadow(color: AppColors.warning.withValues(alpha:0.3), blurRadius: 20, spreadRadius: 5)],
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.2), width: 4),
                    ),
                    // 主图标：Material 的宠物图标
                    child: const Icon(Icons.pets, size: 60, color: AppColors.primaryOrange),
                  ),
                ),
                const SizedBox(height: 30),
                const Text("OlliePaw", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                const SizedBox(height: 8),
                const Text("Loading cuteness...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.grey500)),
                const SizedBox(height: 40),
                // 简易加载进度条（静态宽度示意）
                Container(
                  width: 200, height: 8,
                  decoration: BoxDecoration(color: AppColors.grey200, borderRadius: AppRadius.allXS),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primaryOrange, AppColors.warning]),
                        borderRadius: AppRadius.allXS,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 背景圆形光斑组件：
/// - 用半透明圆形 + 大半径阴影模拟模糊效果
class _BlurBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.5), 
        shape: BoxShape.circle,
        // 通过阴影达到类似模糊的效果，避免使用 BlendMode 带来的兼容问题
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.6),
            blurRadius: 60,
            spreadRadius: 10,
          )
        ],
      ),
    );
  }
}
