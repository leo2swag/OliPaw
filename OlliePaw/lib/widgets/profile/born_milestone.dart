/*
  文件：widgets/profile/born_milestone.dart
  说明：
  - 出生里程碑组件
  - 显示在时间线底部的出生标记

  优化（v2.5）：
  - 从 ProfileScreen 中提取，提高代码复用性
*/
import 'package:flutter/material.dart';

/// 出生里程碑
///
/// 时间线底部的出生标记
class BornMilestone extends StatelessWidget {
  /// 宠物名字
  final String petName;

  const BornMilestone({
    super.key,
    required this.petName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 出生标记点
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFDB2777),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(width: 14),

        // 出生卡片
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE7F3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF9A8D4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: Color(0xFFDB2777),
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Born",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFDB2777),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Welcome to the world, $petName! 🎉",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9F1239),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
