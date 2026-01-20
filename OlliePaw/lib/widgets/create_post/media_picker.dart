/*
  文件：widgets/create_post/media_picker.dart
  说明：
  - 媒体选择器组件
  - 支持图片和视频选择
  - 显示选中状态

  优化（v2.5）：
  - 从 CreatePostScreen 中提取，提高代码复用性
  - 使用 MediaType 枚举进行类型判断
*/
import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/enums/media_type.dart';

/// 媒体选择器
///
/// 包含图片和视频选择按钮
class MediaPicker extends StatelessWidget {
  /// 当前选中的媒体
  final XFile? selectedMedia;

  /// 图片选择回调
  final VoidCallback onPickImage;

  /// 视频选择回调
  final VoidCallback onPickVideo;

  const MediaPicker({
    super.key,
    this.selectedMedia,
    required this.onPickImage,
    required this.onPickVideo,
  });

  @override
  Widget build(BuildContext context) {
    final bool isImageSelected = selectedMedia != null && selectedMedia!.path.isImage;
    final bool isVideoSelected = selectedMedia != null && selectedMedia!.path.isVideo;

    return Row(
      children: [
        // 图片选择按钮
        Expanded(
          child: GestureDetector(
            onTap: onPickImage,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: isImageSelected ? AppColors.lightOrangeBg : AppColors.white,
                borderRadius: AppRadius.allLG,
                border: Border.all(
                  color: isImageSelected ? AppColors.primaryOrange : AppColors.grey200,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isImageSelected ? LucideIcons.checkCircle : LucideIcons.image,
                    color: isImageSelected ? AppColors.primaryOrange : AppColors.grey500,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Photos",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isImageSelected ? AppColors.primaryOrange : AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 视频选择按钮
        Expanded(
          child: GestureDetector(
            onTap: onPickVideo,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: isVideoSelected ? AppColors.info.withValues(alpha: 0.1) : AppColors.white,
                borderRadius: AppRadius.allLG,
                border: Border.all(
                  color: isVideoSelected ? AppColors.info : AppColors.grey200,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isVideoSelected ? LucideIcons.checkCircle : LucideIcons.video,
                    color: isVideoSelected ? AppColors.info : AppColors.grey500,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Video",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isVideoSelected ? AppColors.info : AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
