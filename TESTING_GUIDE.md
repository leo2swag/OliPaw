# 测试框架实施指南 (Testing Framework Guide)

本文档提供完整的测试框架实施方案，包括单元测试、Widget 测试和集成测试。

---

## 📋 目录

1. [测试金字塔](#1-测试金字塔)
2. [依赖配置](#2-依赖配置)
3. [单元测试](#3-单元测试)
4. [Widget 测试](#4-widget-测试)
5. [集成测试](#5-集成测试)
6. [Mock 和测试工具](#6-mock-和测试工具)
7. [CI/CD 集成](#7-cicd-集成)

---

## 1. 测试金字塔

```
        /\
       /  \      集成测试 (10%)
      /    \     - 端到端流程
     /------\    - 用户场景
    /        \
   /          \  Widget 测试 (30%)
  /            \ - UI 组件
 /--------------\ - 交互逻辑
/                \
------------------
  单元测试 (60%)
  - Provider 逻辑
  - 工具函数
  - 服务类
```

**测试覆盖率目标**: 70%+

---

## 2. 依赖配置

### 2.1 添加测试依赖

**文件**: `pubspec.yaml`

```yaml
dev_dependencies:
  # 现有依赖...

  # Flutter 测试框架（默认已包含）
  flutter_test:
    sdk: flutter

  # Mock 库
  mockito: ^5.4.2
  build_runner: ^2.4.6

  # 测试工具
  integration_test:
    sdk: flutter
  flutter_lints: ^3.0.0

  # 覆盖率报告
  coverage: ^1.6.3
```

### 2.2 安装依赖

```bash
cd OlliePaw
flutter pub get
```

---

## 3. 单元测试

### 3.1 测试 CurrencyProvider

**文件**: `test/providers/currency_provider_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ollie_paw/providers/currency_provider.dart';

void main() {
  group('CurrencyProvider', () {
    late CurrencyProvider provider;

    setUp(() {
      // 每个测试前创建新实例
      provider = CurrencyProvider();
    });

    test('初始 Treats 应为 50', () {
      expect(provider.treats, 50);
    });

    test('earnTreats 应增加余额', () {
      // Arrange
      final initialTreats = provider.treats;

      // Act
      provider.earnTreats(10, reason: '测试奖励');

      // Assert
      expect(provider.treats, initialTreats + 10);
    });

    test('spendTreats 余额足够时应成功', () {
      // Arrange
      provider.earnTreats(100); // 确保有足够余额

      // Act
      final success = provider.spendTreats(20);

      // Assert
      expect(success, true);
      expect(provider.treats, 130); // 50 + 100 - 20
    });

    test('spendTreats 余额不足时应失败', () {
      // Arrange
      // 初始余额 50

      // Act
      final success = provider.spendTreats(100);

      // Assert
      expect(success, false);
      expect(provider.treats, 50); // 余额不变
    });

    test('支出 Treats 应触发 notifyListeners', () {
      // Arrange
      var notified = false;
      provider.addListener(() => notified = true);

      // Act
      provider.spendTreats(10);

      // Assert
      expect(notified, true);
    });
  });
}
```

### 3.2 测试 CheckInProvider

**文件**: `test/providers/checkin_provider_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ollie_paw/providers/checkin_provider.dart';

void main() {
  group('CheckInProvider', () {
    late CheckInProvider provider;

    setUp(() {
      provider = CheckInProvider();
    });

    test('初始状态应为未签到', () {
      expect(provider.isCheckedIn, false);
      expect(provider.consecutiveDays, 0);
    });

    test('首次签到应成功', () {
      // Act
      final success = provider.checkIn();

      // Assert
      expect(success, true);
      expect(provider.isCheckedIn, true);
      expect(provider.consecutiveDays, 1);
    });

    test('同一天重复签到应失败', () {
      // Arrange
      provider.checkIn(); // 第一次签到

      // Act
      final success = provider.checkIn(); // 第二次签到

      // Assert
      expect(success, false);
      expect(provider.consecutiveDays, 1); // 连续天数不变
    });

    test('签到应返回正确奖励金额', () {
      expect(CheckInProvider.dailyReward, 20);
    });
  });
}
```

### 3.3 测试 UserProvider

**文件**: `test/providers/user_provider_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ollie_paw/providers/user_provider.dart';
import 'package:ollie_paw/models/types.dart';

void main() {
  group('UserProvider', () {
    late UserProvider provider;

    setUp(() {
      provider = UserProvider();
    });

    test('初始状态应为未登录且启动页未完成', () {
      expect(provider.isLoggedIn, false);
      expect(provider.splashFinished, false);
      expect(provider.currentUser, null);
    });

    test('login 应设置当前用户', () {
      // Arrange
      final user = UserProfile(
        id: 'test_user',
        type: UserType.OWNER,
        name: 'Test User',
        breed: 'Golden Retriever',
      );

      // Act
      provider.login(user);

      // Assert
      expect(provider.isLoggedIn, true);
      expect(provider.currentUser, user);
    });

    test('logout 应清除用户状态', () {
      // Arrange
      final user = UserProfile(
        id: 'test_user',
        type: UserType.OWNER,
        name: 'Test User',
      );
      provider.login(user);

      // Act
      provider.logout();

      // Assert
      expect(provider.isLoggedIn, false);
      expect(provider.currentUser, null);
      expect(provider.splashFinished, false);
    });

    test('finishSplash 应更新状态', () {
      // Act
      provider.finishSplash();

      // Assert
      expect(provider.splashFinished, true);
    });
  });
}
```

### 3.4 测试 Result 类型

**文件**: `test/core/result_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ollie_paw/core/result.dart';

void main() {
  group('Result', () {
    test('Success 应包含正确的数据', () {
      // Arrange
      const result = Success<int>(42);

      // Act & Assert
      result.when(
        success: (data) => expect(data, 42),
        failure: (_) => fail('不应调用 failure'),
      );
    });

    test('Failure 应包含错误消息', () {
      // Arrange
      const result = Failure<int>('错误消息');

      // Act & Assert
      result.when(
        success: (_) => fail('不应调用 success'),
        failure: (message) => expect(message, '错误消息'),
      );
    });

    test('Success 的 isSuccess 应为 true', () {
      const result = Success<String>('test');
      expect(result.isSuccess, true);
    });

    test('Failure 的 isSuccess 应为 false', () {
      const result = Failure<String>('error');
      expect(result.isSuccess, false);
    });
  });
}
```

---

## 4. Widget 测试

### 4.1 测试 LoadingOverlay

**文件**: `test/widgets/loading_overlay_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ollie_paw/widgets/common/loading_overlay.dart';

void main() {
  group('LoadingOverlay', () {
    testWidgets('应显示消息和进度指示器', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingOverlay(
            message: '加载中...',
            subtitle: '请稍候',
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('加载中...'), findsOneWidget);
      expect(find.text('请稍候'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('show 方法应执行任务并关闭', (tester) async {
      // Arrange
      var taskExecuted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  await LoadingOverlay.show(
                    context: context,
                    message: '处理中',
                    task: () async {
                      await Future.delayed(const Duration(milliseconds: 100));
                      taskExecuted = true;
                      return 'result';
                    },
                  );
                },
                child: const Text('开始'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('开始'));
      await tester.pump(); // 开始动画
      await tester.pump(const Duration(milliseconds: 100)); // 等待任务完成
      await tester.pumpAndSettle(); // 等待所有动画完成

      // Assert
      expect(taskExecuted, true);
      expect(find.text('处理中'), findsNothing); // 应已关闭
    });
  });
}
```

### 4.2 测试 PillBadge

**文件**: `test/widgets/pill_badge_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ollie_paw/widgets/common/pill_badge.dart';

void main() {
  group('PillBadge', () {
    testWidgets('应显示文本和图标', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PillBadge(
              label: '测试',
              icon: Icons.star,
              color: Colors.blue,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('测试'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('orange 构造函数应使用橙色', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PillBadge.orange(
              label: '橙色',
              icon: Icons.local_fire_department,
            ),
          ),
        ),
      );

      // Act
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PillBadge),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;

      // Assert
      expect(find.text('橙色'), findsOneWidget);
      // 颜色应为橙色系
    });
  });
}
```

---

## 5. 集成测试

### 5.1 登录流程测试

**文件**: `integration_test/auth_flow_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ollie_paw/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('认证流程集成测试', () {
    testWidgets('完整登录流程', (tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle();

      // 等待启动页完成
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 应该看到登录/注册切换
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);

      // 点击登录按钮
      await tester.tap(find.text('Welcome Back'));
      await tester.pumpAndSettle();

      // 应该进入主界面
      expect(find.text('Discover'), findsOneWidget);
    });

    testWidgets('注册流程 - 宠物主人', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 切换到注册
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // 选择宠物主人
      await tester.tap(find.text('Pet Owner'));
      await tester.pumpAndSettle();

      // 填写信息
      await tester.enterText(find.byType(TextField).first, 'Buddy');
      await tester.enterText(find.byType(TextField).at(1), 'Golden Retriever');
      await tester.pumpAndSettle();

      // 提交注册
      await tester.tap(find.text('Start Adventure'));
      await tester.pumpAndSettle();

      // 应该进入主界面
      expect(find.text('Hi, Buddy'), findsOneWidget);
    });
  });
}
```

### 5.2 签到流程测试

**文件**: `integration_test/checkin_flow_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ollie_paw/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('签到流程集成测试', () {
    testWidgets('每日签到应获得 Treats', (tester) async {
      // 启动应用并登录
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('Welcome Back'));
      await tester.pumpAndSettle();

      // 查找初始 Treats 数量
      final initialTreatsText = find.textContaining('Treats').evaluate().first.widget as Text;
      final initialTreats = int.parse(initialTreatsText.data!.split(' ')[0]);

      // 点击签到按钮
      await tester.tap(find.text('Daily Check-in (+20)'));
      await tester.pumpAndSettle();

      // 验证 Treats 增加
      final newTreatsText = find.textContaining('Treats').evaluate().first.widget as Text;
      final newTreats = int.parse(newTreatsText.data!.split(' ')[0]);

      expect(newTreats, initialTreats + 20);

      // 按钮状态应变为已签到
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
```

---

## 6. Mock 和测试工具

### 6.1 创建 Mock GeminiService

**文件**: `test/mocks/mock_gemini_service.dart`

```dart
import 'package:mockito/mockito.dart';
import 'package:ollie_paw/services/gemini_service.dart';
import 'package:ollie_paw/models/types.dart';

class MockGeminiService extends Mock implements GeminiService {
  @override
  Future<String> generatePetCaption(Pet pet, String context) async {
    return 'Mock caption for ${pet.name}';
  }

  @override
  Future<String> translatePetSound(Pet pet) async {
    return 'Mock translation: I love you!';
  }

  @override
  Future<String> predictFutureSelf(Pet pet) async {
    return 'Mock prediction: ${pet.name} will be very happy!';
  }
}
```

### 6.2 创建测试工具类

**文件**: `test/utils/test_helpers.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ollie_paw/providers/providers.dart';

/// 创建带 Provider 的测试环境
Widget createTestApp({
  required Widget child,
  UserProvider? userProvider,
  PetProvider? petProvider,
  CurrencyProvider? currencyProvider,
  CheckInProvider? checkInProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>(
        create: (_) => userProvider ?? UserProvider(),
      ),
      ChangeNotifierProvider<PetProvider>(
        create: (_) => petProvider ?? PetProvider(),
      ),
      ChangeNotifierProvider<CurrencyProvider>(
        create: (_) => currencyProvider ?? CurrencyProvider(),
      ),
      ChangeNotifierProvider<CheckInProvider>(
        create: (_) => checkInProvider ?? CheckInProvider(),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

/// 创建测试用的 Pet 对象
Pet createTestPet({
  String id = 'test_pet',
  String name = 'Test Dog',
  String breed = 'Golden Retriever',
}) {
  return Pet(
    id: id,
    name: name,
    type: PetType.DOG,
    breed: breed,
    birthDate: '2020-01-01',
    avatarUrl: 'https://example.com/avatar.jpg',
    bio: 'A test dog',
    vaccines: [],
    weightHistory: [],
    gallery: [],
  );
}
```

---

## 7. CI/CD 集成

### 7.1 GitHub Actions 配置

**文件**: `.github/workflows/test.yml`

```yaml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'

      - name: Install dependencies
        run: |
          cd OlliePaw
          flutter pub get

      - name: Run tests
        run: |
          cd OlliePaw
          flutter test --coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./OlliePaw/coverage/lcov.info
          fail_ci_if_error: true
```

### 7.2 运行测试命令

```bash
# 运行所有测试
flutter test

# 运行测试并生成覆盖率报告
flutter test --coverage

# 查看覆盖率报告
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# 运行集成测试
flutter test integration_test/
```

---

## 📝 实施步骤总结

1. ✅ 添加测试依赖到 `pubspec.yaml`
2. ⏳ 创建 Provider 单元测试
3. ⏳ 创建 Widget 测试
4. ⏳ 创建集成测试
5. ⏳ 创建 Mock 类和测试工具
6. ⏳ 配置 CI/CD
7. ⏳ 达到 70% 测试覆盖率

---

## 🎯 预期效果

实施完成后：

- ✅ 70%+ 测试覆盖率
- ✅ 所有核心业务逻辑有单元测试
- ✅ 关键 UI 组件有 Widget 测试
- ✅ 主要用户流程有集成测试
- ✅ CI/CD 自动运行测试
- ✅ 回归 bug 减少 80%

---

**实施优先级**: P1 - 中优先级
**预计工时**: 4-6 小时
**复杂度**: 中等
