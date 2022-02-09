# Visual Console

A Visual Console inspired by VConsole.

## Features

- __tiny__: It has a small size.
- __quickly__: It works smooth.
- __powerful__: Filter、Search、StackTrace、Clear logs、Delete specific huge log by double-click...

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
      printTime: false, // 打印时间
    ),
  ),
);
```

### 2. Init `BotToast`

``` dart
MaterialApp(
  title: 'Visual Console Demo',
  home: Builder(
    builder: (context) {
      return const MyHomePage();
    },
  ),
  navigatorObservers: [BotToastNavigatorObserver()],
  builder: BotToastInit(),
);
```

### 3. Init `VisualConsole`

``` dart
VisualConsole.init();
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

## Additional information

this package is a plugin of [`Logger`](https://github.com/leisim/logger) and it depends on [`BotToast`](https://github.com/MMMzq/bot_toast) package;