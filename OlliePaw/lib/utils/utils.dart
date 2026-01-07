/*
  文件：utils/utils.dart
  说明：
  - 工具类的桶文件（Barrel File）
  - 集中导出所有工具类
  - 简化导入语句

  使用方式：
  ```dart
  // 之前：需要多行导入
  import 'package:ollie_paw/utils/date_utils.dart';
  import 'package:ollie_paw/utils/chart_utils.dart';

  // 现在：单行导入
  import 'package:ollie_paw/utils/utils.dart';

  // 然后可以直接使用所有工具类
  String age = AppDateUtils.calculateAge('2021-05-10');
  double interval = ChartUtils.calculateYAxisInterval([29.0, 29.2, 30.1]);
  ```

  好处：
  - 减少导入语句数量
  - 统一管理导出
  - 更好的代码组织
*/

// 日期工具
export 'date_utils.dart';

// 图表工具
export 'chart_utils.dart';

// SnackBar 通知工具
export 'snackbar_helper.dart';

// 图片选择工具
export 'photo_picker_helper.dart';
