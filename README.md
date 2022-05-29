# Visual Console

A visual console inspired by VConsole.

## Features

- __configurable__: It's a [`Logger`](https://github.com/leisim/logger) Plugin.
- __simple__: two channel output, IDE's console and screen visual-console.
- __tiny__: It has a small size.
- __fast__: It works fast and smooth.
- __powerful__: Filter、Search, StackTrace, Clean, Copy, Delete some log by double-click and etc.

## Getting started

### 1. Define Logger

``` dart
final logger = VisualLogger(
  filter: ProductionFilter(),
  output: VisualOutput(),
  printer: VisualPrinter(
    realPrinter: VisualPrefixPrinter(
      methodCount: 1,
      lineLength: () {
        int lineLength = 80;
        try {
          lineLength = stdout.terminalColumns;
        } catch (e) {}
        return lineLength;
      }(),
      colors: stdout.supportsAnsiEscapes, // Colorful log messages
      printEmojis: false,
      printTime: true,
    ),
  ),
);
```

### 2. Init

``` dart
MaterialApp(
  title: 'Visual Console Demo',
  home: const MyHomePage(),
  builder: (context, child) {
    return Stack(
      children: [
        child!,
        const Console(),
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