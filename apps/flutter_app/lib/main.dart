import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String kDefaultBaseUrl = 'https://xn.example.com';
const Duration kRequestTimeout = Duration(seconds: 15);

void main() {
  runApp(const BigHeadBookApp());
}

class BigHeadBookApp extends StatelessWidget {
  const BigHeadBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '大头记账',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.apiClient});

  final AuthApiClient? apiClient;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _totpController = TextEditingController();
  final _baseUrlController = TextEditingController(text: kDefaultBaseUrl);

  late final AuthApiClient _apiClient;
  AuthStatus? _status;
  bool _loadingStatus = false;
  bool _loggingIn = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? AuthApiClient(baseUrl: kDefaultBaseUrl);
    _baseUrlController.addListener(_handleBaseUrlChange);
    _fetchStatus();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _totpController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  void _handleBaseUrlChange() {
    _apiClient.baseUrl = _baseUrlController.text.trim();
  }

  Future<void> _fetchStatus() async {
    setState(() {
      _loadingStatus = true;
      _message = null;
    });
    try {
      final status = await _apiClient.fetchStatus();
      setState(() {
        _status = status;
        _message = '已连接 ${_apiClient.baseUrl}';
      });
    } catch (error) {
      setState(() {
        _status = null;
        _message = '获取状态失败: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingStatus = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loggingIn = true;
      _message = null;
    });
    try {
      await _apiClient.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        totpCode: _status?.totpEnabled == true &&
                _totpController.text.trim().isNotEmpty
            ? _totpController.text.trim()
            : null,
      );
      setState(() {
        _message = '登录成功';
      });
    } catch (error) {
      setState(() {
        _message = '登录失败: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loggingIn = false;
        });
      }
    }
  }

  bool get _showRegister {
    if (_status == null) return false;
    return !_status!.initialized || _status!.registrationEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('大头记账 · 登录')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 16),
                    _buildForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _status;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: '后端域名',
                helperText: '默认指向 https://xn.example.com，支持快速修改',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _loadingStatus ? null : _fetchStatus,
                  icon: _loadingStatus
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('检测后端状态'),
                ),
                const SizedBox(width: 8),
                if (status != null)
                  Chip(
                    label: Text(status.initialized ? '已初始化' : '待初始化'),
                    avatar: Icon(
                      status.initialized ? Icons.check_circle : Icons.info,
                      color:
                          status.initialized ? Colors.green : Colors.orangeAccent,
                    ),
                  ),
              ],
            ),
            if (status != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _StatusBadge(
                    active: status.oidcEnabled,
                    label: 'OIDC 登录',
                  ),
                  _StatusBadge(
                    active: status.totpEnabled,
                    label: 'TOTP 校验',
                  ),
                  _StatusBadge(
                    active: status.captchaEnabled,
                    label: '滑块验证',
                  ),
                  _StatusBadge(
                    active: status.registrationEnabled,
                    label: '用户注册',
                  ),
                ],
              ),
            ],
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(
                _message!,
                style: TextStyle(
                  color: _message!.startsWith('登录成功') ||
                          _message!.startsWith('已连接')
                      ? Colors.green[700]
                      : Colors.red[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    final status = _status;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: '用户名 / 邮箱',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? '请输入用户名或邮箱' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: '密码',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
            validator: (value) =>
                (value == null || value.isEmpty) ? '请输入密码' : null,
          ),
          if (status?.totpEnabled == true) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _totpController,
              decoration: const InputDecoration(
                labelText: '动态验证码（TOTP）',
                prefixIcon: Icon(Icons.shield_outlined),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loggingIn ? null : _submit,
            icon: _loggingIn
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.login),
            label: const Text('登录'),
          ),
          if (_showRegister) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('用户注册'),
                    content: const Text('请在后续版本中完成注册流程，当前仅展示入口。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('好的'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.app_registration),
              label: const Text('用户注册'),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active, required this.label});

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      avatar: Icon(
        active ? Icons.check_circle : Icons.remove_circle_outline,
        color: active ? Colors.green : Colors.grey,
        size: 18,
      ),
      backgroundColor: active
          ? Colors.green.withOpacity(0.1)
          : Theme.of(context).colorScheme.surfaceVariant,
    );
  }
}

class AuthStatus {
  const AuthStatus({
    required this.initialized,
    required this.oidcEnabled,
    required this.totpEnabled,
    required this.captchaEnabled,
    required this.registrationEnabled,
  });

  factory AuthStatus.fromJson(Map<String, dynamic> json) {
    return AuthStatus(
      initialized: json['initialized'] == true,
      oidcEnabled: json['oidc_enabled'] == true,
      totpEnabled: json['totp_enabled'] == true,
      captchaEnabled: json['captcha_enabled'] == true,
      registrationEnabled: json['registration_enabled'] == true,
    );
  }

  final bool initialized;
  final bool oidcEnabled;
  final bool totpEnabled;
  final bool captchaEnabled;
  final bool registrationEnabled;
}

class LoginResult {
  const LoginResult({
    this.accessToken,
    this.refreshToken,
    this.requireTotp,
    this.forcePasswordReset,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      accessToken: (json['access_token'] ?? json['accessToken']) as String?,
      refreshToken: (json['refresh_token'] ?? json['refreshToken']) as String?,
      requireTotp: json['require_totp'] == true,
      forcePasswordReset: json['force_password_reset'] == true,
    );
  }

  final String? accessToken;
  final String? refreshToken;
  final bool? requireTotp;
  final bool? forcePasswordReset;
}

class AuthApiClient {
  AuthApiClient({
    String baseUrl = kDefaultBaseUrl,
    http.Client? client,
  })  : _baseUrl = baseUrl,
        _client = client ?? http.Client();

  final http.Client _client;
  String _baseUrl;

  String get baseUrl => _baseUrl;

  set baseUrl(String value) {
    _baseUrl = value.isEmpty ? kDefaultBaseUrl : value;
  }

  Uri _uri(String path) {
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalized$path');
  }

  Map<String, String> get _jsonHeaders => {'Content-Type': 'application/json'};

  Future<AuthStatus> fetchStatus() async {
    final response = await _client
        .get(_uri('/api/v1/auth/status'))
        .timeout(kRequestTimeout);
    return _decodeResponse<AuthStatus>(
      response,
      AuthStatus.fromJson,
    );
  }

  Future<LoginResult> login({
    required String username,
    required String password,
    String? totpCode,
  }) async {
    final body = {
      'username': username,
      'password': password,
      if (totpCode != null && totpCode.isNotEmpty) 'totp_code': totpCode,
    };
    final response = await _client
        .post(
          _uri('/api/v1/auth/login'),
          headers: _jsonHeaders,
          body: jsonEncode(body),
        )
        .timeout(kRequestTimeout);
    return _decodeResponse<LoginResult>(
      response,
      LoginResult.fromJson,
    );
  }

  T _decodeResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic> json) parser,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('响应格式不正确');
    }
    final code = decoded['code'];
    if (code is num && code != 0) {
      final message = decoded['message'] ?? '后端返回错误 ($code)';
      throw Exception(message);
    }
    final data = code == null ? decoded : decoded['data'] ?? {};
    if (data is! Map<String, dynamic>) {
      throw Exception('响应数据格式不正确');
    }
    return parser(data);
  }
}
