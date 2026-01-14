/*
  文件：core/constants/app_colors.dart
  说明：
  - 集中管理应用程序中的所有颜色值
  - 避免硬编码颜色，提高可维护性
  - 确保UI一致性

  v3.0 更新：温暖友好的配色方案
  - 灵感来自 Moodiary 的柔和、有机美学
  - 更温暖的色调，更高的可接近性
  - 柔和的背景色和生动的强调色
*/

import 'package:flutter/material.dart';

/// 应用颜色常量
///
/// 集中定义所有颜色值，确保UI一致性
/// v3.0: 温暖、友好、家庭感的配色方案
class AppColors {
  // 防止实例化
  AppColors._();

  // ==================== 主色调 (更温暖柔和) ====================

  /// 主要橙色 (Warm Orange) - 更柔和的橙色
  /// 用于：主按钮、强调元素、品牌色
  static const Color primaryOrange = Color(0xFFFFB366);

  /// 深橙色 (Peachy Orange) - 温暖的桃色
  /// 用于：按钮按下状态、深色强调
  static const Color darkOrange = Color(0xFFFFB88C);

  /// 浅橙色背景 (Soft Peach Background)
  /// 用于：卡片背景、浅色区域
  static const Color lightOrangeBg = Color(0xFFFFE5CC);

  // ==================== 类别颜色 (柔和有机色) ====================

  /// 快照类别颜色 (Snapshot Category) - 温暖黄色
  static const Color categorySnapshot = Color(0xFFFFD88C);
  static const Color categorySnapshotBg = Color(0xFFFFF4E0);

  /// 睡觉类别颜色 (Sleepy Category) - 柔和薰衣草
  static const Color categorySleepy = Color(0xFFC5B3E6);
  static const Color categorySleepyBg = Color(0xFFEFE9F7);

  /// 散步类别颜色 (Walk Category) - 柔和绿色
  static const Color categoryWalk = Color(0xFFA8D5BA);
  static const Color categoryWalkBg = Color(0xFFE8F5ED);

  /// 玩耍类别颜色 (Play Category) - 天蓝色
  static const Color categoryPlay = Color(0xFFA3D5E8);
  static const Color categoryPlayBg = Color(0xFFE5F4F9);

  /// 成就类别颜色 (Milestone Category) - 柔和紫色
  static const Color categoryMilestone = Color(0xFFB8A8E6);
  static const Color categoryMilestoneBg = Color(0xFFEEE9F7);

  /// 健康类别颜色 (Health Category) - 薄荷绿
  static const Color categoryHealth = Color(0xFFB8E6D5);
  static const Color categoryHealthBg = Color(0xFFE8F7F2);

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

  /// 主屏幕背景色 (温暖奶油色)
  /// 用于：所有主要屏幕的背景 - 更温暖柔和
  static const Color screenBg = Color(0xFFFFF8F0);

  /// 卡片背景色 (柔和米色)
  /// 用于：卡片容器、标签页内容区域
  static const Color cardBg = Color(0xFFF5E6D3);

  /// 深色背景 (深海军蓝) - Moodiary inspired
  /// 用于：深色模式、对比背景
  static const Color darkBg = Color(0xFF1E2139);

  /// 灰色阴影系列
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);

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

  // ==================== 心情/情绪颜色 (有机blob色) ====================

  /// 开心心情 - 温暖黄色
  static const Color moodHappy = Color(0xFFFFD88C);
  static const Color moodHappyBg = Color(0xFFFFF4E0);

  /// 兴奋心情 - 亮粉色
  static const Color moodExcited = Color(0xFFFFB3D9);
  static const Color moodExcitedBg = Color(0xFFFFE5F3);

  /// 平静心情 - 薄荷绿
  static const Color moodCalm = Color(0xFFB8E6D5);
  static const Color moodCalmBg = Color(0xFFE8F7F2);

  /// 玩耍心情 - 天蓝色
  static const Color moodPlayful = Color(0xFFA3D5E8);
  static const Color moodPlayfulBg = Color(0xFFE5F4F9);

  /// 困倦心情 - 柔和薰衣草
  static const Color moodSleepy = Color(0xFFC5B3E6);
  static const Color moodSleepyBg = Color(0xFFEFE9F7);

  /// 能量心情 - 桃橙色
  static const Color moodEnergetic = Color(0xFFFFB88C);
  static const Color moodEnergeticBg = Color(0xFFFFE5CC);

  /// 爱心情 - 柔和粉色
  static const Color moodLove = Color(0xFFFFB3C1);
  static const Color moodLoveBg = Color(0xFFFFE5E9);

  /// 自然心情 - 柔和绿色
  static const Color moodNature = Color(0xFFA8D5BA);
  static const Color moodNatureBg = Color(0xFFE8F5ED);

  // ==================== 卡片阴影 (更柔和) ====================

  /// 卡片阴影 - 更柔和扩散
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 20,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// 轻阴影
  static const List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.04),
      blurRadius: 12,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// 浮动阴影 - 强调深度
  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.12),
      blurRadius: 32,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// 柔和阴影 - 极轻微
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.02),
      blurRadius: 8,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];
}
