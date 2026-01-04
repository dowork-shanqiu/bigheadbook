import 'package:flutter/material.dart';

void main() {
  runApp(const BigHeadBookApp());
}

class BigHeadBookApp extends StatelessWidget {
  const BigHeadBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '木木记账',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('木木记账 · BigHeadBook')),
      body: const Center(
        child: Text('Hello, world! 准备好记一笔了吗？'),
      ),
    );
  }
}
