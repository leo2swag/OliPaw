# Firebase 集成前检查清单

**目标**: 确保在迁移到 Firebase 前，代码库处于最佳状态
**当前版本**: v2.5
**最后更新**: 2025-12-29

---

## ✅ 已解决的阻塞问题

以下问题已在之前的迭代中解决，参考 `FIREBASE_BLOCKERS_RESOLVED.md`：

### 1. ✅ 认证系统准备完毕
- ✅ 创建 AuthProvider 包装认证逻辑
- ✅ 实现 Mock AuthService (测试用)
- ✅ login_screen 和 signup_screen 已就绪
- ✅ 表单验证集中到 AppConstants

**下一步**: 将 AuthService 实现替换为 Firebase Authentication

### 2. ✅ 数据模型元数据字段
- ✅ UserProfile 和 Pet 模型已包含 createdAt/updatedAt
- ✅ 使用 ISO 8601 格式存储日期
- ✅ Hive 模型生成完毕

**下一步**: 迁移到 Firestore 时保持字段兼容

### 3. ✅ 可变字段处理
- ✅ Treats、签到状态已移至独立 Provider
- ✅ 不再存储在 Pet/UserProfile 中
- ✅ 使用 SharedPreferences 临时存储

**下一步**: 迁移到 Firestore 子集合或单独文档

---

## 🎯 Firebase 准备状态

### 架构准备度: ✅ 95%

| 组件 | 状态 | Firebase 兼容性 |
|------|------|----------------|
| AuthProvider | ✅ 已实现 | 接口兼容 |
| UserProvider | ✅ 已实现 | 需迁移到 Firestore |
| PetProvider | ✅ 已实现 | 需迁移到 Firestore |
| CurrencyProvider | ✅ 已实现 | 需迁移到 Firestore |
| CheckInProvider | ✅ 已实现 | 需迁移到 Firestore |

### 数据模型准备度: ✅ 90%

| 模型 | Hive | Firestore 就绪 | 需要调整 |
|------|------|---------------|---------|
| UserProfile | ✅ | ✅ | userId 字段映射 |
| Pet | ✅ | ✅ | userId 外键关联 |
| Post | ✅ | ✅ | 添加 userId |
| Vaccine | ✅ | ✅ | 子集合结构 |
| WeightRecord | ✅ | ✅ | 子集合结构 |

---

## 📋 迁移前检查清单

### Phase 1: 代码准备 ✅ 已完成

- [x] 拆分 AppState 为独立 Providers
- [x] 创建 AuthProvider 认证抽象层
- [x] 实现 Mock AuthService
- [x] 添加 userId 到所有数据模型
- [x] 元数据字段 (createdAt/updatedAt)
- [x] 表单验证器集中管理
- [x] 错误处理统一 (SnackBarHelper)

### Phase 2: 依赖配置 ⏳ 待实施

- [ ] 添加 Firebase 依赖到 pubspec.yaml
  ```yaml
  dependencies:
    firebase_core: ^latest
    firebase_auth: ^latest
    cloud_firestore: ^latest
    firebase_storage: ^latest
  ```

- [ ] iOS 配置
  - [ ] 下载 GoogleService-Info.plist
  - [ ] 配置 Info.plist

- [ ] Android 配置
  - [ ] 下载 google-services.json
  - [ ] 配置 build.gradle
  - [ ] 添加 multidex 支持

- [ ] Web 配置 (可选)
  - [ ] 添加 Firebase SDK scripts
  - [ ] 配置 firebase-config.js

### Phase 3: Firebase 项目设置 ⏳ 待实施

- [ ] 创建 Firebase 项目
- [ ] 启用 Authentication
  - [ ] Email/Password 登录
  - [ ] (可选) Google 登录
  - [ ] (可选) Apple 登录

- [ ] 启用 Firestore Database
  - [ ] 创建数据库 (生产模式)
  - [ ] 配置 Security Rules

- [ ] 启用 Cloud Storage
  - [ ] 配置存储桶
  - [ ] 配置 Security Rules

### Phase 4: 认证迁移 ⏳ 待实施

- [ ] 替换 AuthService Mock 实现
  ```dart
  class AuthService {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // 替换 Mock 实现为 Firebase 实现
    Future<AuthUser?> signIn({required String email, required String password}) async {
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return _mapFirebaseUser(credential.user);
      } catch (e) {
        // 错误处理
      }
    }
  }
  ```

- [ ] 测试注册流程
- [ ] 测试登录流程
- [ ] 测试登出流程
- [ ] 测试密码重置

### Phase 5: Firestore 迁移 ⏳ 待实施

参考 `FIREBASE_MIGRATION_GUIDE.md` 获取详细步骤。

**数据结构**:
```
users (collection)
  └── {userId} (document)
      ├── name: string
      ├── email: string
      ├── createdAt: timestamp
      └── pets (subcollection)
          └── {petId} (document)
              ├── name: string
              ├── breed: string
              ├── vaccines (subcollection)
              └── weightRecords (subcollection)

posts (collection)
  └── {postId} (document)
      ├── userId: string
      ├── content: string
      ├── createdAt: timestamp
      └── comments (subcollection)

currency (collection)
  └── {userId} (document)
      ├── treats: number
      └── lastUpdated: timestamp

checkins (collection)
  └── {userId} (document)
      ├── lastCheckIn: string
      └── streak: number
```

- [ ] 实现 Firestore 服务层
- [ ] 迁移 UserProvider 到 Firestore
- [ ] 迁移 PetProvider 到 Firestore
- [ ] 迁移 CurrencyProvider 到 Firestore
- [ ] 迁移 CheckInProvider 到 Firestore

### Phase 6: Storage 迁移 ⏳ 待实施

- [ ] 实现照片上传到 Cloud Storage
- [ ] 实现视频上传到 Cloud Storage
- [ ] 更新 Post 模型使用 Storage URLs
- [ ] 实现照片删除

### Phase 7: 安全性 ⏳ 待实施

- [ ] 配置 Firestore Security Rules
  ```javascript
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      // 用户只能访问自己的数据
      match /users/{userId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;

        // 宠物子集合
        match /pets/{petId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }

      // 帖子公开可读，但只能作者修改
      match /posts/{postId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null;
        allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
      }
    }
  }
  ```

- [ ] 配置 Storage Security Rules
  ```javascript
  rules_version = '2';
  service firebase.storage {
    match /b/{bucket}/o {
      match /users/{userId}/{allPaths=**} {
        allow read: if request.auth != null;
        allow write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
  ```

- [ ] 环境变量保护 API Keys
- [ ] 实现速率限制
- [ ] 添加数据验证规则

### Phase 8: 测试 ⏳ 待实施

- [ ] 单元测试覆盖 Firestore 服务
- [ ] 集成测试覆盖认证流程
- [ ] 端到端测试覆盖主要用户流程
- [ ] 性能测试 (Firestore 查询优化)
- [ ] 安全规则测试

### Phase 9: 数据迁移 ⏳ 待实施

- [ ] 导出现有 Hive 数据
- [ ] 编写迁移脚本
- [ ] 测试迁移流程 (开发环境)
- [ ] 执行生产迁移
- [ ] 验证数据完整性

### Phase 10: 监控和优化 ⏳ 待实施

- [ ] 配置 Firebase Analytics
- [ ] 配置 Crashlytics
- [ ] 配置 Performance Monitoring
- [ ] 优化 Firestore 查询索引
- [ ] 实现离线支持

---

## ⚠️ 已知风险

### 高风险
1. **数据丢失风险**
   - 缓解: 完整备份 Hive 数据
   - 缓解: 测试环境先迁移
   - 缓解: 实施双写策略 (Hive + Firestore)

2. **认证迁移中断**
   - 缓解: Mock → Firebase 平滑切换
   - 缓解: AuthProvider 抽象层已就绪
   - 缓解: 保留 Mock 实现作为回退

### 中风险
3. **成本超支**
   - 缓解: 使用 Firestore 免费额度
   - 缓解: 实施查询优化
   - 缓解: 配置预算告警

4. **性能下降**
   - 缓解: 离线缓存策略
   - 缓解: 索引优化
   - 缓解: 分页加载

### 低风险
5. **学习曲线**
   - 缓解: 参考详细迁移指南
   - 缓解: 小步迭代，逐步迁移

---

## 📚 参考文档

### 内部文档
- [Firebase 迁移指南](FIREBASE_MIGRATION_GUIDE.md) - 详细的 7 阶段迁移计划
- [Firebase 阻塞问题解决](FIREBASE_BLOCKERS_RESOLVED.md) - 历史问题记录
- [项目状态](PROJECT_STATUS.md) - 当前架构概览
- [测试指南](TESTING_GUIDE.md) - 测试框架

### Firebase 官方文档
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [Firebase Authentication](https://firebase.google.com/docs/auth/flutter/start)
- [Cloud Firestore](https://firebase.google.com/docs/firestore/quickstart)
- [Cloud Storage](https://firebase.google.com/docs/storage/flutter/start)
- [Security Rules](https://firebase.google.com/docs/rules)

---

## 🎯 建议的迁移顺序

1. ✅ **准备阶段** (已完成)
   - 架构优化
   - Mock 认证实现
   - 数据模型准备

2. ⏳ **认证迁移** (第1周)
   - Firebase 项目设置
   - Authentication 配置
   - AuthService 替换

3. ⏳ **用户数据迁移** (第2-3周)
   - UserProvider → Firestore
   - PetProvider → Firestore

4. ⏳ **功能数据迁移** (第4-5周)
   - CurrencyProvider → Firestore
   - CheckInProvider → Firestore
   - Posts → Firestore

5. ⏳ **存储迁移** (第6周)
   - Cloud Storage 集成
   - 照片/视频上传

6. ⏳ **测试和优化** (第7-8周)
   - 安全规则配置
   - 性能优化
   - 全面测试

---

**准备状态**: ✅ 95% 完成
**预计迁移时间**: 6-8 周
**风险级别**: 中等（已有充分准备）

**维护者**: OlliePaw 开发团队
**文档版本**: v2.5
**最后更新**: 2025-12-29
