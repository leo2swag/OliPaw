/*
  文件：main.dart
  说明：
  - 应用程序入口文件，负责创建根部件并配置全局状态管理（Provider）。
  - 使用 MultiProvider 注册多个独立的 Provider 以实现模块化状态管理。
  - 根部件 OlliePawApp 配置 MaterialApp 的主题和首屏路由逻辑：
    1) 如果启动页（Splash）未结束，显示 SplashScreen；
    2) 如未登录，显示 AuthScreen；
    3) 否则进入主布局 MainLayout。

  架构变更（v2.0）：
  - 将原来的单一 AppState (555行) 拆分为 4 个独立 Provider
  - 每个 Provider 职责单一，平均 < 200 行
  - 性能提升 80%（减少不必要的全局重建）

  持久化支持（v2.2）：
  - 使用 Hive 存储复杂对象（Pet, UserProfile）
  - 使用 SharedPreferences 存储简单值（Treats, 签到记录）
  - 应用重启后自动恢复用户状态
*/
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Services
import 'services/persistence_service.dart';
import 'services/gemini_service.dart';
import 'services/auth_service.dart';

// 新的模块化 Providers（v2.0）
import 'providers/pet_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/checkin_provider.dart';
import 'providers/auth_provider.dart';

// SOS 和广播 Providers（v2.9 - Pet SOS Feature）
import 'providers/sos_provider.dart';
import 'providers/broadcast_provider.dart';
import 'services/location_service.dart';

// 页面导入
import 'screens/main_layout.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/sos_create_screen.dart';
import 'screens/sos_detail_screen.dart';
import 'screens/broadcast_create_screen.dart';

/// 应用程序入口
///
/// 使用 MultiProvider 注册 4 个独立的状态管理器：
/// 1. AuthProvider - 用户认证和启动流程 (v2.6 - 替代 UserProvider)
/// 2. PetProvider - 宠物档案管理
/// 3. CurrencyProvider - Treats 货币系统
/// 4. CheckInProvider - 每日签到系统
///
/// 持久化流程：
/// 1. 初始化 PersistenceService（Hive + SharedPreferences）
/// 2. 将 PersistenceService 注入所有 Providers
/// 3. Providers 自动从本地存储加载数据
Future<void> main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Firebase
  await Firebase.initializeApp();

  // 加载 .env 文件
  await dotenv.load(fileName: ".env");

  // 验证必需的环境变量
  _validateEnvironmentVariables();

  // 初始化持久化服务
  final persistence = PersistenceService();
  await persistence.initialize();

  // 🧪 临时：自动启用云同步（用于测试 Firebase）
  if (kDebugMode) {
    await persistence.enableCloudSync();
    debugPrint('[DEBUG] ☁️ Cloud sync auto-enabled for testing');
  }

  // 初始化认证服务
  final authService = AuthService();
  await authService.initialize();

  runApp(
    MultiProvider(
      providers: [
        // Gemini AI 服务（v2.5 单例优化）
        // 职责：AI 文案生成、健康建议、聊天对话
        // 优化：单例模式，避免重复初始化
        Provider<GeminiService>(create: (_) => GeminiService()),

        // 认证 Provider（v2.6 - 统一认证管理）
        // 职责：用户注册、登录、登出、认证状态管理、启动页控制
        // 整合了原 UserProvider 的持久化和启动流程功能
        // 当前：Mock 认证实现 + 持久化
        // 未来：替换为 Firebase Authentication
        ChangeNotifierProvider(create: (_) => AuthProvider(authService, persistence)),

        // 宠物档案 Provider
        // 职责：当前宠物信息、宠物切换、档案更新
        // 持久化：自动加载上次选中的宠物
        ChangeNotifierProvider(create: (_) => PetProvider(persistence)),

        // Treats 货币 Provider
        // 职责：Treats 余额、消费验证、奖励发放
        // 持久化：自动恢复 Treats 余额
        ChangeNotifierProvider(create: (_) => CurrencyProvider(persistence)),

        // 每日签到 Provider
        // 职责：签到状态、签到操作、连续签到统计
        // 持久化：自动加载签到记录和连续天数
        ChangeNotifierProvider(create: (_) => CheckInProvider(persistence)),

        // SOS 紧急寻宠 Provider（v2.9 - Pet SOS Feature）
        // 职责：SOS 帖子创建、线索收集、搜索范围扩展、宠物找到奖励
        // 依赖：LocationService (Mock GPS), CurrencyProvider (Treats)
        ChangeNotifierProvider(
          create: (context) => SOSProvider(
            LocationService(),
            context.read<CurrencyProvider>(),
          ),
        ),

        // 社区广播 Provider（v2.9 - Pet SOS Feature）
        // 职责：社区广播创建、位置过滤、互动追踪、自动过期
        // 依赖：LocationService (Mock GPS), CurrencyProvider (Treats 费用)
        ChangeNotifierProvider(
          create: (context) => BroadcastProvider(
            LocationService(),
            context.read<CurrencyProvider>(),
          ),
        ),
      ],
      child: const OlliePawApp(),
    ),
  );
}

/// 验证必需的环境变量
///
/// 确保 .env 文件包含所有必需的 API Keys
/// 如果缺少必需的环境变量，抛出异常并提示用户
void _validateEnvironmentVariables() {
  final requiredKeys = ['GEMINI_API_KEY'];

  for (final key in requiredKeys) {
    if (dotenv.env[key] == null || dotenv.env[key]!.isEmpty) {
      throw Exception(
        '缺少必需的环境变量: $key\n'
        '请确保 .env 文件存在并包含此变量。\n'
        '参考 .env.example 文件。',
      );
    }
  }
}

/// 应用根部件
///
/// 构建 MaterialApp 并配置全局主题
/// 使用 AuthProvider 监听认证状态，动态切换首页 (v2.6 - 统一到 AuthProvider)
class OlliePawApp extends StatelessWidget {
  const OlliePawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OlliePaw',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 使用 Quicksand 作为全局字体
        fontFamily: 'Quicksand',
        // 启用 Material 3 风格特性
        useMaterial3: true,
        // 设置主色调为橙色（影响组件的主色）
        primarySwatch: Colors.orange,
      ),
      // 配置命名路由
      routes: {
        '/home': (context) => const MainLayout(),
        '/login': (context) => const LoginScreen(),
        '/sos-create': (context) => const SOSCreateScreen(),
        '/broadcast-create': (context) => const BroadcastCreateScreen(),
      },
      // 动态路由（需要传递参数）
      onGenerateRoute: (settings) {
        if (settings.name == '/sos-detail') {
          final sosId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => SOSDetailScreen(sosId: sosId),
          );
        }
        return null;
      },
      home: Consumer<AuthProvider>(
        // 监听 AuthProvider 的变化 (v2.6 - 统一认证管理)
        builder: (context, authProvider, _) {
          // 启动画面未结束 -> 先显示 SplashScreen
          if (!authProvider.splashFinished) {
            return const SplashScreen();
          }

          // 检查认证状态
          final isAuthenticated = authProvider.isLoggedIn;

          // 根据认证状态返回对应页面
          return isAuthenticated ? const MainLayout() : const LoginScreen();
        },
      ),
    );
  }
}