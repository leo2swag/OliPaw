# API Key 安全处理指南 (.env 文件)

本文档提供完整的 API Key 安全处理方案，使用 `.env` 文件和 `flutter_dotenv` 包。

---

## 📋 目录

1. [为什么需要 .env 文件](#1-为什么需要-env-文件)
2. [依赖配置](#2-依赖配置)
3. [创建 .env 文件](#3-创建-env-文件)
4. [配置 .gitignore](#4-配置-gitignore)
5. [代码实现](#5-代码实现)
6. [团队协作](#6-团队协作)

---

## 1. 为什么需要 .env 文件

### ❌ 当前问题

```dart
// lib/services/gemini_service.dart
class GeminiService {
  final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'YOUR_GEMINI_API_KEY', // ⚠️ 硬编码在代码中！
  );
}
```

**风险**:
- ❌ API Key 暴露在 Git 历史中
- ❌ 任何访问代码的人都能看到 Key
- ❌ 无法为不同环境使用不同 Key
- ❌ Key 泄露后需要修改代码重新部署

### ✅ 使用 .env 文件后

```dart
class GeminiService {
  final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: dotenv.env['GEMINI_API_KEY']!, // ✅ 从环境变量读取
  );
}
```

**优势**:
- ✅ API Key 不会提交到 Git
- ✅ 每个开发者使用自己的 Key
- ✅ 生产/开发环境可用不同 Key
- ✅ Key 泄露只需更换 .env 文件

---

## 2. 依赖配置

### 2.1 添加依赖

**文件**: `pubspec.yaml`

```yaml
dependencies:
  # 现有依赖...

  # 环境变量管理
  flutter_dotenv: ^5.1.0
```

### 2.2 配置资源文件

在 `pubspec.yaml` 的 `flutter` 部分添加：

```yaml
flutter:
  # 现有配置...

  assets:
    # 现有资源...
    - .env  # 添加 .env 文件到资源中
```

### 2.3 安装依赖

```bash
cd OlliePaw
flutter pub get
```

---

## 3. 创建 .env 文件

### 3.1 创建 .env 文件

**文件**: `OlliePaw/.env`

```env
# Gemini AI API Key
# 获取地址: https://makersuite.google.com/app/apikey
GEMINI_API_KEY=your_actual_gemini_api_key_here

# 其他可能的 API Keys（未来扩展）
# FIREBASE_API_KEY=your_firebase_key
# STRIPE_PUBLISHABLE_KEY=your_stripe_key
```

### 3.2 创建 .env.example 文件（模板）

**文件**: `OlliePaw/.env.example`

```env
# Gemini AI API Key
# 获取地址: https://makersuite.google.com/app/apikey
GEMINI_API_KEY=YOUR_KEY_HERE

# 说明:
# 1. 复制此文件为 .env
# 2. 将 YOUR_KEY_HERE 替换为你的实际 API Key
# 3. 不要将 .env 文件提交到 Git
```

**用途**:
- 提交到 Git 作为配置模板
- 新开发者可以复制此文件创建自己的 `.env`

---

## 4. 配置 .gitignore

**文件**: `OlliePaw/.gitignore`

```gitignore
# 现有规则...

# 环境变量文件 - 包含敏感信息，不要提交
.env

# 但保留模板文件
!.env.example
```

**验证配置**:

```bash
# 检查 .env 是否被忽略
git status

# 应该看不到 .env 文件
# 但能看到 .env.example
```

---

## 5. 代码实现

### 5.1 更新 main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// ... 其他导入

/// 应用程序入口
///
/// 加载 .env 文件并初始化应用
Future<void> main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 加载 .env 文件
  await dotenv.load(fileName: ".env");

  // 验证必需的环境变量
  _validateEnvironmentVariables();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => CheckInProvider()),
      ],
      child: const OlliePawApp(),
    ),
  );
}

/// 验证必需的环境变量
void _validateEnvironmentVariables() {
  final requiredKeys = ['GEMINI_API_KEY'];

  for (final key in requiredKeys) {
    if (dotenv.env[key] == null || dotenv.env[key]!.isEmpty) {
      throw Exception(
        '缺少必需的环境变量: $key\n'
        '请确保 .env 文件存在并包含此变量。\n'
        '参考 .env.example 文件。'
      );
    }
  }
}
```

### 5.2 更新 GeminiService

**文件**: `lib/services/gemini_service.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/types.dart';

/// Gemini AI 服务
///
/// 安全地从环境变量加载 API Key
class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    // 从 .env 文件读取 API Key
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'Gemini API Key 未配置！\n'
        '请在 .env 文件中设置 GEMINI_API_KEY。'
      );
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  // ... 其他方法保持不变
}
```

### 5.3 创建环境配置类（可选）

**文件**: `lib/core/config/env_config.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 环境配置
///
/// 集中管理所有环境变量
class EnvConfig {
  // 私有构造函数，防止实例化
  EnvConfig._();

  // ==========================================================================
  // API Keys
  // ==========================================================================

  /// Gemini AI API Key
  static String get geminiApiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GEMINI_API_KEY 未配置');
    }
    return key;
  }

  // ==========================================================================
  // 应用配置
  // ==========================================================================

  /// 是否为调试模式
  static bool get isDebugMode {
    return dotenv.env['DEBUG_MODE'] == 'true';
  }

  /// API 超时时间（秒）
  static int get apiTimeout {
    final timeout = dotenv.env['API_TIMEOUT'];
    return timeout != null ? int.tryParse(timeout) ?? 30 : 30;
  }

  // ==========================================================================
  // 验证
  // ==========================================================================

  /// 验证所有必需的环境变量
  static void validate() {
    final requiredKeys = [
      'GEMINI_API_KEY',
    ];

    final missing = <String>[];

    for (final key in requiredKeys) {
      if (dotenv.env[key] == null || dotenv.env[key]!.isEmpty) {
        missing.add(key);
      }
    }

    if (missing.isNotEmpty) {
      throw Exception(
        '缺少必需的环境变量: ${missing.join(', ')}\n'
        '请检查 .env 文件。参考 .env.example。'
      );
    }
  }
}
```

**使用示例**:

```dart
// 在 GeminiService 中
class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: EnvConfig.geminiApiKey, // 使用配置类
    );
  }
}

// 在 main.dart 中
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 验证环境变量
  EnvConfig.validate();

  runApp(const OlliePawApp());
}
```

---

## 6. 团队协作

### 6.1 新开发者入职流程

1. **克隆项目**:
   ```bash
   git clone <repository_url>
   cd ollie_paw/OlliePaw
   ```

2. **创建 .env 文件**:
   ```bash
   cp .env.example .env
   ```

3. **配置 API Key**:
   - 访问 https://makersuite.google.com/app/apikey
   - 创建自己的 Gemini API Key
   - 将 Key 填入 `.env` 文件

4. **运行应用**:
   ```bash
   flutter pub get
   flutter run
   ```

### 6.2 文档说明

在 `README.md` 中添加：

```markdown
## 🔑 配置 API Keys

本项目使用环境变量管理 API Keys。

### 首次设置

1. 复制环境变量模板：
   ```bash
   cp .env.example .env
   ```

2. 获取 Gemini API Key：
   - 访问 [Google AI Studio](https://makersuite.google.com/app/apikey)
   - 创建新的 API Key
   - 复制 Key

3. 更新 `.env` 文件：
   ```env
   GEMINI_API_KEY=your_actual_api_key_here
   ```

4. 安装依赖并运行：
   ```bash
   flutter pub get
   flutter run
   ```

### ⚠️ 注意事项

- **不要**将 `.env` 文件提交到 Git
- **不要**在代码中硬编码 API Key
- **不要**将 API Key 分享给他人
- 每个开发者应使用自己的 API Key
```

---

## 📝 实施步骤总结

1. ✅ 添加 `flutter_dotenv` 依赖到 `pubspec.yaml`
2. ✅ 配置 `assets` 包含 `.env`
3. ⏳ 创建 `.env` 文件（包含实际 API Key）
4. ⏳ 创建 `.env.example` 文件（模板）
5. ⏳ 更新 `.gitignore` 忽略 `.env`
6. ⏳ 更新 `main.dart` 加载 `.env`
7. ⏳ 更新 `GeminiService` 使用环境变量
8. ⏳ 创建 `EnvConfig` 类（可选）
9. ⏳ 更新 `README.md` 添加设置说明
10. ✅ 测试应用运行

---

## 🎯 预期效果

实施完成后：

- ✅ API Key 不会出现在 Git 历史中
- ✅ 每个开发者使用独立的 Key
- ✅ Key 泄露只需更换 .env 文件
- ✅ 支持多环境配置（开发/生产）
- ✅ 新开发者入职流程简单

---

## ⚠️ 安全最佳实践

1. **定期轮换 API Keys**: 每 3-6 个月更换一次
2. **限制 API Key 权限**: 只授予必需的权限
3. **监控 API 使用**: 设置使用量警报
4. **使用 Key 管理服务**: 生产环境考虑使用 AWS Secrets Manager / Google Secret Manager
5. **代码审查**: 确保没有 Key 被意外提交

---

## 🔧 故障排除

### 问题 1: "未找到 .env 文件"

**解决方案**:
```bash
# 确保 .env 文件在正确的位置
ls -la OlliePaw/.env

# 确保 pubspec.yaml 中配置了 assets
flutter clean
flutter pub get
```

### 问题 2: "API Key 无效"

**解决方案**:
- 检查 .env 文件中的 Key 是否正确
- 确保 Key 没有多余的空格
- 验证 Key 在 Google AI Studio 中是否激活

### 问题 3: "环境变量为空"

**解决方案**:
```dart
// 添加调试日志
print('Gemini Key: ${dotenv.env['GEMINI_API_KEY']}');

// 确保 dotenv.load() 在使用前调用
await dotenv.load(fileName: ".env");
```

---

**实施优先级**: P0 - 高优先级（安全相关）
**预计工时**: 1 小时
**复杂度**: 简单
