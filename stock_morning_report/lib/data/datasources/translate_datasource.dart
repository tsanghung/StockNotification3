import 'dart:async';
import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';

class TranslateDatasource {
  final Dio _dio;

  TranslateDatasource(this._dio);

  /// 翻譯單一英文標題為繁體中文
  /// 使用 Google Translate 非官方端點（與 google-translate-api-next 相同原理）
  Future<String> translateToZhTw(String text) async {
    if (text.isEmpty) return text;

    try {
      final response = await _dio.get(
        ApiConstants.googleTranslate,
        queryParameters: {
          'client': 'gtx',
          'sl': 'en',
          'tl': 'zh-TW',
          'dt': 't',
          'q': text,
        },
      );

      // 回應格式：[[["翻譯結果","原文",...], ...], ...]
      final data = response.data as List<dynamic>;
      final translations = data[0] as List<dynamic>;
      final result = translations
          .map((t) => (t as List<dynamic>)[0] as String? ?? '')
          .join('');

      return result.isNotEmpty ? result : text;
    } catch (_) {
      // 翻譯失敗時回傳原文（對應 news.js 的 catch 行為）
      return text;
    }
  }

  /// 批次翻譯多個標題，每批 5 個，避免 rate limit
  Future<List<String>> translateBatch(List<String> texts) async {
    if (texts.isEmpty) return [];

    final results = <String>[];
    const batchSize = 5;

    for (var i = 0; i < texts.length; i += batchSize) {
      final batch = texts.skip(i).take(batchSize).toList();
      final translated = await Future.wait(
        batch.map(translateToZhTw),
      );
      results.addAll(translated);

      // 批次間小延遲，避免 rate limit
      if (i + batchSize < texts.length) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    return results;
  }
}
