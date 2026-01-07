/*
  文件：utils/photo_picker_helper.dart
  说明：
  - 照片和视频选择辅助类
  - 功能：
    1) 从相册选择照片
    2) 拍摄照片
    3) 选择视频
    4) 显示选择选项底部弹窗
  - 使用方式：在需要的地方调用静态方法
  注意：需要在 info.plist (iOS) 和 AndroidManifest.xml (Android) 配置相机和相册权限
*/

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// 照片选择辅助类
/// 说明：封装 ImagePicker 的常用操作，提供统一的接口
class PhotoPickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// 从相册选择照片
  /// 参数：
  /// - context: 构建上下文（用于显示提示）
  /// - maxWidth: 图片最大宽度（默认 1920）
  /// - maxHeight: 图片最大高度（默认 1920）
  /// - imageQuality: 图片质量 0-100（默认 85）
  /// 返回：选中的照片文件，如果用户取消则返回 null
  static Future<XFile?> pickImageFromGallery(
    BuildContext context, {
    double maxWidth = 1920,
    double maxHeight = 1920,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('照片已选择！ 📸'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }

      return image;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择照片失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// 使用相机拍照
  /// 参数：
  /// - context: 构建上下文（用于显示提示）
  /// - maxWidth: 图片最大宽度（默认 1920）
  /// - maxHeight: 图片最大高度（默认 1920）
  /// - imageQuality: 图片质量 0-100（默认 85）
  /// 返回：拍摄的照片文件，如果用户取消则返回 null
  static Future<XFile?> takePhoto(
    BuildContext context, {
    double maxWidth = 1920,
    double maxHeight = 1920,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (photo != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('照片拍摄成功！ 📸'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }

      return photo;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('拍照失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// 从相册选择视频
  /// 参数：
  /// - context: 构建上下文（用于显示提示）
  /// - maxDuration: 视频最大时长（默认 1 分钟）
  /// 返回：选中的视频文件，如果用户取消则返回 null
  static Future<XFile?> pickVideoFromGallery(
    BuildContext context, {
    Duration maxDuration = const Duration(minutes: 1),
  }) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration,
      );

      if (video != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('视频已选择！ 🎥'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }

      return video;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择视频失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// 显示照片选择选项底部弹窗
  /// 说明：
  /// - 提供拍照和从相册选择两个选项
  /// - 如果已有照片，还提供移除选项
  /// 参数：
  /// - context: 构建上下文
  /// - hasImage: 是否已选择照片
  /// - onCameraTap: 拍照回调
  /// - onGalleryTap: 从相册选择回调
  /// - onRemoveTap: 移除照片回调（可选）
  static void showImagePickerOptions({
    required BuildContext context,
    required VoidCallback onCameraTap,
    required VoidCallback onGalleryTap,
    VoidCallback? onRemoveTap,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              const Text(
                '添加照片',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 拍照选项
              ListTile(
                leading: const Icon(LucideIcons.camera, color: Colors.orange),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.pop(context);
                  onCameraTap();
                },
              ),

              // 从相册选择
              ListTile(
                leading: const Icon(LucideIcons.image, color: Colors.blue),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.pop(context);
                  onGalleryTap();
                },
              ),

              // 移除选项（如果已有照片）
              if (onRemoveTap != null)
                ListTile(
                  leading: const Icon(LucideIcons.trash2, color: Colors.red),
                  title: const Text('移除照片'),
                  onTap: () {
                    Navigator.pop(context);
                    onRemoveTap();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
