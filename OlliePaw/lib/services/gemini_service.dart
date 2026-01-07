/*
  文件：services/gemini_service.dart
  说明：
  - 封装与 Google Generative AI (Gemini) 的交互：
    1) 生成宠物短文案（generatePetCaption）
    2) 提供健康小贴士（analyzeHealthTip）
    3) 与 AI 兽医对话（chatWithVet）
    4) 汪/喵声翻译（translatePetSound）
    5) 未来自我预测（predictFutureSelf）
  - 通过 .env 文件读取 API Key，确保安全性。
  - 若未设置 API Key，方法将返回友好占位文本，避免崩溃。

  安全性改进（v2.1）：
  - 从 String.fromEnvironment 迁移到 flutter_dotenv
  - API Key 不再硬编码在代码中或编译产物中
  - 支持不同环境使用不同的 Key（开发/生产）

  错误处理改进（v2.5）：
  - 自定义异常类型，提供更精确的错误信息
  - 用户友好的错误提示
*/
import 'dart:async';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/types.dart';
import '../core/exceptions/gemini_exceptions.dart';
import '../core/constants/ui_constants.dart';

/// Gemini 服务：提供与 Google Generative AI 的能力封装
///
/// 安全地从环境变量加载 API Key
///
/// 优化（v2.5）：
/// - 单例模式，避免重复创建模型实例
/// - 通过 Provider 注入，便于测试和依赖管理
class GeminiService {
  // 单例实例
  static final GeminiService _instance = GeminiService._internal();

  /// 工厂构造函数，返回单例实例
  factory GeminiService() => _instance;

  late final GenerativeModel _model;
  late final String _apiKey;

  /// 私有构造函数，只在首次访问时执行
  GeminiService._internal() {
    // 从 .env 文件读取 API Key
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (_apiKey.isEmpty) {
      throw const GeminiApiKeyMissingException();
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  /// 是否具备有效的 API Key
  bool get hasKey => _apiKey.isNotEmpty;

  // 1. Caption Generator
  /// 生成宠物短文案（最多两句，第一人称、带 emoji、无 hashtag）
  ///
  /// 优化（v2.5）：改进的错误处理
  Future<String> generatePetCaption(Pet pet, String activityDescription) async {
    if (!hasKey) return "Woof! Just living my best life. (No API Key)";

    try {
      final prompt = '''
        You are a ${pet.breed} named ${pet.name}.
        Your personality is cute, slightly sassy, and food-motivated.
        Write a short social media caption (max 2 sentences) for a photo where you are: $activityDescription.
        Use emojis. Do not use hashtags. Write in the first person ("I").
      ''';

      final response = await _model.generateContent([Content.text(prompt)])
          .timeout(APITimeouts.geminiTimeout);

      if (response.text == null || response.text!.isEmpty) {
        throw const GeminiEmptyResponseException();
      }

      return response.text!.trim();
    } on TimeoutException {
      throw const GeminiTimeoutException();
    } on SocketException {
      throw GeminiNetworkException();
    } on GeminiException {
      rethrow;
    } catch (e) {
      // 其他未知错误
      throw GeminiApiException(e.toString());
    }
  }

  // 2. Health Tip
  /// 生成健康小贴士（单句，偏预防/饮食）
  Future<String> analyzeHealthTip(Pet pet) async {
    if (!hasKey) return "Remember to keep fresh water available at all times!";
    try {
      final prompt = '''
        Give me a one-sentence health tip for a ${pet.breed}.
        Focus on preventive care or diet. Keep it friendly.
      ''';
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? "Regular vet visits keep your pet happy!";
    } catch (e) {
      return "Regular vet visits keep your pet happy!";
    }
  }

  // 3. Chat
  /// 与 AI 兽医简短对话（< 80 词）
  Future<String> chatWithVet(String message, Pet pet) async {
    if (!hasKey) return "Please set GEMINI_API_KEY to chat with Dr. AI.";
    try {
      final prompt = '''
        You are a friendly AI Vet Assistant. User has a ${pet.breed} named ${pet.name}.
        Answer concisely (under 80 words).
        User Question: $message
      ''';
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? "I'm not sure, better check with a vet!";
    } catch (e) {
      return "I'm having trouble thinking right now.";
    }
  }

  // 4. Translator
  /// 汪/喵声“翻译”为俏皮的人类语句（单句）
  Future<String> translatePetSound(Pet pet) async {
    if (!hasKey) return "Feed me. Now.";
    try {
      final prompt = '''
        You are a ${pet.breed} named ${pet.name}.
        Translate a random bark/meow into a funny, sassy human sentence.
        Max 1 sentence.
      ''';
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? "I am singing the song of my people!";
    } catch (e) {
      return "I am singing the song of my people!";
    }
  }

  // 5. Future Self
  /// 预测 5 年后的“未来自我”（星座运势式的幽默口吻，最多两句）
  Future<String> predictFutureSelf(Pet pet) async {
    if (!hasKey) return "Still the goodest boy, just slower.";
    try {
      final prompt = '''
        Predict the future of this ${pet.breed} named ${pet.name} in 5 years.
        Describe their personality evolution in a funny, horoscope-like way.
        Max 2 sentences.
      ''';
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? "Future unclear, ask again after treats.";
    } catch (e) {
      return "Future unclear, ask again after treats.";
    }
  }
}