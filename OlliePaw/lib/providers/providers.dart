/*
  文件：providers/providers.dart
  说明：
  - Providers 的桶文件（Barrel File）
  - 集中导出所有状态管理 Provider
  - 简化导入语句

  使用方式：
  ```dart
  // 之前：需要多行导入
  import 'package:ollie_paw/providers/user_provider.dart';
  import 'package:ollie_paw/providers/pet_provider.dart';
  import 'package:ollie_paw/providers/currency_provider.dart';
  import 'package:ollie_paw/providers/checkin_provider.dart';

  // 现在：单行导入
  import 'package:ollie_paw/providers/providers.dart';

  // 然后可以直接使用所有 Provider
  UserProvider()
  PetProvider()
  CurrencyProvider()
  CheckInProvider()
  ```
*/

// 用户认证 Provider
export 'user_provider.dart';

// 宠物档案 Provider
export 'pet_provider.dart';

// Treats 货币系统 Provider
export 'currency_provider.dart';

// 每日签到 Provider
export 'checkin_provider.dart';

// Firebase 认证 Provider
export 'auth_provider.dart';
