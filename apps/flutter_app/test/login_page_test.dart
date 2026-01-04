import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_app/main.dart';

void main() {
  test('fetchStatus parses wrapped status response', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/auth/status');
      return http.Response(
        jsonEncode({
          'code': 0,
          'data': {
            'initialized': true,
            'oidc_enabled': false,
            'totp_enabled': true,
            'captcha_enabled': false,
            'registration_enabled': true,
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final api = AuthApiClient(
      baseUrl: 'https://xn.example.com',
      client: client,
    );
    final status = await api.fetchStatus();
    expect(status.initialized, isTrue);
    expect(status.registrationEnabled, isTrue);
    expect(status.totpEnabled, isTrue);
  });

  test('login posts credentials to xuannexus login api', () async {
    late Map<String, dynamic> body;
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/auth/login');
      body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'code': 0,
          'data': {'access_token': 'token123'},
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final api = AuthApiClient(
      baseUrl: 'https://xn.example.com',
      client: client,
    );
    final result = await api.login(
      username: 'demo',
      password: 'pwd',
      totpCode: '123456',
    );
    expect(body['username'], 'demo');
    expect(body['totp_code'], '123456');
    expect(result.accessToken, 'token123');
  });

  testWidgets('register button is shown when backend allows registration',
      (tester) async {
    final client = MockClient((request) async {
      if (request.url.path == '/api/v1/auth/status') {
        return http.Response(
          jsonEncode({
            'code': 0,
            'data': {
              'initialized': true,
              'oidc_enabled': false,
              'totp_enabled': false,
              'captcha_enabled': false,
              'registration_enabled': true,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response('{}', 404);
    });
    final api = AuthApiClient(
      baseUrl: 'https://xn.example.com',
      client: client,
    );
    await tester.pumpWidget(MaterialApp(home: LoginPage(apiClient: api)));
    await tester.pumpAndSettle();
    expect(find.text('用户注册'), findsOneWidget);
  });
}
