/*
  文件：widgets/common/common.dart
  说明：
  - 通用组件的桶文件（Barrel File）
  - 集中导出所有可复用的 UI 组件
  - 简化导入语句

  使用方式：
  ```dart
  // 单行导入所有通用组件
  import 'package:ollie_paw/widgets/common/common.dart';

  // 然后可以直接使用所有组件
  TreatsBadge(size: TreatsBadgeSize.medium)
  PillBadge.orange(text: '3y 7m')
  EmptyState(icon: Icons.pets, title: 'No pets')
  ```
*/

// 徽章类组件
export 'treats_badge.dart';
export 'pill_badge.dart';

// 布局组件
export 'section_header.dart';
export 'empty_state.dart';
export 'pet_avatar_info.dart';
export 'fun_lab_card.dart';

// 对话框组件
export 'app_dialog.dart';

// 按钮组件
export 'app_button.dart';

// 聊天组件
export 'chat_bubble.dart';

// 加载组件
export 'loading_overlay.dart';
