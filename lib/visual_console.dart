library visual_console;

import 'package:flutter/material.dart';
import 'package:visual_console/src/console.dart';

export 'package:logger/logger.dart';
export 'package:visual_console/src/console.dart';
export 'package:visual_console/src/logger.dart';

class VisualConsole {
  static TransitionBuilder init([ConsoleConfiguration? config]) {
    ConsoleMgr.config = config ?? ConsoleConfiguration();
    return (context, Widget? child) => Console(size: MediaQuery.of(context).size);
  }
}
