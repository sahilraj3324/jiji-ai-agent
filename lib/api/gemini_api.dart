import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Gemini API service for chat interactions
class GeminiApi {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  final String apiKey;

  GeminiApi({required this.apiKey});

  /// Send a message to Gemini and get a response
  ///
  /// [message] - The user's message
  /// [conversationHistory] - Previous messages for context (optional)
  /// Returns the AI response text
  Future<String> sendMessage({
    required String message,
    List<Map<String, dynamic>>? conversationHistory,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/models/gemini-2.5-flash:generateContent?key=AIzaSyDRs9nXzU7WcNB2KTepbpVhuQsO3MOjvM0',
    );

    // Build the contents array with conversation history
    final List<Map<String, dynamic>> contents = [];

    // Add conversation history if provided
    if (conversationHistory != null) {
      contents.addAll(conversationHistory);
    }

    // Add the current user message
    contents.add({
      'role': 'user',
      'parts': [
        {'text': message},
      ],
    });

    final body = jsonEncode({
      'contents': contents,
      'generationConfig': {
        'temperature': 0.9,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
      ],
    });

    debugPrint('API URL: $url');
    debugPrint('Request body: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;

        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;

          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] ?? 'No response generated';
          }
        }
        return 'No response generated';
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        throw GeminiApiException('API Error: $errorMessage');
      }
    } catch (e) {
      debugPrint('Exception: $e');
      if (e is GeminiApiException) rethrow;
      throw GeminiApiException('Network error: $e');
    }
  }

  /// Stream a response from Gemini (for real-time typing effect)
  ///
  /// [message] - The user's message
  /// [conversationHistory] - Previous messages for context (optional)
  /// Returns a stream of response text chunks
  Stream<String> streamMessage({
    required String message,
    List<Map<String, dynamic>>? conversationHistory,
  }) async* {
    final url = Uri.parse(
      '$_baseUrl/models/gemini-2.5-flash:streamGenerateContent?key=AIzaSyDRs9nXzU7WcNB2KTepbpVhuQsO3MOjvM0',
    );

    final List<Map<String, dynamic>> contents = [];

    if (conversationHistory != null) {
      contents.addAll(conversationHistory);
    }

    contents.add({
      'role': 'user',
      'parts': [
        {'text': message},
      ],
    });

    final body = jsonEncode({
      'contents': contents,
      'generationConfig': {
        'temperature': 0.9,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
    });

    try {
      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      request.body = body;

      final streamedResponse = await http.Client().send(request);

      if (streamedResponse.statusCode == 200) {
        await for (final chunk in streamedResponse.stream.transform(
          utf8.decoder,
        )) {
          // Parse the JSON chunks from the stream
          final lines = chunk.split('\n');
          for (final line in lines) {
            if (line.trim().isEmpty) continue;
            try {
              // Handle the streaming JSON format
              var jsonStr = line.trim();
              if (jsonStr.startsWith('[')) jsonStr = jsonStr.substring(1);
              if (jsonStr.startsWith(',')) jsonStr = jsonStr.substring(1);
              if (jsonStr.endsWith(']'))
                jsonStr = jsonStr.substring(0, jsonStr.length - 1);

              if (jsonStr.trim().isEmpty) continue;

              final data = jsonDecode(jsonStr);
              final candidates = data['candidates'] as List?;

              if (candidates != null && candidates.isNotEmpty) {
                final content = candidates[0]['content'];
                final parts = content?['parts'] as List?;

                if (parts != null && parts.isNotEmpty) {
                  final text = parts[0]['text'];
                  if (text != null) yield text;
                }
              }
            } catch (_) {
              // Skip malformed chunks
            }
          }
        }
      } else {
        throw GeminiApiException(
          'Stream error: ${streamedResponse.statusCode}',
        );
      }
    } catch (e) {
      if (e is GeminiApiException) rethrow;
      throw GeminiApiException('Network error: $e');
    }
  }
}

/// Custom exception for Gemini API errors
class GeminiApiException implements Exception {
  final String message;
  GeminiApiException(this.message);

  @override
  String toString() => 'GeminiApiException: $message';
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  /// Convert to Gemini API format
  Map<String, dynamic> toGeminiFormat() {
    return {
      'role': isUser ? 'user' : 'model',
      'parts': [
        {'text': text},
      ],
    };
  }
}
