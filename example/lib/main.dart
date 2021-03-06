import 'dart:io';

import 'package:flutter/material.dart';

import 'package:visual_console/visual_console.dart';

var logger = VisualLogger(
  filter: ProductionFilter(),
  output: VisualOutput(),
  printer: VisualPrinter(
    realPrinter: VisualPrefixPrinter(
      methodCount: 1,
      lineLength: () {
        int lineLength = 80;
        try {
          // 获取控制台一行能打印多少字符
          lineLength = stdout.terminalColumns;
        } catch (e) {
          // ignore: empty_catches
        }
        return lineLength;
      }(),
      colors: stdout.supportsAnsiEscapes, // Colorful log messages
      printEmojis: false, // 打印表情符号
      printTime: true, // 打印时间
    ),
  ),
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visual Console Demo',
      home: Builder(
        builder: (context) {
          return const MyHomePage();
        },
      ),
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            const Console(),
          ],
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visual Console"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                logger.v("verbose");
                logger.d("debug");
                logger.i("info");
                logger.w("warning");
                logger.e("error");
                logger.wtf("wtf");
              },
              child: const Text("Tap to log"),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  throw Exception("error");
                } catch (e, s) {
                  logger.e("catch error", e, s);
                }
              },
              child: const Text("Tap to error"),
            ),
          ],
        ),
      ),
    );
  }
}
