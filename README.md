# Visual Console

A visual console inspired by VConsole.

## Features

- __configurable__: It's a [`Logger`](https://github.com/leisim/logger) Plugin.
- __simple__: two channel output, IDE's console and screen visual-console.
- __tiny__: It has a small size.
- __blazing__: It works fast and smooth.
- __powerful__: Filter、Search, StackTrace, Clean, Copy, Delete some log by double-click and etc.

## Getting started

### 1. Define Logger

``` dart
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
        } catch (e) {}
        return lineLength;
      }(),
      colors: io.stdout.supportsAnsiEscapes, // Colorful log messages
      printEmojis: false, // 打印表情符号
      printTime: true, // 打印时间
    ),
  ),
);
```

### 2. Init

``` dart
MaterialApp(
  title: 'Visual Console Demo',
  home: const MyHomePage(),
  builder: VisualConsole.init(),
);
```

### 3. (*) If Use With BotToast

You can choose which layer should cover other one.

```dart
var botToastBuilder = BotToastInit();
MaterialApp(
  title: 'Visual Console Demo',
  home: const MyHomePage(),
  builder: (context, child) {
  child = botToastBuilder(context, child);
  return Stack(
    children: [
      VisualConsole.init(
        ConsoleConfiguration(
            // ... configure you own
        )
      )(context, child),
    ],
  );
 },
);
```

## Usage

```dart
logger.v("verbose");
logger.d("debug");
logger.i("info");
logger.w("warning");
logger.e("error");
logger.wtf("wtf");
```

## Screen Shot

![截图](https://github.com/oloshe/visual_console/blob/main/img/Simulator%20Screen%20Shot%20-%20iPhone%2013.png?raw=true)

## Additional information

this package is a plugin of [`Logger`](https://github.com/leisim/logger);