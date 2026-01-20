/*
  文件：utils/utils.dart
  说明：
  - 工具类的桶文件（Barrel File）
  - 集中导出所有工具类
  - 简化导入语句

  使用方式：
  ```dart
  // 之前：需要多行导入
  import 'package:ollie_paw/core/extensions/date_extensions.dart';
  import 'package:ollie_paw/utils/chart_utils.dart';

  // 现在：单行导入
  import 'package:ollie_paw/utils/utils.dart';

  // 然后可以直接使用所有工具类
  String age = DateTime.parse('2021-05-10').calculateAge();
  double interval = ChartUtils.calculateYAxisInterval([29.0, 29.2, 30.1]);
  ```

  好处：
  - 减少导入语句数量
  - 统一管理导出
  - 更好的代码组织

  v2.8 更新：
  - 移除重复的 date_utils.dart（已合并到 date_extensions.dart）
  - 添加 date_extensions 导出以便统一访问
  - 添加 date_picker_helper 以统一日期选择器样式

  v3.3 更新：
  - 添加 navigation_helper 以统一导航模式
*/

// 导航工具（统一的导航操作）
export 'navigation_helper.dart';

// 日期扩展（统一的日期工具）
export '../core/extensions/date_extensions.dart';

// 日期选择器工具
export 'date_picker_helper.dart';

// 图表工具
export 'chart_utils.dart';

// SnackBar 通知工具
export 'snackbar_helper.dart';

// 图片选择工具
export 'photo_picker_helper.dart';
