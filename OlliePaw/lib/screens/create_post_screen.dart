/*
  文件：screens/create_post_screen.dart
  说明：
  - 创建动态页面（New Memory）：
    1) 心情（Vibe Check）选择器 - 简洁设计
    2) 文本输入框（支持 AI 自动生成文案）
    3) 图片/视频上传 - 上传后自动调用 AI 生成文案
    4) 分类（Category）选择器 - 简洁样式
  - 简化版本：更简洁、更少的颜色和装饰

  架构变更（v2.0）：
  - 从 AppState 迁移到专用 Providers
  - PetProvider: 获取当前宠物信息
  - CurrencyProvider: 扣除 Treats 费用

  优化（v2.5）：
  - 组件化重构，提取为可复用组件：
    - MoodSelector: 心情选择器
    - PostInputField: 帖子输入框
    - MediaPicker: 媒体选择器
    - CategorySelector: 分类选择器
*/
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/pet_provider.dart';
import '../providers/currency_provider.dart';
import '../services/gemini_service.dart';
import '../widgets/common/loading_overlay.dart';
import '../widgets/create_post/mood_selector.dart';
import '../widgets/create_post/post_input_field.dart';
import '../widgets/create_post/media_picker.dart';
import '../widgets/create_post/category_selector.dart';

/// 创建动态页面：编辑心情、文本，并可调用 AI 协助
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

/// 创建动态 State：
/// - 管理文本输入、AI 调用状态、心情选择、分类选择、照片/视频上传
///
/// 优化（v2.5）：
/// - GeminiService 通过 Provider 注入，避免重复创建实例
/// - 组件化重构，分离关注点
class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  final bool _isGenerating = false;
  String _selectedMood = 'Happy';
  String _selectedCategory = 'Pics';
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedMedia;

  /// 获取 GeminiService 实例（通过 Provider）
  GeminiService get _ai => context.read<GeminiService>();

  // 可供选择的心情列表（用于选择器）
  final List<Map<String, String>> _moods = [
    {'name': 'Happy', 'emoji': '😊'},
    {'name': 'Sassy', 'emoji': '😎'},
    {'name': 'Chaos', 'emoji': '🤪'},
    {'name': 'Sleepy', 'emoji': '😴'},
    {'name': 'Playful', 'emoji': '🎾'},
    {'name': 'Hungry', 'emoji': '🍖'},
  ];

  // 分类列表
  final List<Map<String, String>> _categories = [
    {'name': 'Pics', 'emoji': '📸'},
    {'name': 'Sleep', 'emoji': '💤'},
    {'name': 'Walk', 'emoji': '🌳'},
    {'name': 'Play', 'emoji': '🎾'},
  ];

  /// 选择照片并自动生成文案
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

        // 自动生成 AI 文案
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo selected! Generating caption... 📸'),
            backgroundColor: Colors.green,
          ),
        );

        _generateCaption();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  /// 选择视频并自动生成文案
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

        // 自动生成 AI 文案
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video selected! Generating caption... 🎥'),
            backgroundColor: Colors.green,
          ),
        );

        _generateCaption();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking video: $e')),
        );
      }
    }
  }

  /// 使用 AI 生成短文案：
  /// - 扣除 5 Treats，不足则提示
  /// - 将生成结果填入文本框
  void _generateCaption() async {
    final pet = context.read<PetProvider>().currentPet;
    final contextText = _textCtrl.text.isEmpty ? "Playing outside" : _textCtrl.text;

    // Spend treats check
    if (!context.read<CurrencyProvider>().spendTreats(5)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Need 5 Treats! 🦴"))
      );
      return;
    }

    final caption = await LoadingOverlay.show(
      context: context,
      message: 'Generating caption...',
      subtitle: 'AI is thinking 🤔',
      task: () => _ai.generatePetCaption(pet, contextText),
    );

    if (caption != null) {
      _textCtrl.text = caption;
    }
  }

  @override
  /// 构建页面：
  /// - 顶部 AppBar 的 Post 按钮仅做返回（提交逻辑留空）
  /// - 包含心情选择器、输入区、AI 操作与上传功能
  Widget build(BuildContext context) {
    final petName = context.watch<PetProvider>().currentPet.name;

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        title: const Text("Create Post", style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        backgroundColor: AppColors.screenBg,
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text("Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 心情选择器组件
            MoodSelector(
              moods: _moods,
              selectedMood: _selectedMood,
              onMoodSelected: (mood) => setState(() => _selectedMood = mood),
            ),
            const SizedBox(height: 24),

            // 帖子输入框组件
            PostInputField(
              controller: _textCtrl,
              hintText: "What's $petName thinking?",
              isGenerating: _isGenerating,
              onGenerateCaption: _generateCaption,
            ),
            const SizedBox(height: 20),

            // 媒体选择器组件
            MediaPicker(
              selectedMedia: _selectedMedia,
              onPickImage: _pickImage,
              onPickVideo: _pickVideo,
            ),
            const SizedBox(height: 24),

            // 分类选择器组件
            CategorySelector(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) => setState(() => _selectedCategory = category),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
