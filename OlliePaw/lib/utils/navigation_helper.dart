/*
  文件：utils/navigation_helper.dart
  说明：
  - 统一导航工具类
  - 标准化所有导航操作
  - 提供一致的导航模式

  v3.3 - 导航标准化
*/
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// 导航帮助类：统一应用内所有导航操作
class NavigationHelper {
  NavigationHelper._(); // 私有构造函数，禁止实例化

  /// 导航到命名路由
  ///
  /// 使用示例:
  /// ```dart
  /// NavigationHelper.pushNamed(context, '/sos-create');
  /// NavigationHelper.pushNamed(context, '/sos-detail', arguments: sosId);
  /// ```
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// 导航到命名路由并替换当前路由
  ///
  /// 使用场景：登录后跳转到主页
  static Future<T?> pushReplacementNamed<T, TO>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// 导航到命名路由并清空所有历史路由
  ///
  /// 使用场景：登出后返回登录页
  static Future<T?> pushNamedAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false, // 移除所有历史路由
      arguments: arguments,
    );
  }

  /// 直接导航到页面（使用 MaterialPageRoute）
  ///
  /// 仅在需要传递复杂对象时使用，否则优先使用 pushNamed
  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    bool fullscreenDialog = false,
  }) async {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => page,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// 返回上一页
  ///
  /// 使用示例:
  /// ```dart
  /// NavigationHelper.pop(context);
  /// NavigationHelper.pop(context, result: data);
  /// ```
  static void pop<T>(BuildContext context, [T? result]) {
    if (Navigator.canPop(context)) {
      Navigator.pop<T>(context, result);
    }
  }

  /// 返回到指定路由
  ///
  /// 使用场景：从深层页面直接返回到特定页面
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  /// 登出：清空导航栈并跳转到登录页
  ///
  /// 专用于登出流程
  static Future<void> logout(BuildContext context) async {
    return pushNamedAndRemoveUntil(context, '/login');
  }

  /// 显示 Modal Bottom Sheet
  ///
  /// 统一的底部弹出面板样式
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isScrollControlled = false,
    double? height,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent, // Keep Colors.transparent - no AppColors equivalent
      builder: (ctx) => Container(
        height: height,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: child,
      ),
    );
  }

  /// 显示确认对话框
  ///
  /// 返回 true 表示确认，false 表示取消
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '确认',
    String cancelText = '取消',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: isDangerous
                ? TextButton.styleFrom(foregroundColor: AppColors.error)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
