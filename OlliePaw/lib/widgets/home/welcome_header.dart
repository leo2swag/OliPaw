/*
  文件：widgets/home/welcome_header.dart
  说明：
  - 首页欢迎头部组件
  - 使用 Selector 优化性能，只在宠物名称变化时重建
  - 显示问候语和宠物名称

  性能优化（v2.3）：
  - 使用 Selector 监听宠物名称
  - 避免整个页面因宠物信息变化而重建
*/
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';

/// 欢迎头部
///
/// 显示问候语和宠物名称，仅在宠物名称变化时重建
class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<PetProvider, String>(
      selector: (_, provider) => provider.currentPet.name,
      builder: (context, petName, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'Good Morning,',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              petName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
          ],
        );
      },
    );
  }
}
