/*
  文件：widgets/common/common.dart
  说明：
  - 通用组件的桶文件（Barrel File）
  - 集中导出所有可复用的 UI 组件
  - 简化导入语句

  使用方式：
  ```dart
  // 之前：需要多行导入
  import 'package:ollie_paw/widgets/common/treats_badge.dart';
  import 'package:ollie_paw/widgets/common/selectable_chip.dart';
  import 'package:ollie_paw/widgets/common/pill_badge.dart';

  // 现在：单行导入
  import 'package:ollie_paw/widgets/common/common.dart';

  // 然后可以直接使用所有组件
  TreatsBadge(size: TreatsBadgeSize.medium)
  SelectableChip(label: 'Happy', isSelected: true)
  PillBadge.orange(text: '3y 7m')
  ```

  好处：
  - 减少导入语句数量
  - 统一管理导出
  - 更好的代码组织
*/

// 徽章类组件
export 'treats_badge.dart';
export 'pill_badge.dart';

// 选择器组件
export 'selectable_chip.dart';

// 布局组件
export 'section_header.dart';
export 'feature_card.dart';
export 'empty_state.dart';

// 对话框组件
export 'app_dialog.dart';

// 按钮组件
export 'app_button.dart';

// 聊天组件
export 'chat_bubble.dart';

// 加载组件
export 'loading_overlay.dart';
