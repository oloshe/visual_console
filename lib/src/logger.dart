import 'dart:core';

import 'package:logger/logger.dart';
import 'package:visual_console/src/console.dart';

/// 继承 Logger 重写log方法
/// 让打印到控制台和vconsole的log分别处理
class VisualLogger extends Logger {
  final LogFilter _filter;
  final VisualPrinter _printer;
  final VisualOutput _output;

  VisualLogger({
    required VisualPrinter printer,
    LogFilter? filter,
    VisualOutput? output,
  })  : _printer = printer,
        _filter = filter ?? DevelopmentFilter(),
        _output = output ?? VisualOutput(),
        super(
        filter: filter,
        printer: printer,
        output: output,
      );

  @override
  void log(Level level, message, [error, StackTrace? stackTrace]) {
    // 原本的log逻辑 打印在控制台中
    super.log(level, message, error, stackTrace);
    // 重写的逻辑 打印在 VConsole 里
    var logEvent = LogEvent(level, message, error, stackTrace);
    if (_filter.shouldLog(logEvent)) {
      String output = _printer.visualLog(logEvent);
      if (output.isNotEmpty) {
        var outputEvent = _printer.process(logEvent, output);
        try {
          _output.printToVisualConsole(outputEvent);
        } catch (e, s) {
          // ignore: avoid_print
          print(e); print(s);
        }
      }
    }
  }
}

class VisualOutputEvent {
  final Level level;
  final String log;
  final String? errorName;
  final String? errorStack;

  VisualOutputEvent(this.level, this.log, {this.errorName, this.errorStack});
}

class VisualOutput extends ConsoleOutput {
  /// 打印到 vconsole 里
  void printToVisualConsole(VisualOutputEvent event) {
    ConsoleMgr.instance.addLog(event);
  }
}

class VisualPrinter extends PrefixPrinter {
  final VisualPrefixPrinter _realPrinter;

  VisualPrinter({
    required VisualPrefixPrinter realPrinter,
  })
      : _realPrinter = realPrinter,
        super(realPrinter);

  // 返回 log 的文本
  String visualLog(LogEvent event) {
    var messageStr = _realPrinter.stringifyMessage(event.message);
    return messageStr;
  }

  /// 处理调用栈的信息并返回 [VisualOutputEvent] 实例
  VisualOutputEvent process(LogEvent event, String logs) {
    String? errorName;
    if (event.error != null) {
      errorName = event.error.toString();
    }
    String? stackTraceStr;
    if (event.stackTrace == null) {
      if (_realPrinter.methodCount > 0) {
        stackTraceStr = _realPrinter.formatStackTrace(
            StackTrace.current, _realPrinter.methodCount);
      }
    } else if (_realPrinter.errorMethodCount > 0) {
      stackTraceStr = _realPrinter.formatStackTrace(
          event.stackTrace, _realPrinter.errorMethodCount);
    }
    return VisualOutputEvent(event.level, logs,
        errorName: errorName, errorStack: stackTraceStr);
  }
}

// 继承PrettyPrinter，重写formatStackTrace方法
// 解决stackTraceBeginIndex不能正确生效的问题
class VisualPrefixPrinter extends PrettyPrinter {

  VisualPrefixPrinter({
    int stackTraceBeginIndex = 0,
    int methodCount = 2,
    int errorMethodCount = 8,
    int lineLength = 120,
    bool colors = true,
    bool printEmojis = true,
    bool printTime = false,
  }) : super(
    stackTraceBeginIndex: stackTraceBeginIndex,
    methodCount: methodCount,
    errorMethodCount: errorMethodCount,
    lineLength: lineLength,
    colors: colors,
    printEmojis: printEmojis,
    printTime: printTime,
  );

  @override
  String? formatStackTrace(StackTrace? stackTrace, int methodCount) {
    var lines = stackTrace.toString().split('\n');
    var formatted = <String>[];
    var count = 0;
    for (var line in lines) {
      if (_discardDeviceStacktraceLine(line) || line.isEmpty) {
        continue;
      }
      formatted.add('#$count   ${line.replaceFirst(RegExp(r'#\d+\s+'), '')}');
      if (++count == methodCount) {
        break;
      }
    }

    if (formatted.isEmpty) {
      return null;
    } else {
      return formatted.join('\n');
    }
  }

  /// 来自父类 [PrettyPrinter]
  static final _deviceStackTraceRegex =
  RegExp(r'#[0-9]+[\s]+(.+) \(([^\s]+)\)');

  /// 来自父类 [PrettyPrinter]
  bool _discardDeviceStacktraceLine(String line) {
    var match = _deviceStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    var str = match.group(2)!;
    return str.startsWith('package:logger')
        || str.startsWith('package:visual_console');
  }
}
