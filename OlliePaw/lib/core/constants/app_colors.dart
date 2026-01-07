/*
  文件：core/constants/app_colors.dart
  说明：
  - 集中管理应用程序中的所有颜色值
  - 避免硬编码颜色，提高可维护性
  - 确保UI一致性
*/

import 'package:flutter/material.dart';

/// 应用颜色常量
///
/// 集中定义所有颜色值，确保UI一致性
class AppColors {
  // 防止实例化
  AppColors._();

  // ==================== 主色调 ====================

  /// 主要橙色 (Primary Orange)
  /// 用于：主按钮、强调元素、品牌色
  static const Color primaryOrange = Color(0xFFFB923C);

  /// 深橙色 (Dark Orange)
  /// 用于：按钮按下状态、深色强调
  static const Color darkOrange = Color(0xFFEA580C);

  /// 浅橙色背景 (Light Orange Background)
  /// 用于：卡片背景、浅色区域
  static const Color lightOrangeBg = Color(0xFFFED7AA);

  // ==================== 类别颜色 ====================

  /// 快照类别颜色 (Snapshot Category)
  static const Color categorySnapshot = Color(0xFFEA580C);
  static const Color categorySnapshotBg = Color(0xFFFED7AA);

  /// 睡觉类别颜色 (Sleepy Category)
  static const Color categorySleepy = Color(0xFF2563EB);
  static const Color categorySleepyBg = Color(0xFFBFDBFE);

  /// 散步类别颜色 (Walk Category)
  static const Color categoryWalk = Color(0xFF16A34A);
  static const Color categoryWalkBg = Color(0xFFBBF7D0);

  /// 玩耍类别颜色 (Play Category)
  static const Color categoryPlay = Color(0xFFDB2777);
  static const Color categoryPlayBg = Color(0xFFFCE7F3);

  /// 成就类别颜色 (Milestone Category)
  static const Color categoryMilestone = Color(0xFF7C3AED);
  static const Color categoryMilestoneBg = Color(0xFFEDE9FE);

  /// 健康类别颜色 (Health Category)
  static const Color categoryHealth = Color(0xFF10B981);
  static const Color categoryHealthBg = Color(0xFFD1FAE5);

  // ==================== 功能颜色 ====================

  /// 成功绿色
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFD1FAE5);

  /// 错误红色
  static const Color error = Colors.red;
  static const Color errorBg = Color(0xFFFEE2E2);

  /// 警告黄色
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningBg = Color(0xFFFEF3C7);

  /// 信息蓝色
  static const Color info = Colors.indigo;
  static const Color infoBg = Color(0xFFDEE5FF);

  // ==================== 中性颜色 ====================

  /// 深灰色文本
  static const Color textDark = Color(0xFF1F2937);

  /// 中灰色文本
  static const Color textMedium = Color(0xFF6B7280);

  /// 浅灰色文本
  static const Color textLight = Color(0xFF9CA3AF);

  /// 边框颜色
  static const Color border = Color(0xFFE5E7EB);

  /// 背景颜色
  static const Color background = Color(0xFFF9FAFB);

  /// 白色
  static const Color white = Colors.white;

  /// 黑色
  static const Color black = Colors.black;

  // ==================== 签到颜色 ====================

  /// 已签到背景色
  static const Color checkedInBg = Color(0xFFDCFCE7);

  /// 已签到文本色
  static const Color checkedInText = Color(0xFF16A34A);

  // ==================== 渐变色 ====================

  /// 主渐变 (Primary Gradient)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrange, darkOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 成功渐变 (Success Gradient)
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== 挑战卡片颜色 ====================

  /// 挑战卡片主色 (紫色)
  static const Color challengePrimary = Color(0xFF8B5CF6);

  /// 挑战卡片次色 (紫红色)
  static const Color challengeSecondary = Color(0xFFD946EF);

  /// 挑战卡片浅色文本 (浅紫色)
  static const Color challengeTextLight = Color(0xFFE9D5FF);

  /// 挑战卡片渐变
  static const LinearGradient challengeGradient = LinearGradient(
    colors: [challengePrimary, challengeSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
