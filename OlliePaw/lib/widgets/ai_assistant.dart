/*
  文件：widgets/ai_assistant.dart
  说明：
  - AI 助手（PawPal）：与 GeminiService 对话，按条计费（消耗 Treats）。
  - 展示聊天消息列表与输入框，支持发送后异步获取 AI 回复。
  - 支持照片/视频上传功能，可将媒体发送给 AI 分析
  注意：增强 UI 设计，添加媒体上传功能
*/
import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/types.dart';
import '../services/gemini_service.dart';
import '../providers/currency_provider.dart';
import '../core/enums/media_type.dart';

/// AI 助手组件：与 AI 兽医对话
class AiAssistant extends StatefulWidget {
  final Pet pet;
  const AiAssistant({super.key, required this.pet});

  @override
  State<AiAssistant> createState() => _AiAssistantState();
}

/// AI 助手状态：
/// - 管理消息列表、输入框、AI 调用与扣费逻辑、媒体上传
///
/// 优化（v2.5）：
/// - GeminiService 通过 Provider 注入，避免重复创建实例
class _AiAssistantState extends State<AiAssistant> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;
  final int _cost = 5;
  XFile? _selectedMedia;

  /// 获取 GeminiService 实例（通过 Provider）
  GeminiService get _ai => context.read<GeminiService>();

  @override
  /// 初始化对话：插入欢迎消息与费用说明
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      role: 'model',
      text: "Hi! I'm PawPal 🐾 I charge $_cost treats per answer. How can I help ${widget.pet.name}?",
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 选择照片
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedMedia = image;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo selected! You can now send it to PawPal 📸'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  /// 选择视频
  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 1),
      );

      if (video != null) {
        setState(() {
          _selectedMedia = video;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video selected! You can now send it to PawPal 🎥'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking video: $e')),
        );
      }
    }
  }

  /// 显示媒体选择选项
  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Upload Media',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: AppRadius.allMD,
                ),
                child: const Icon(LucideIcons.image, color: Colors.orange),
              ),
              title: const Text('Upload Photo', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Share a photo with PawPal'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: AppRadius.allMD,
                ),
                child: const Icon(LucideIcons.video, color: Colors.blue),
              ),
              title: const Text('Upload Video', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Share a video with PawPal'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// 发送消息：
  /// - 扣除 Treats，不足则提示
  /// - 将用户消息加入列表，调用 AI，追加回复
  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedMedia == null) return;

    final currencyProvider = context.read<CurrencyProvider>();
    if (!currencyProvider.spendTreats(_cost)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not enough treats! 🦴"))
      );
      return;
    }

    // 构建用户消息文本
    String userMessage = text;
    if (_selectedMedia != null) {
      final mediaType = _selectedMedia!.path.mediaType;
      final mediaLabel = '${mediaType.icon} ${mediaType.englishName}';
      userMessage = text.isEmpty
        ? '$mediaLabel attached'
        : '$text\n$mediaLabel attached';
    }

    setState(() {
      _messages.add(ChatMessage(role: 'user', text: userMessage));
      _loading = true;
      _controller.clear();
      _selectedMedia = null;
    });

    final response = await _ai.chatWithVet(text.isEmpty ? "Analyze this media" : text, widget.pet);

    setState(() {
      _messages.add(ChatMessage(role: 'model', text: response));
      _loading = false;
    });
  }

  @override
  /// 构建界面：头部费用/余额、消息列表、输入发送行
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 头部：渐变背景 + 头像 + 标题 + 余额（Treats）
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.indigo.shade400, Colors.purple.shade400],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.indigo,
                  radius: 24,
                  child: Icon(LucideIcons.bot, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "PawPal AI",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Your AI Vet Assistant",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Consumer<CurrencyProvider>(
                    builder: (ctx, provider, _) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.allXL,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.bone, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            "${provider.treats}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.brown,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: AppRadius.allMD,
                    ),
                    child: Text(
                      "$_cost 🦴/msg",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 聊天消息列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (ctx, i) {
              final msg = _messages[i];
              final isUser = msg.role == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                      ? LinearGradient(
                          colors: [Colors.amber.shade400, Colors.orange.shade400],
                        )
                      : null,
                    color: isUser ? null : Colors.white,
                    borderRadius: AppRadius.allXL.copyWith(
                      topRight: isUser ? Radius.zero : const Radius.circular(20),
                      topLeft: isUser ? const Radius.circular(20) : Radius.zero,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                          ? Colors.orange.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        if (_loading)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.indigo.shade400,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "PawPal is thinking...",
                  style: TextStyle(
                    color: Colors.indigo.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // 媒体预览（如果已选择）
        if (_selectedMedia != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: AppRadius.allLG,
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.allMD,
                    image: _selectedMedia!.path.isVideo
                      ? null
                      : DecorationImage(
                          image: FileImage(File(_selectedMedia!.path)),
                          fit: BoxFit.cover,
                        ),
                    color: _selectedMedia!.path.isVideo
                      ? Colors.blue.shade100
                      : null,
                  ),
                  child: _selectedMedia!.path.isVideo
                    ? const Icon(LucideIcons.video, color: Colors.blue)
                    : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedMedia!.path.mediaType.englishName} attached',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Ready to send',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => setState(() => _selectedMedia = null),
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),

        // 输入区：TextField + 上传按钮 + 发送按钮
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 上传按钮
              IconButton(
                onPressed: _showMediaOptions,
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.indigo.shade400],
                    ),
                    borderRadius: AppRadius.allMD,
                  ),
                  child: const Icon(LucideIcons.paperclip, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Ask Dr. PawPal...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              // 发送按钮
              GestureDetector(
                onTap: _loading ? null : _handleSend,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade400, Colors.purple.shade400],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
