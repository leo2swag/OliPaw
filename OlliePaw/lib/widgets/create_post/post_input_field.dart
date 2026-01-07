/*
  文件：widgets/create_post/post_input_field.dart
  说明：
  - 帖子输入框组件
  - 支持 AI 辅助生成文案
  - 包含加载状态显示

  优化（v2.5）：
  - 从 CreatePostScreen 中提取，提高代码复用性
  - 使用回调函数处理 AI 生成事件
*/
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// 帖子输入框
///
/// 包含文本输入和 AI 辅助生成功能
class PostInputField extends StatelessWidget {
  /// 文本控制器
  final TextEditingController controller;

  /// 占位符文本
  final String hintText;

  /// 是否正在生成
  final bool isGenerating;

  /// AI 生成回调
  final VoidCallback onGenerateCaption;

  const PostInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isGenerating,
    required this.onGenerateCaption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 15),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isGenerating)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Generating...",
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                // AI 自动生成文案（扣 5 Treats）
                TextButton.icon(
                  onPressed: onGenerateCaption,
                  icon: const Icon(LucideIcons.sparkles, size: 16),
                  label: const Text("AI Assist (5🦴)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange.shade700,
                    backgroundColor: Colors.orange.shade50,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}
