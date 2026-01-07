/*
  文件：theme/theme.dart
  说明：
  - 主题系统的桶文件（Barrel File）
  - 导出应用主题配置
  - 简化导入语句

  使用方式：
  ```dart
  // 之前
  import 'package:ollie_paw/theme/app_theme.dart';

  // 现在
  import 'package:ollie_paw/theme/theme.dart';

  // 使用主题常量
  Container(
    padding: EdgeInsets.all(AppTheme.spaceL),
    decoration: BoxDecoration(
      color: AppTheme.primaryOrange,
      borderRadius: BorderRadius.circular(AppTheme.radiusL),
    ),
  )
  ```

  好处：
  - 统一的导入路径
  - 未来可扩展（如添加暗黑主题等）
*/

// 应用主题
export 'app_theme.dart';
