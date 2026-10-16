import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:projectappice/data/gemini_client.dart';

void main() {
  const okBody = '''
  {
    "candidates": [
      {
        "content": {
          "parts": [
            { "text": "สวัสดี" },
            { "text": "ครับ" }
          ],
          "role": "model"
        },
        "finishReason": "STOP"
      }
    ]
  }
  ''';

  (GeminiClient, List<http.Request>) fakeClient(int status, String body) {
    final seen = <http.Request>[];
    final mock = MockClient((request) async {
      seen.add(request);
      return http.Response(
        body,
        status,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final client = GeminiClient(apiKey: 'test-key', client: mock);
    return (client, seen);
  }

  test('ไม่มี API key ให้ throw AiException', () {
    final client = GeminiClient(apiKey: '');
    expect(
      () => client.generate(prompt: 'ทดสอบ'),
      throwsA(isA<AiException>()),
    );
  });

  test('ส่ง header x-goog-api-key และ body ตามรูปแบบ Gemini', () async {
    final (client, seen) = fakeClient(200, okBody);
    final text = await client.generate(
      prompt: 'ทดสอบ',
      systemInstruction: 'คุณคือเชฟ',
    );

    expect(text, 'สวัสดีครับ'); // รวมข้อความจากทุก part
    expect(seen, hasLength(1));
    final req = seen.single;
    expect(req.method, 'POST');
    expect(req.url.toString(), contains(':generateContent'));
    expect(req.url.queryParameters.containsKey('key'), isFalse); // key ไม่หลุดไปอยู่ใน URL
    expect(req.headers['x-goog-api-key'], 'test-key');

    final body = jsonDecode(req.body) as Map<String, dynamic>;
    expect(body['contents'][0]['parts'][0]['text'], 'ทดสอบ');
    expect(body['system_instruction']['parts'][0]['text'], 'คุณคือเชฟ');
    expect(body['generationConfig'].containsKey('responseSchema'), isFalse);
  });

  test('ถ้า HTTP status != 200 ให้ throw AiException', () async {
    final (client, _) = fakeClient(400, '{"error": {"message": "API key not valid"}}');
    expect(
      () => client.generate(prompt: 'ทดสอบ'),
      throwsA(isA<AiException>()),
    );
  });

  test('ถ้า timeout ให้ throw AiException', () async {
    final mock = MockClient((request) async {
      throw TimeoutException('AI Timeout');
    });
    final client = GeminiClient(apiKey: 'test-key', client: mock);

    expect(
      () => client.generate(prompt: 'ทดสอบ'),
      throwsA(isA<AiException>()),
    );
  });

  test('ถ้าไม่มีเน็ตให้ throw AiException', () async {
    final mock = MockClient((request) async {
      throw const SocketException('No Internet');
    });
    final client = GeminiClient(apiKey: 'test-key', client: mock);

    expect(
      () => client.generate(prompt: 'ทดสอบ'),
      throwsA(isA<AiException>()),
    );
  });

  test('extractText แกะข้อความและตรวจบล็อก', () {
    final blocked = {
      'promptFeedback': {'blockReason': 'SAFETY'}
    };
    expect(
      () => GeminiClient.extractText(blocked),
      throwsA(isA<AiException>()),
    );

    final emptyCandidates = <String, dynamic>{'candidates': []};
    expect(
      () => GeminiClient.extractText(emptyCandidates),
      throwsA(isA<AiException>()),
    );
  });
}
