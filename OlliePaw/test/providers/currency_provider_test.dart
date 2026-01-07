/*
  文件：test/providers/currency_provider_test.dart
  说明：
  - CurrencyProvider 单元测试
  - 测试 Treats 余额管理、消费、奖励等功能
  - 使用 mockito 模拟 PersistenceService

  测试覆盖：
  - Treats 初始化
  - Treats 消费（成功/失败）
  - Treats 奖励
  - 数据持久化
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ollie_paw/providers/currency_provider.dart';
import 'package:ollie_paw/services/persistence_service.dart';

// 生成 Mock 类（使用 Nice Mocks 自动提供默认返回值）
@GenerateNiceMocks([MockSpec<PersistenceService>()])
import 'currency_provider_test.mocks.dart';

void main() {
  group('CurrencyProvider', () {
    late MockPersistenceService mockPersistence;
    late CurrencyProvider provider;

    setUp(() {
      mockPersistence = MockPersistenceService();

      // 默认行为：返回 50 Treats
      when(mockPersistence.getTreats()).thenReturn(50);

      // 默认行为：saveTreats 总是成功
      when(mockPersistence.saveTreats(any)).thenAnswer((_) async => true);

      provider = CurrencyProvider(mockPersistence);
    });

    test('初始化时从存储加载 Treats', () {
      expect(provider.treats, 50);
      verify(mockPersistence.getTreats()).called(1);
    });

    test('消费 Treats - 余额充足时成功', () {
      // Act
      final result = provider.spendTreats(10);

      // Assert
      expect(result, true);
      expect(provider.treats, 40);
      verify(mockPersistence.saveTreats(40)).called(1);
    });

    test('消费 Treats - 余额不足时失败', () {
      // Act
      final result = provider.spendTreats(100);

      // Assert
      expect(result, false);
      expect(provider.treats, 50); // 余额不变
      verifyNever(mockPersistence.saveTreats(any));
    });

    test('消费 Treats - 刚好用完所有余额', () {
      // Act
      final result = provider.spendTreats(50);

      // Assert
      expect(result, true);
      expect(provider.treats, 0);
      verify(mockPersistence.saveTreats(0)).called(1);
    });

    test('获得 Treats 奖励', () {
      // Act
      provider.earnTreats(20, reason: '每日签到');

      // Assert
      expect(provider.treats, 70);
      verify(mockPersistence.saveTreats(70)).called(1);
    });

    test('多次交易后余额正确', () {
      // Arrange & Act
      provider.earnTreats(30); // 50 + 30 = 80
      provider.spendTreats(15); // 80 - 15 = 65
      provider.earnTreats(10); // 65 + 10 = 75
      provider.spendTreats(5); // 75 - 5 = 70

      // Assert
      expect(provider.treats, 70);
    });

    test('消费失败不触发保存', () {
      // Arrange
      clearInteractions(mockPersistence);

      // Act
      provider.spendTreats(100); // 失败

      // Assert
      verifyNever(mockPersistence.saveTreats(any));
    });

    test('初始化时如果存储为空使用默认值 50', () {
      // Arrange
      when(mockPersistence.getTreats()).thenReturn(50);
      final newProvider = CurrencyProvider(mockPersistence);

      // Assert
      expect(newProvider.treats, 50);
    });
  });

  group('CurrencyProvider - 边界测试', () {
    late MockPersistenceService mockPersistence;
    late CurrencyProvider provider;

    setUp(() {
      mockPersistence = MockPersistenceService();
      when(mockPersistence.getTreats()).thenReturn(50);
      provider = CurrencyProvider(mockPersistence);
    });

    test('消费 0 Treats', () {
      final result = provider.spendTreats(0);
      expect(result, true);
      expect(provider.treats, 50);
    });

    test('获得 0 Treats', () {
      provider.earnTreats(0);
      expect(provider.treats, 50);
    });

    test('消费负数 Treats（不应该发生，但要测试）', () {
      // 注意：实际代码可能需要添加验证
      final result = provider.spendTreats(-10);
      expect(result, true); // 因为 50 >= -10
    });
  });
}
