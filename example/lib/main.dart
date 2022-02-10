import 'dart:io' as io;

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
          lineLength = io.stdout.terminalColumns;
        } catch (e) {
          // ignore: empty_catches
        }
        return lineLength;
      }(),
      colors: io.stdout.supportsAnsiEscapes, // Colorful log messages
      printEmojis: false, // 打印表情符号
      printTime: false, // 打印时间
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
      navigatorObservers: [BotToastNavigatorObserver()],
      builder: BotToastInit(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    VisualConsole.init();
    logger.i("welcome to visual console");
  }

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
                try  {
                  throw Exception("error");
                } catch(e, s) {
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