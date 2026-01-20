/*
  文件：services/notification_service.dart
  说明：
  - 应用内通知服务（MVP 版本）
  - 处理各种优先级的通知展示

  功能：
  - SOS 紧急通知（全屏模态框）
  - 线索通知（SnackBar）
  - 广播通知（SnackBar）
  - 通用通知展示

  未来扩展：
  - Firebase Cloud Messaging (FCM) 推送通知
  - 本地通知（flutter_local_notifications）
  - 通知历史记录
  - 用户通知偏好设置
*/

import 'package:flutter/material.dart';
import '../models/sos_types.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_dimensions.dart';

/// 通知优先级
enum NotificationPriority {
  critical, // 关键（SOS）- 全屏模态框
  urgent,   // 紧急（线索、危险预警）- 持久 SnackBar
  normal,   // 普通（社交、市场）- 普通 SnackBar
}

/// 应用内通知服务
class NotificationService {
  // 单例模式
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// 显示 SOS 紧急通知（全屏模态框）
  ///
  /// 用于附近有宠物走失时的紧急通知
  void showSOSAlert(BuildContext context, SOSPost sos) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.allMD,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.allMD,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 图标
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pets,
                    size: 40,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 16),

                // 标题
                const Text(
                  '🚨 附近宠物走失！',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // 宠物信息
                Text(
                  '${sos.petName} (${sos.petBreed})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // 位置信息
                Text(
                  '最后出现: ${sos.lastSeenLocation.addressName ?? sos.lastSeenLocation.city}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grey500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // 悬赏信息
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: AppRadius.allMD,
                  ),
                  child: Text(
                    '悬赏: ${sos.treatsReward} 🦴 Treats',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.allSM,
                          ),
                        ),
                        child: const Text('稍后'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, '/sos-detail', arguments: sos.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.allSM,
                          ),
                        ),
                        child: const Text(
                          '查看详情',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 显示广播通知（SnackBar）
  void showBroadcastNotification(
    BuildContext context,
    CommunityBroadcast broadcast,
  ) {
    final color = _getBroadcastColor(broadcast.type);
    final icon = _getBroadcastIcon(broadcast.type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    broadcast.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    broadcast.content,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '查看',
          textColor: AppColors.white,
          onPressed: () {
            // TODO: 导航到广播详情
          },
        ),
      ),
    );
  }

  /// 显示线索通知
  void showClueNotification(
    BuildContext context,
    SOSPost sos,
    ClueReport clue,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.location_on,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '新线索！',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${sos.petName}: ${clue.description}',
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryOrange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: '查看',
          textColor: AppColors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/sos-detail', arguments: sos.id);
          },
        ),
      ),
    );
  }

  /// 显示成功通知
  void showSuccessNotification(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 显示错误通知
  void showErrorNotification(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// 显示警告通知
  void showWarningNotification(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 显示信息通知
  void showInfoNotification(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  // ==========================================================================
  // 辅助方法
  // ==========================================================================

  /// 获取广播类型对应的颜色
  Color _getBroadcastColor(BroadcastType type) {
    switch (type) {
      case BroadcastType.sos:
      case BroadcastType.danger:
        return AppColors.error;
      case BroadcastType.social:
        return AppColors.success;
      case BroadcastType.marketplace:
        return AppColors.warning;
    }
  }

  /// 获取广播类型对应的图标
  String _getBroadcastIcon(BroadcastType type) {
    switch (type) {
      case BroadcastType.sos:
        return '🔴';
      case BroadcastType.danger:
        return '⚠️';
      case BroadcastType.social:
        return '🟢';
      case BroadcastType.marketplace:
        return '🟡';
    }
  }
}

/*
  未来 FCM 推送通知集成示例：

  添加依赖到 pubspec.yaml:
  dependencies:
    firebase_messaging: ^14.7.6
    flutter_local_notifications: ^16.3.0

  实现示例：

  class FCMService {
    final FirebaseMessaging _messaging = FirebaseMessaging.instance;

    Future<void> initialize() async {
      // 请求通知权限
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // 获取 FCM Token
      String? token = await _messaging.getToken();
      print('FCM Token: $token');

      // 监听前台消息
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('收到前台消息: ${message.notification?.title}');
        // 显示应用内通知
      });

      // 监听后台消息点击
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('点击后台消息: ${message.data}');
        // 导航到相关页面
      });
    }

    // 订阅地理位置主题
    Future<void> subscribeToLocationTopic(double lat, double lon) async {
      // 订阅附近区域的 SOS 通知
      final topic = 'sos_${lat.toInt()}_${lon.toInt()}';
      await _messaging.subscribeToTopic(topic);
    }

    // 发送推送通知（服务器端）
    // POST https://fcm.googleapis.com/fcm/send
    // Headers: Authorization: key=YOUR_SERVER_KEY
    // Body:
    // {
    //   "to": "/topics/sos_39_116",
    //   "notification": {
    //     "title": "🚨 附近宠物走失！",
    //     "body": "Buddy (Golden Retriever) 在北京 CBD 走失",
    //     "sound": "default",
    //     "badge": "1"
    //   },
    //   "data": {
    //     "sosId": "sos_123",
    //     "type": "sos_alert"
    //   }
    // }
  }
*/
