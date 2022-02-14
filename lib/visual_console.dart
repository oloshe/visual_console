library visual_console;

import 'package:visual_console/src/console.dart';

export 'package:bot_toast/bot_toast.dart';
export 'package:logger/logger.dart';
export 'package:visual_console/src/console.dart';
export 'package:visual_console/src/logger.dart';


class VisualConsole {
  static init([ConsoleConfiguration? config]) {
    ConsoleMgr.showConsole(config ?? ConsoleConfiguration());
  }
}
