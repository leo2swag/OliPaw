# OlliePaw 代码结构指南

**目标读者**: 新加入项目的开发者
**用途**: 快速了解项目架构、文件组织和组件关系
**版本**: v2.5
**最后更新**: 2025-12-29

---

## 📋 目录

1. [项目总览](#项目总览)
2. [架构图](#架构图)
3. [核心概念](#核心概念)
4. [目录结构详解](#目录结构详解)
5. [数据流向](#数据流向)
6. [共享组件](#共享组件)
7. [快速开始](#快速开始)
8. [常见开发场景](#常见开发场景)

---

## 项目总览

OlliePaw 是一个基于 Flutter 的宠物社交应用，采用 **Provider 状态管理** 和 **模块化架构**。

### 技术栈
- **框架**: Flutter 3.x
- **状态管理**: Provider (ChangeNotifier)
- **本地存储**: Hive + SharedPreferences
- **AI 服务**: Google Gemini API
- **认证**: Mock Auth (准备迁移 Firebase)

### 核心功能
- 🐾 宠物档案管理 (健康追踪、疫苗记录、体重管理)
- 💰 Treats 虚拟货币系统
- 📱 社交动态发布与互动
- 🤖 AI 驱动的内容生成
- ✅ 每日签到系统

---

## 架构图

```
┌─────────────────────────────────────────────────────────────┐
│                         main.dart                           │
│                     (应用程序入口)                            │
│                                                             │
│  ┌───────────────────────────────────────────────────┐    │
│  │              MultiProvider                        │    │
│  │  ┌──────────────────────────────────────────┐    │    │
│  │  │  ChangeNotifierProvider (5个)             │    │    │
│  │  │  - UserProvider                           │    │    │
│  │  │  - PetProvider                            │    │    │
│  │  │  - CurrencyProvider                       │    │    │
│  │  │  - CheckInProvider                        │    │    │
│  │  │  - AuthProvider                           │    │    │
│  │  └──────────────────────────────────────────┘    │    │
│  │                                                   │    │
│  │  Provider (2个服务)                               │    │
│  │  - GeminiService                                 │    │
│  │  - PersistenceService                            │    │
│  │                                                   │    │
│  └───────────────────────────────────────────────────┘    │
│                          │                                 │
│                          ▼                                 │
│              ┌─────────────────────┐                      │
│              │   MaterialApp       │                      │
│              │   (路由和主题)        │                      │
│              └─────────────────────┘                      │
│                          │                                 │
│         ┌────────────────┼────────────────┐              │
│         ▼                ▼                ▼              │
│  SplashScreen    LoginScreen      MainLayout             │
│   (启动页)        (登录页)        (主布局)                   │
│                                    │                      │
│                     ┌──────────────┼──────────────┐      │
│                     ▼              ▼              ▼      │
│                HomeScreen    CareScreen    ProfileScreen │
│                                                           │
└─────────────────────────────────────────────────────────────┘
```

---

## 核心概念

### 1. Provider 状态管理

**什么是 Provider?**
- Flutter 官方推荐的状态管理方案
- 基于 InheritedWidget，向下传递状态
- 使用 ChangeNotifier 通知 UI 更新

**核心方法**:
```dart
// 读取状态 (会触发重建)
final treats = context.watch<CurrencyProvider>().treats;

// 调用方法 (不触发重建)
context.read<CurrencyProvider>().spend(5);

// 监听特定属性 (仅该属性变化时重建)
final treats = context.select<CurrencyProvider, int>((p) => p.treats);
```

### 2. 模块化架构

每个 Provider 负责单一职责:
- **UserProvider**: 用户认证状态
- **PetProvider**: 宠物档案管理
- **CurrencyProvider**: Treats 货币
- **CheckInProvider**: 签到系统
- **AuthProvider**: Firebase 认证

### 3. 数据持久化

**两层存储策略**:
```
复杂对象 (Pet, User) → Hive (NoSQL 数据库)
简单值 (Treats, 签到) → SharedPreferences (Key-Value)
```

---

## 目录结构详解

```
lib/
├── main.dart                          # 入口文件 (配置 Provider 和路由)
│
├── core/                              # 核心配置和工具
│   ├── constants/                     # 常量定义
│   │   ├── app_constants.dart        # 应用常量 + 表单验证器
│   │   └── pricing.dart              # Treats 定价
│   ├── theme/                         # 主题系统
│   │   ├── app_colors.dart           # 颜色常量
│   │   ├── app_dimensions.dart       # 尺寸常量
│   │   └── app_input_decoration.dart # 输入框样式 (v2.5)
│   ├── enums/                         # 枚举类型
│   │   └── media_type.dart
│   ├── models/                        # 核心数据模型
│   │   └── post_options.dart
│   ├── exceptions/                    # 异常定义
│   │   └── gemini_exceptions.dart
│   ├── extensions/                    # 扩展方法
│   │   └── date_extensions.dart
│   └── result.dart                   # 类型安全的错误处理
│
├── models/                            # 数据模型层
│   ├── types.dart                    # 核心业务模型 (User, Pet, Post, etc.)
│   ├── user_hive_model.dart          # Hive 用户模型
│   └── pet_hive_model.dart           # Hive 宠物模型
│
├── providers/                         # 状态管理层 ⭐ 核心
│   ├── providers.dart                # 桶文件 (统一导出)
│   ├── user_provider.dart            # 用户认证状态
│   ├── pet_provider.dart             # 宠物档案管理
│   ├── currency_provider.dart        # Treats 货币系统
│   ├── checkin_provider.dart         # 每日签到
│   ├── auth_provider.dart            # Firebase 认证 (v2.5)
│   └── app_state.dart                # 遗留 (向后兼容)
│
├── services/                          # 业务逻辑层
│   ├── persistence_service.dart      # 数据持久化服务
│   ├── auth_service.dart             # 认证服务 (Mock)
│   └── gemini_service.dart           # AI 服务 (Gemini API)
│
├── screens/                           # 页面层
│   ├── auth/                         # 认证页面
│   │   ├── login_screen.dart         # 登录页
│   │   └── signup_screen.dart        # 注册页
│   ├── home/                         # Home 子组件
│   │   ├── checkin_button.dart
│   │   ├── treats_badge.dart
│   │   └── welcome_header.dart
│   ├── main_layout.dart              # 主布局 (底部导航)
│   ├── splash_screen.dart            # 启动页
│   ├── home_screen.dart              # 首页 (动态流)
│   ├── profile_screen.dart           # 个人档案
│   ├── care_screen.dart              # 健康追踪
│   ├── create_post_screen.dart       # 创建动态
│   └── explore_screen.dart           # 探索页
│
├── widgets/                           # UI 组件层
│   ├── common/                       # 通用组件
│   │   ├── loading_overlay.dart      # 加载蒙层
│   │   ├── empty_state.dart          # 空状态
│   │   ├── pill_badge.dart           # 药丸徽章
│   │   ├── app_dialog.dart           # 对话框
│   │   ├── app_button.dart           # 按钮
│   │   └── chat_bubble.dart          # 聊天气泡
│   ├── home/                         # Home 专用组件
│   ├── password_form_field.dart      # 密码输入 (v2.5)
│   ├── add_vaccine_dialog.dart       # 疫苗记录表单
│   ├── add_weight_dialog.dart        # 体重记录表单
│   ├── health_tracker.dart           # 健康追踪组件
│   ├── feed_card.dart                # 动态卡片
│   └── comments_bottom_sheet.dart    # 评论系统
│
├── utils/                             # 工具类层
│   ├── utils.dart                    # 桶文件
│   ├── date_utils.dart               # 日期工具
│   ├── chart_utils.dart              # 图表工具
│   ├── snackbar_helper.dart          # 通知工具 (v2.5)
│   ├── photo_picker_helper.dart      # 照片选择
│   └── mock_data.dart                # 模拟数据
│
└── theme/                             # 全局主题
    ├── app_theme.dart                # 主题定义
    └── theme.dart                    # 桶文件
```

---

## 数据流向

### 用户登录流程

```
1. 用户操作
   LoginScreen (输入邮箱密码)
          ↓
2. 表单验证
   AppConstants.validateEmail()
   AppConstants.validatePassword()
          ↓
3. 调用 Provider
   context.read<AuthProvider>().signIn(email, password)
          ↓
4. Provider 调用 Service
   AuthProvider → AuthService.signIn()
          ↓
5. Service 处理业务逻辑
   AuthService (验证凭据, 创建 AuthUser)
          ↓
6. Provider 更新状态
   AuthProvider.notifyListeners()
          ↓
7. UI 自动重建
   Consumer<AuthProvider> 监听到变化
          ↓
8. 导航到主页
   Navigator.pushReplacementNamed('/home')
```

### 发布动态流程

```
1. 用户操作
   CreatePostScreen (填写文案、选择照片)
          ↓
2. AI 文案生成 (可选)
   GeminiService.generatePetCaption()
   CurrencyProvider.spend(5) // 扣除 5 Treats
          ↓
3. 提交动态
   PetProvider.addPost(post)
          ↓
4. 数据持久化
   PersistenceService.savePet(updatedPet)
          ↓
5. UI 更新
   PetProvider.notifyListeners()
   HomeScreen 监听到新动态
```

### Treats 消费流程

```
1. 功能请求 (如 AI 生成)
   用户点击 "Generate Caption"
          ↓
2. 检查余额
   CurrencyProvider.canSpend(5)
          ↓
3. 扣除 Treats
   CurrencyProvider.spend(5)
     ├─ 余额充足 → true
     │    ├─ _treats -= 5
     │    ├─ 保存到 SharedPreferences
     │    └─ notifyListeners()
     │
     └─ 余额不足 → false
          └─ SnackBarHelper.showError("余额不足")
```

---

## 共享组件

### 表单组件 (v2.5 新增)

#### 1. AppInputDecoration
**位置**: `lib/core/theme/app_input_decoration.dart`

**用途**: 统一所有输入框样式

**工厂方法**:
```dart
// 标准输入框
AppInputDecoration.standard(
  labelText: 'Email',
  hintText: 'Enter your email',
  prefixIcon: Icons.email_outlined,
)

// 多行文本
AppInputDecoration.textArea(
  labelText: 'Bio',
  hintText: 'Tell us about yourself',
)

// 紧凑型 (对话框)
AppInputDecoration.compact(
  labelText: 'Name',
)
```

**依赖关系**:
- 被 `login_screen.dart` 使用
- 被 `signup_screen.dart` 使用
- 被 `profile_screen.dart` 使用
- 被 `add_vaccine_dialog.dart` 使用

#### 2. PasswordFormField
**位置**: `lib/widgets/password_form_field.dart`

**用途**: 可复用的密码输入组件 (内置可见性切换)

**使用示例**:
```dart
PasswordFormField(
  controller: _passwordController,
  labelText: 'Password',
  hintText: 'At least 6 characters',
  validator: AppConstants.validatePassword,
)
```

**内部依赖**:
- 使用 `AppInputDecoration.standard()`
- 管理自己的 `_obscureText` 状态

**被使用于**:
- `login_screen.dart`
- `signup_screen.dart`

### 通知组件

#### SnackBarHelper
**位置**: `lib/utils/snackbar_helper.dart`

**用途**: 统一的通知提示系统

**方法**:
```dart
// 成功提示 (绿色)
SnackBarHelper.showSuccess(context, 'Login successful!');

// 错误提示 (红色)
SnackBarHelper.showError(context, 'Invalid credentials');

// 信息提示 (蓝色)
SnackBarHelper.showInfo(context, 'Password reset coming soon');

// 警告提示 (橙色)
SnackBarHelper.showWarning(context, 'Low Treats balance');
```

**被使用于**:
- 所有需要用户反馈的地方
- 替代了直接使用 `ScaffoldMessenger`

### 验证工具

#### AppConstants 验证器
**位置**: `lib/core/constants/app_constants.dart`

**方法**:
```dart
// 邮箱验证
AppConstants.validateEmail(value)

// 密码验证 (最少 6 位)
AppConstants.validatePassword(value)

// 确认密码验证
AppConstants.validateConfirmPassword(value, password)

// 名称验证
AppConstants.validateName(value)
```

**使用场景**:
- `TextFormField` 的 `validator` 参数
- 统一验证规则，易于维护

### UI 组件

#### AppButton
**位置**: `lib/widgets/common/app_button.dart`

**用途**: 统一的按钮样式

**类型**:
```dart
// 主按钮 (橙色)
AppButton.primary(
  text: 'Submit',
  onPressed: _handleSubmit,
  isLoading: _isLoading, // 自动显示加载状态
)

// 次按钮 (灰色)
AppButton.secondary(...)

// 边框按钮
AppButton.outline(...)

// 文本按钮
AppButton.text(...)
```

#### LoadingOverlay
**位置**: `lib/widgets/common/loading_overlay.dart`

**用途**: AI 功能的加载蒙层

**使用示例**:
```dart
LoadingOverlay(
  isLoading: _isGenerating,
  message: 'Generating caption...',
  child: YourWidget(),
)
```

#### EmptyState
**位置**: `lib/widgets/common/empty_state.dart`

**用途**: 列表无数据时的友好提示

**使用示例**:
```dart
EmptyState(
  icon: LucideIcons.inbox,
  title: 'No posts yet',
  subtitle: 'Start sharing your pet moments!',
)
```

### 业务组件

#### FeedCard
**位置**: `lib/widgets/feed_card.dart`

**用途**: 动态卡片 (显示宠物动态)

**功能**:
- 照片/视频展示
- 点赞动画
- 评论按钮
- 分享功能
- 用户信息展示

**依赖**:
- `CommentsBottomSheet` (评论系统)
- `CachedNetworkImage` (图片缓存)
- Provider: `PetProvider`, `UserProvider`

#### HealthTracker
**位置**: `lib/widgets/health_tracker.dart`

**用途**: 健康追踪组件 (疫苗、体重)

**功能**:
- 疫苗记录列表
- 体重图表
- AI 健康建议
- 添加记录按钮

**依赖**:
- `AddVaccineDialog`
- `AddWeightDialog`
- `GeminiService` (AI 建议)
- `PetProvider`

---

## Provider 详解

### 1. UserProvider
**文件**: `lib/providers/user_provider.dart`

**职责**:
- 用户登录/登出状态
- 当前用户信息
- 启动页完成标记

**核心状态**:
```dart
bool _splashFinished       // 启动页是否完成
UserProfile? _currentUser  // 当前用户
```

**核心方法**:
```dart
void login(UserProfile user)        // 登录
void logout()                        // 登出
void finishSplash()                  // 完成启动页
```

**数据持久化**:
- 自动从 `PersistenceService` 加载已登录用户
- 登出时清除本地存储

**被使用于**:
- `SplashScreen` (检查启动状态)
- `LoginScreen` (登录操作)
- `MainLayout` (获取用户信息)

---

### 2. PetProvider
**文件**: `lib/providers/pet_provider.dart`

**职责**:
- 宠物档案管理
- 当前选中宠物
- 宠物列表

**核心状态**:
```dart
Pet? _currentPet           // 当前宠物
List<Pet> _pets            // 所有宠物列表
```

**核心方法**:
```dart
void setCurrentPet(Pet pet)                    // 切换宠物
Future<void> updatePet(Pet pet)                // 更新宠物信息
void addPost(Post post)                        // 添加动态
void addVaccine(Vaccine vaccine)               // 添加疫苗记录
void addWeightRecord(WeightRecord record)      // 添加体重记录
```

**数据持久化**:
- 使用 Hive 存储完整的 Pet 对象
- 自动保存每次修改

**被使用于**:
- `ProfileScreen` (显示宠物信息)
- `CareScreen` (健康追踪)
- `HomeScreen` (显示动态)
- `CreatePostScreen` (发布动态)

---

### 3. CurrencyProvider
**文件**: `lib/providers/currency_provider.dart`

**职责**:
- Treats 货币管理
- 消费验证
- 余额追踪

**核心状态**:
```dart
int _treats = 50  // 初始 50 Treats
```

**核心方法**:
```dart
bool spend(int amount)      // 消费 Treats (带余额检查)
void earn(int amount)       // 获得 Treats
bool canSpend(int amount)   // 检查是否有足够余额
```

**数据持久化**:
- SharedPreferences 存储余额
- 每次交易自动保存

**消费场景**:
```dart
AI 文案生成:       5 Treats
AI 健康建议:      10 Treats
AI 兽医对话:      20 Treats/消息
汪声翻译:         15 Treats
未来自我预测:     25 Treats
```

**被使用于**:
- 所有 AI 功能调用前
- `HomeScreen` (显示余额)
- `CheckInButton` (签到奖励)

**测试覆盖**: ✅ 100% (11 个单元测试)

---

### 4. CheckInProvider
**文件**: `lib/providers/checkin_provider.dart`

**职责**:
- 每日签到管理
- 签到状态追踪
- 连续签到天数

**核心状态**:
```dart
String? _lastCheckIn  // 最后签到日期 (ISO 8601)
int _streak           // 连续签到天数
```

**核心方法**:
```dart
Future<bool> checkIn()    // 执行签到 (返回是否成功)
bool get canCheckIn       // 今天是否可以签到
```

**签到逻辑**:
```dart
1. 检查今天是否已签到
2. 如果可签到:
   - 增加 20 Treats (通过 CurrencyProvider)
   - 更新 _lastCheckIn
   - 计算连续签到天数
   - 保存到 SharedPreferences
   - notifyListeners()
```

**被使用于**:
- `CheckInButton` (HomeScreen 顶部)

---

### 5. AuthProvider
**文件**: `lib/providers/auth_provider.dart`

**职责**:
- Firebase 认证准备
- 登录/注册/登出
- 认证状态管理

**核心状态**:
```dart
AuthStatus _status                // 认证状态 (uninitialized/unauthenticated/authenticated)
AuthUser? _currentUser           // 当前认证用户
String? _errorMessage            // 错误消息
bool _isLoading                  // 加载状态
```

**核心方法**:
```dart
Future<bool> signIn({email, password})         // 登录
Future<bool> signUp({email, password, name})   // 注册
Future<void> signOut()                         // 登出
```

**认证流程**:
```dart
1. 调用 AuthService (当前是 Mock 实现)
2. 监听 AuthService 的认证状态流
3. 更新 _currentUser 和 _status
4. notifyListeners() 通知 UI
```

**被使用于**:
- `LoginScreen`
- `SignUpScreen`
- `MainLayout` (检查登录状态)

**未来**: 将 Mock AuthService 替换为 Firebase Authentication

---

## Provider 之间的关系

```
                    ┌─────────────────┐
                    │  UserProvider   │
                    │  (用户认证)       │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
     ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
     │ PetProvider │  │ Currency    │  │ CheckIn     │
     │ (宠物管理)    │  │ Provider    │  │ Provider    │
     │             │  │ (货币系统)    │  │ (签到系统)    │
     └─────────────┘  └──────┬──────┘  └──────┬──────┘
                             │                │
                             └────────┬───────┘
                                      ▼
                              互相调用关系:
                  CheckInProvider.checkIn()
                       ↓
                  CurrencyProvider.earn(20)
                       ↓
                  保存到 SharedPreferences
```

**关键关系**:
1. **UserProvider** 独立运作，不依赖其他 Provider
2. **PetProvider** 使用 UserProvider 获取当前用户 ID
3. **CheckInProvider** 调用 **CurrencyProvider** 发放签到奖励
4. **所有 Provider** 通过 `PersistenceService` 持久化数据

---

## 服务层详解

### PersistenceService
**文件**: `lib/services/persistence_service.dart`

**职责**: 统一的数据持久化接口

**存储策略**:
```dart
Hive (NoSQL 数据库):
  - UserProfile (复杂对象)
  - Pet (复杂对象, 包含子对象)

SharedPreferences (Key-Value):
  - Treats 余额
  - 签到日期
  - 当前用户 ID
  - 当前宠物 ID
```

**核心方法**:
```dart
// Hive 操作
Future<void> saveUser(UserProfile user)
UserProfile? getUser(String userId)
Future<void> savePet(Pet pet)
Pet? getPet(String petId)

// SharedPreferences 操作
Future<void> saveTreats(int treats)
int? getTreats()
Future<void> saveLastCheckIn(String date)
String? getLastCheckIn()
```

**初始化流程**:
```dart
1. 初始化 Hive
2. 注册 TypeAdapter (UserHiveModel, PetHiveModel)
3. 打开 boxes
4. 初始化 SharedPreferences
```

---

### GeminiService
**文件**: `lib/services/gemini_service.dart`

**职责**: 所有 AI 功能的统一入口

**核心方法**:
```dart
Future<String> generatePetCaption({...})     // 生成宠物文案
Future<String> analyzeHealthTip({...})       // 健康建议
Future<String> chatWithVet(String message)   // AI 兽医对话
Future<String> translatePetSound({...})      // 汪/喵声翻译
Future<String> predictFutureSelf({...})      // 未来自我预测
```

**调用流程**:
```dart
1. 检查 API Key (从 .env 加载)
2. 构建 Prompt (针对不同功能)
3. 调用 Gemini API
4. 解析响应
5. 返回结果或抛出异常
```

**错误处理**:
- API Key 缺失 → `GeminiException`
- 网络错误 → 降级提示
- 返回空内容 → 默认 fallback 文案

**被使用于**:
- `CreatePostScreen` (文案生成)
- `HealthTracker` (健康建议)
- `AIAssistant` (聊天)
- `ExploreScreen` (翻译、预测)

---

### AuthService
**文件**: `lib/services/auth_service.dart`

**职责**: 认证业务逻辑 (当前是 Mock 实现)

**核心方法**:
```dart
Future<AuthUser?> signIn({email, password})
Future<AuthUser?> signUp({email, password, displayName})
Future<void> signOut()
Stream<AuthUser?> get authStateChanges  // 认证状态流
```

**当前实现**:
- 硬编码用户列表
- 延迟 1 秒模拟网络请求
- 简单的密码匹配验证

**未来替换为 Firebase**:
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AuthUser?> signIn({email, password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _mapFirebaseUser(credential.user);
  }
}
```

---

## 快速开始

### 场景 1: 添加新的页面

1. **创建页面文件**
```dart
// lib/screens/my_new_screen.dart
class MyNewScreen extends StatefulWidget {
  const MyNewScreen({super.key});

  @override
  State<MyNewScreen> createState() => _MyNewScreenState();
}

class _MyNewScreenState extends State<MyNewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Screen')),
      body: Center(child: Text('Hello!')),
    );
  }
}
```

2. **在 MainLayout 添加路由** (如果是底部导航页面)
```dart
// lib/screens/main_layout.dart
final List<Widget> _pages = [
  const HomeScreen(),
  const MyNewScreen(),  // 添加这里
  // ...
];
```

3. **或在 main.dart 添加命名路由**
```dart
routes: {
  '/my_new': (context) => const MyNewScreen(),
},
```

---

### 场景 2: 使用 Provider 获取数据

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 方法 1: 直接 watch (整个 Provider 变化都会重建)
    final petProvider = context.watch<PetProvider>();

    // 方法 2: select (只监听特定属性)
    final currentPet = context.select<PetProvider, Pet?>(
      (provider) => provider.currentPet,
    );

    // 方法 3: Consumer (更细粒度控制)
    return Consumer<PetProvider>(
      builder: (context, provider, child) {
        return Text('Pet: ${provider.currentPet?.name}');
      },
    );
  }
}
```

---

### 场景 3: 添加新的 AI 功能

1. **在 GeminiService 添加方法**
```dart
// lib/services/gemini_service.dart
Future<String> myNewAIFeature({required String input}) async {
  final prompt = '''
你是一个宠物专家。
输入: $input
请生成...
''';

  final response = await _model.generateContent([Content.text(prompt)]);
  return response.text ?? '生成失败';
}
```

2. **在 Pricing 添加定价**
```dart
// lib/core/constants/pricing.dart
static const int myNewFeature = 10; // 10 Treats
```

3. **在 UI 调用**
```dart
Future<void> _handleGenerateNewFeature() async {
  // 检查余额
  if (!context.read<CurrencyProvider>().spend(Pricing.myNewFeature)) {
    SnackBarHelper.showError(context, '余额不足!');
    return;
  }

  // 显示加载
  setState(() => _isLoading = true);

  try {
    // 调用 AI
    final gemini = context.read<GeminiService>();
    final result = await gemini.myNewAIFeature(input: _inputText);

    // 显示结果
    setState(() => _result = result);
    SnackBarHelper.showSuccess(context, '生成成功!');
  } catch (e) {
    SnackBarHelper.showError(context, '生成失败: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

### 场景 4: 添加新的表单对话框

```dart
// lib/widgets/my_custom_dialog.dart
Future<void> showMyCustomDialog({
  required BuildContext context,
  required Function(MyData data) onSaved,
}) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('添加记录'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // 使用统一的输入框样式
            TextFormField(
              decoration: AppInputDecoration.standard(
                labelText: '名称',
                prefixIcon: Icons.label,
              ),
              validator: AppConstants.validateName,
            ),
            const SizedBox(height: 16),
            // 添加更多字段...
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            // 验证和保存逻辑
            final data = MyData(...);
            onSaved(data);
            Navigator.pop(context);
          },
          child: const Text('保存'),
        ),
      ],
    ),
  );
}
```

---

### 场景 5: 添加数据持久化

1. **在 PersistenceService 添加方法**
```dart
// lib/services/persistence_service.dart
Future<void> saveMyData(String key, MyData data) async {
  try {
    await _prefs.setString(key, jsonEncode(data.toJson()));
  } catch (e) {
    debugPrint('[PersistenceService] Error saving data: $e');
  }
}

MyData? getMyData(String key) {
  try {
    final json = _prefs.getString(key);
    if (json != null) {
      return MyData.fromJson(jsonDecode(json));
    }
  } catch (e) {
    debugPrint('[PersistenceService] Error loading data: $e');
  }
  return null;
}
```

2. **在 Provider 中使用**
```dart
class MyProvider extends ChangeNotifier {
  final PersistenceService _persistence;
  MyData? _data;

  MyProvider(this._persistence) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    _data = _persistence.getMyData('my_key');
    notifyListeners();
  }

  Future<void> updateData(MyData newData) async {
    _data = newData;
    await _persistence.saveMyData('my_key', newData);
    notifyListeners();
  }
}
```

---

## 常见开发场景

### 添加新的 Provider

1. **创建 Provider 文件**
```dart
// lib/providers/my_new_provider.dart
class MyNewProvider extends ChangeNotifier {
  final PersistenceService _persistence;

  MyNewProvider(this._persistence) {
    _loadFromStorage();
  }

  // 状态字段
  String? _myData;

  // Getter
  String? get myData => _myData;

  // 私有方法: 加载数据
  Future<void> _loadFromStorage() async {
    // 从持久化加载
  }

  // 公开方法: 更新数据
  Future<void> updateData(String newData) async {
    _myData = newData;
    // 保存到持久化
    notifyListeners();
  }
}
```

2. **在 providers.dart 导出**
```dart
export 'my_new_provider.dart';
```

3. **在 main.dart 注册**
```dart
MultiProvider(
  providers: [
    // 其他 providers...
    ChangeNotifierProvider(
      create: (_) => MyNewProvider(persistence),
    ),
  ],
  // ...
)
```

---

### 使用统一组件

**表单输入**:
```dart
TextFormField(
  decoration: AppInputDecoration.standard(
    labelText: 'Email',
    prefixIcon: Icons.email,
  ),
  validator: AppConstants.validateEmail,
)
```

**密码输入**:
```dart
PasswordFormField(
  controller: _passwordController,
  labelText: 'Password',
  validator: AppConstants.validatePassword,
)
```

**按钮**:
```dart
AppButton.primary(
  text: 'Submit',
  onPressed: _handleSubmit,
  isLoading: _isLoading,
)
```

**通知**:
```dart
SnackBarHelper.showSuccess(context, 'Success!');
SnackBarHelper.showError(context, 'Error!');
```

**空状态**:
```dart
EmptyState(
  icon: LucideIcons.inbox,
  title: 'No data',
  subtitle: 'Start adding items',
)
```

---

## 代码规范

### 文件命名
- 文件名: `snake_case.dart`
- 类名: `PascalCase`
- 变量/方法: `camelCase`
- 常量: `lowerCamelCase` (避免 `UPPER_CASE`)

### 文件头部注释
```dart
/*
  文件：screens/my_screen.dart
  说明：
  - 页面功能描述
  - 主要特性

  使用方式：
  - 如何导航到此页面

  注意：
  - 特殊说明
*/
```

### 导入顺序
```dart
// 1. Flutter SDK
import 'package:flutter/material.dart';

// 2. 第三方包
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// 3. 项目内部 (使用桶文件)
import '../providers/providers.dart';  // ✅ 推荐
import '../utils/utils.dart';

// 避免
import '../providers/user_provider.dart';  // ❌ 不推荐
import '../providers/pet_provider.dart';
```

### Provider 使用规范
```dart
// ✅ 好的做法
// 1. 只读取需要的属性
final treats = context.select<CurrencyProvider, int>((p) => p.treats);

// 2. 调用方法时使用 read
context.read<CurrencyProvider>().spend(5);

// 3. 需要多个属性时使用 Consumer
Consumer<PetProvider>(
  builder: (context, provider, child) {
    return Column(
      children: [
        Text(provider.currentPet?.name ?? ''),
        Text('Posts: ${provider.currentPet?.posts.length}'),
      ],
    );
  },
)

// ❌ 不好的做法
// 整个 Provider 变化都会重建
final provider = context.watch<PetProvider>();
```

---

## 测试指南

### 运行测试
```bash
# 运行所有测试
flutter test

# 运行特定文件
flutter test test/providers/currency_provider_test.dart

# 查看覆盖率
flutter test --coverage
```

### Provider 测试示例
```dart
// test/providers/my_provider_test.dart
void main() {
  late MockPersistenceService mockPersistence;
  late MyProvider provider;

  setUp(() {
    mockPersistence = MockPersistenceService();
    provider = MyProvider(mockPersistence);
  });

  test('初始状态正确', () {
    expect(provider.myData, isNull);
  });

  test('更新数据后触发通知', () async {
    var notified = false;
    provider.addListener(() => notified = true);

    await provider.updateData('new data');

    expect(notified, isTrue);
    expect(provider.myData, equals('new data'));
  });
}
```

---

## 性能优化建议

### 1. 使用 Selector 而非 Watch
```dart
// ❌ 不好 - 整个 Provider 变化都重建
final provider = context.watch<PetProvider>();

// ✅ 好 - 只监听特定属性
final petName = context.select<PetProvider, String?>(
  (p) => p.currentPet?.name,
);
```

### 2. 使用 const 构造
```dart
// ✅ 好 - 不会重建
const SizedBox(height: 16)
const Text('Label')

// ❌ 不好 - 每次都创建新实例
SizedBox(height: 16)
Text('Label')
```

### 3. 图片缓存
```dart
// 使用 CachedNetworkImage
CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: 800,  // 限制内存缓存
  memCacheHeight: 800,
)
```

### 4. ListView.builder
```dart
// ✅ 好 - 延迟构建
ListView.builder(
  itemCount: posts.length,
  itemBuilder: (context, index) => FeedCard(post: posts[index]),
)

// ❌ 不好 - 一次性构建所有
ListView(
  children: posts.map((p) => FeedCard(post: p)).toList(),
)
```

---

## 调试技巧

### 1. 使用 debugPrint
```dart
// ✅ 生产环境会自动关闭
debugPrint('[MyScreen] Button pressed');

// ❌ 生产环境仍会打印
print('Debug message');
```

### 2. Provider 调试
```dart
class MyProvider extends ChangeNotifier {
  @override
  void notifyListeners() {
    debugPrint('[MyProvider] notifyListeners called');
    super.notifyListeners();
  }
}
```

### 3. Flutter DevTools
```bash
# 运行应用后打开
flutter run
# 在浏览器打开 DevTools
# 查看 Widget Tree, Performance, Network
```

---

## 故障排查

### 问题: Provider 未更新 UI

**原因**: 忘记调用 `notifyListeners()`

**解决**:
```dart
void updateData(String newData) {
  _data = newData;
  notifyListeners();  // ← 必须调用
}
```

---

### 问题: 数据丢失

**原因**: 未持久化到本地存储

**解决**:
```dart
Future<void> updateData(String newData) async {
  _data = newData;
  await _persistence.saveData('key', newData);  // ← 保存
  notifyListeners();
}
```

---

### 问题: API Key 错误

**原因**: `.env` 文件未配置或格式错误

**解决**:
1. 确保 `.env` 文件存在于项目根目录
2. 格式: `GEMINI_API_KEY=your_actual_key_here`
3. 运行: `flutter pub get`
4. 重启应用

---

## 下一步学习

### 新手 (0-1 周)
1. ✅ 阅读本文档
2. ✅ 运行应用并体验功能
3. ✅ 查看 `main.dart` 理解 Provider 配置
4. ✅ 阅读 `models/types.dart` 理解数据结构

### 初级 (1-2 周)
5. ✅ 学习 Provider 基本用法
6. ✅ 修改现有页面 UI
7. ✅ 添加新的表单字段
8. ✅ 使用统一组件替换重复代码

### 中级 (2-4 周)
9. ✅ 创建新的页面
10. ✅ 添加新的 AI 功能
11. ✅ 编写单元测试
12. ✅ 实现数据持久化

### 高级 (1-2 月)
13. ✅ 优化性能 (Selector, const)
14. ✅ Firebase 集成准备
15. ✅ 架构改进建议
16. ✅ Code Review 和重构

---

## 相关文档

- [项目状态总览](PROJECT_STATUS.md) - 当前版本和完成状态
- [中文注释指南](OlliePaw/CHINESE_COMMENTS_GUIDE.md) - 代码注释规范
- [Firebase 迁移准备](PRE_FIREBASE_CHECKLIST.md) - Firebase 集成检查清单
- [性能优化指南](PERFORMANCE_GUIDE.md) - 性能优化实践
- [测试指南](TESTING_GUIDE.md) - 测试框架和示例

---

**维护者**: OlliePaw 开发团队
**文档版本**: v2.5
**最后更新**: 2025-12-29

**欢迎贡献**: 如果您发现任何问题或有改进建议，请提交 Issue 或 PR！
