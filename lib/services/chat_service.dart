import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ChatService {
  // Gemini API configuration (v1beta, Gemini 2.0 Flash)
  // IMPORTANT: Use a Gemini API key from Google AI Studio
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const String _apiKey =
      'AIzaSyDx_05TCfWpVdrp4aYNsBUzMZJm8BS50gI'; // ضع مفتاحك هنا

  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  Future<String> getAIResponse(String message) async {
    if (kDebugMode) {
      print('Sending message to API: $message');
    }

    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        if (message.trim().isEmpty) {
          return 'Please enter a message';
        }

        final response = await http.post(
          Uri.parse('$_apiUrl?key=$_apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': message},
                ],
              },
            ],
          }),
        );

        if (kDebugMode) {
          print('Response status code: [32m${response.statusCode}[0m');
          print('Response body: ${response.body}');
        }

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text =
              data['candidates']?[0]?['content']?['parts']?[0]?['text'];
          if (text != null) {
            if (kDebugMode) {
              print('Successfully parsed response: $text');
            }
            return text;
          } else {
            if (kDebugMode) {
              print('No response from Gemini.');
            }
            return 'No response from Gemini.';
          }
        } else {
          // Always print and return the full error body for easier debugging
          if (kDebugMode) {
            print('Full error body: ${response.body}');
          }
          return 'Error: ${response.statusCode} - ${response.reasonPhrase}\n${response.body}';
        }
      } on TimeoutException {
        if (kDebugMode) {
          print('Request timed out');
        }
        retryCount++;
        if (retryCount < _maxRetries) {
          if (kDebugMode) {
            print(
              'Retrying after timeout... (Attempt $retryCount of $_maxRetries)',
            );
          }
          await Future.delayed(_retryDelay);
          continue;
        }
        return 'Request timed out. Please try again.';
      } on http.ClientException catch (e) {
        if (kDebugMode) {
          print('Network error: $e');
        }
        retryCount++;
        if (retryCount < _maxRetries) {
          if (kDebugMode) {
            print(
              'Retrying after network error... (Attempt $retryCount of $_maxRetries)',
            );
          }
          await Future.delayed(_retryDelay);
          continue;
        }
        return 'Network error: Please check your internet connection';
      } catch (e) {
        if (kDebugMode) {
          print('Unexpected error: $e');
        }
        return 'Error connecting to Gemini AI.';
      }
    }
    return 'Maximum retry attempts reached. Please try again later.';
  }
}
