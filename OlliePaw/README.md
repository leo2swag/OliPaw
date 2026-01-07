# OlliePaw 🐾

A pet-centric social network built with Flutter.

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

## 📱 功能特性

- 宠物档案管理
- AI 驱动的内容生成
- 每日签到系统
- Treats 货币系统
- 社交动态分享

## 🏗️ 架构

本项目使用模块化的 Provider 状态管理：
- `UserProvider` - 用户认证和启动流程
- `PetProvider` - 宠物档案管理
- `CurrencyProvider` - Treats 货币系统
- `CheckInProvider` - 每日签到系统
- `AuthProvider` - Firebase 认证准备 (v2.5)

## 📚 文档

### 新手入门 ⭐
- [代码结构指南](../CODE_STRUCTURE_GUIDE.md) - **新开发者必读** - 快速理解项目架构和文件关系
- [项目状态总览](../PROJECT_STATUS.md) - 当前版本状态和架构

### 代码规范
- [中文注释指南](CHINESE_COMMENTS_GUIDE.md) - 代码注释规范

### Firebase 集成
- [Firebase 迁移指南](../FIREBASE_MIGRATION_GUIDE.md) - 详细迁移步骤
- [Firebase 集成准备](../PRE_FIREBASE_CHECKLIST.md) - 迁移前检查清单
- [Firebase 问题解决](../FIREBASE_BLOCKERS_RESOLVED.md) - 已解决的阻塞问题

### 技术指南
- [API Key 安全指南](../API_KEY_SECURITY_GUIDE.md) - 环境变量管理
- [性能优化指南](../PERFORMANCE_GUIDE.md) - 性能优化实践
- [数据持久化指南](../PERSISTENCE_GUIDE.md) - Hive + SharedPreferences
- [测试指南](../TESTING_GUIDE.md) - 测试框架和示例

## 📄 License

This project is a starting point for a Flutter application.
