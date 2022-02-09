import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:tuple/tuple.dart';

import 'package:visual_console/src/logger.dart';

class ConsoleMgr with ChangeNotifier {
  static Duration debounceDuration = const Duration(seconds: 1);

  /// 所有日志
  final List<VisualOutputEvent> _logs = [];

  /// 过滤后的日志
  List<VisualOutputEvent> _filterLogs = [];

  /// 过滤条件
  String? _condition;

  /// 检索字符串
  String? _searchString;

  /// 防止频繁构建的计时器
  Timer? _debounce;

  ConsoleMgr._();

  static ConsoleMgr? _instance;

  static ConsoleMgr get instance => _consoleMgr();
  List<VisualOutputEvent> get logs => _logs;
  List<VisualOutputEvent> get filterLogs => _filterLogs;
  String? get condition => _condition;
  String? get searchString => _searchString;

  /// 是否没有过滤条件
  bool get noCondition =>
      _condition == null && (_searchString == null || _searchString == "");

  static ConsoleMgr _consoleMgr() {
    _instance ??= ConsoleMgr._();
    return _instance!;
  }

  /// 新增一条log
  void addLog(VisualOutputEvent log) {
    _logs.insert(0, log);

    // 使用debounce减少频繁log导致的多次更新
    if (_debounce != null) {
      _debounce!.cancel();
    }
    _debounce = Timer(debounceDuration, () {
      notifyListeners();
    });
  }

  /// 清空log
  void clearLog() {
    _logs.clear();
    notifyListeners();
  }

  /// 删除一条log
  void deleteLog(VisualOutputEvent event) {
    logs.remove(event);
    logsFilter(_condition);
    notifyListeners();
  }

  /// 过滤日志
  void logsFilter(String? condition, [bool search = false]) {
    List<VisualOutputEvent> list;
    if (!search) {
      _condition = condition;
    } else {
      _searchString = condition;
    }
    switch (_condition) {
      case "Warn":
        _filterLogs =
            logs.where((element) => element.level == Level.warning).toList();
        list = _filterLogs;
        break;
      case "Error":
        _filterLogs =
            logs.where((element) => element.level == Level.error).toList();
        list = _filterLogs;
        break;
      default:
        list = _logs;
    }
    if (_searchString != null && _searchString != "") {
      var reg = RegExp(
        _searchString!,
        caseSensitive: false, // 大小写不明感
      );
      _filterLogs = list.where((element) {
        return element.log.contains(reg) ||
            (element.errorStack?.contains(reg) ?? false);
      }).toList();
    }
    notifyListeners();
  }

  static void showConsole() {
    BotToast.showWidget(
      toastBuilder: (_) => Builder(
        builder: (context) {
          return _Console(size: MediaQuery.of(context).size);
        }
      ),
      groupKey: "console",
    );
  }

  static const levelColors = {
    Level.verbose: Color(0xffb1b1f8),
    Level.debug: Color(0xfff1f1f1),
    Level.info: Colors.white,
    Level.warning: Color(0xfffffea1),
    Level.error: Color(0xffff6666),
    Level.wtf: Colors.black,
  };

  static const levelTextColors = {
    Level.verbose: Colors.blueGrey,
    Level.debug: Colors.black54,
    Level.info: Colors.black,
    Level.warning: Color(0xff715929),
    Level.error: Colors.white,
    Level.wtf: Colors.white,
  };
}

/// 控制台
class _Console extends StatefulWidget {
  final Size size;

  const _Console({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  _ConsoleState createState() => _ConsoleState();
}

class _ConsoleState extends State<_Console> {
  bool dragging = false;
  late Offset pos;
  final GlobalKey _entry = GlobalKey();
  final List<String> _tabItems = ['All', 'Error', 'Warn'];

  bool showPanel = false;

  @override
  void initState() {
    super.initState();
    pos = Offset(
      20,
      widget.size.height - 100
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size.height,
      width: widget.size.width,
      child: Stack(
        children: [
          Positioned(
            key: _entry,
            left: pos.dx,
            top: pos.dy,
            child: GestureDetector(
              onVerticalDragCancel: () {
                setState(() {
                  dragging = false;
                });
              },
              onVerticalDragUpdate: (detail) {
                final RenderBox box =
                    _entry.currentContext?.findRenderObject() as RenderBox;
                final size = box.size;
                var newPos = detail.globalPosition
                    .translate(-size.width / 2, -size.height / 2);
                setState(() {
                  pos = newPos;
                });
              },
              onVerticalDragStart: (detail) {
                setState(() {
                  dragging = true;
                });
              },
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                onPressed: () {
                  setState(() {
                    showPanel = true;
                  });

                  /// 每次打开重置一下
                  ConsoleMgr.instance.logsFilter(null);
                },
                child: const Text("Console"),
              ),
            ),
          ),
          // 蒙层
          if (showPanel)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showPanel = false;
                  });
                },
                child: const ColoredBox(
                  color: Colors.black38,
                ),
              ),
            ),
          // console面板
          if (showPanel)
            Positioned(
              bottom: 0,
              top: widget.size.height * 0.2,
              left: 0,
              right: 0,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                ),
                child: Material(
                  child: Column(
                    children: [
                      _ConsoleHeader(
                          tabItems: _tabItems,
                          onTabChange: (index) {
                            String? condition;
                            if (_tabItems[index] != "All") {
                              condition = _tabItems[index];
                            }
                            ConsoleMgr.instance.logsFilter(condition);
                          },
                          onClose: () {
                            setState(() {
                              showPanel = false;
                            });
                          }),
                      const _ConsoleBody(),
                      SizedBox(
                        height: 50,
                        child: ColoredBox(
                          color: const Color(0xfff6f6f6),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    ConsoleMgr.instance.clearLog();
                                  },
                                  child: const Text("Clear"),
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                                child: VerticalDivider(
                                  width: 10,
                                  color: Colors.grey,
                                  indent: 5,
                                  endIndent: 5,
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      showPanel = false;
                                    });
                                  },
                                  child: const Text("Hide"),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

/// 控制台内容主体滑动区域
class _ConsoleBody extends StatefulWidget {
  const _ConsoleBody({Key? key}) : super(key: key);

  @override
  State<_ConsoleBody> createState() => _ConsoleBodyState();
}

class _ConsoleBodyState extends State<_ConsoleBody> {
  late List<VisualOutputEvent> list;

  dynamic lastChange;

  @override
  void initState() {
    ConsoleMgr.instance.addListener(onConsoleChange);
    list = ConsoleMgr.instance.logs;
    super.initState();
  }

  @override
  dispose() {
    ConsoleMgr.instance.removeListener(onConsoleChange);
    super.dispose();
  }

  onConsoleChange() {
    var instance = ConsoleMgr.instance;
    var list = instance.noCondition ? instance.logs : instance.filterLogs;
    var tuple = Tuple4(
      list,
      list.length, // 当删除某一项时，只有长度会变
      instance.searchString, // 当搜索结果词变了的时候如果长度一直则不会刷新，所以要加上
      instance.condition, // 当条件改变的时候需要判断
    );
    if (tuple != lastChange) {
      lastChange = tuple;
      setState(() {
        this.list = list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.topCenter,
        color: Colors.white,
        child: ListView.builder(
          reverse: true,
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (context, index) {
            var event = list[index];
            return _LogListItem(event: event);
          },
        ),
      ),
    );
  }
}

/// log块
class _LogListItem extends StatelessWidget {
  final VisualOutputEvent event;
  const _LogListItem({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        Clipboard.setData(
          ClipboardData(
            text: event.log,
          ),
        );
        showSnack("Copied!");
      },
      onDoubleTap: () {
        ConsoleMgr.instance.deleteLog(event);
        showSnack("Deleted!");
      },
      child: ColoredBox(
        color: ConsoleMgr.levelColors[event.level]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              height: 0.5,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: ConsoleMgr.levelTextColors[event.level]!,
                ),
                child: _LogItem(event: event),
              ),
            ),
            const Divider(
              height: 0.5,
            ),
          ],
        ),
      ),
    );
  }
}

/// log内容块
class _LogItem extends StatefulWidget {
  final VisualOutputEvent event;
  const _LogItem({Key? key, required this.event}) : super(key: key);

  @override
  _LogItemState createState() => _LogItemState();
}

class _LogItemState extends State<_LogItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.event.log),
        if (widget.event.errorName != null)
          Text(
            widget.event.errorName!,
            style: TextStyle(
                fontSize: 15,
                color: ConsoleMgr.levelTextColors[widget.event.level]!,
                height: 2),
          ),
        if (widget.event.errorStack != null)
          Text(
            widget.event.errorStack!,
            style: TextStyle(
                fontSize: 12,
                color: ConsoleMgr.levelTextColors[widget.event.level]!,
                height: 2),
          ),
      ],
    );
  }
}

/// 控制台顶部
class _ConsoleHeader extends StatefulWidget {
  final List<String> tabItems;
  final Function(int) onTabChange;
  final Function() onClose;
  const _ConsoleHeader({
    Key? key,
    required this.tabItems,
    required this.onTabChange,
    required this.onClose,
  }) : super(key: key);

  @override
  _ConsoleHeaderState createState() => _ConsoleHeaderState();
}

class _ConsoleHeaderState extends State<_ConsoleHeader> {
  late final TabController tabController;
  bool showFilter = false;
  TextEditingController textEditController = TextEditingController();
  @override
  void initState() {
    tabController = TabController(
      length: widget.tabItems.length,
      vsync: ScrollableState(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ColoredBox(
            color: Colors.green,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: TabBar(
                      controller: tabController,
                      indicatorColor: Colors.white,
                      tabs: widget.tabItems
                          .map((s) => Tab(child: Text(s)))
                          .toList(),
                      onTap: (idx) {
                        widget.onTabChange(idx);
                      },
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      showFilter = !showFilter;
                    });
                  },
                  child: Icon(
                    Icons.filter_alt_outlined,
                    color: showFilter ? Colors.blue[200] : Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    BotToast.removeAll("console");
                    // ignore: avoid_print
                    print(
                        "visual console closed! hot-restart to show it again!");

                    showSnack("See U Again!");
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showFilter)
          SizedBox(
            height: 50,
            child: Overlay(
              initialEntries: [
                OverlayEntry(builder: (_) {
                  return ListTile(
                    leading: IconButton(
                      onPressed: () {
                        var val = textEditController.text;
                        ConsoleMgr.instance
                            .logsFilter(val == "" ? null : val, true);
                      },
                      icon: const Icon(Icons.search),
                    ),
                    title: TextField(
                      controller: textEditController,
                      onSubmitted: (val) {
                        ConsoleMgr.instance
                            .logsFilter(val == "" ? null : val, true);
                      },
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        textEditController.clear();
                        ConsoleMgr.instance.logsFilter(null, true);
                      },
                    ),
                  );
                })
              ],
            ),
          )
      ],
    );
  }
}

void showSnack(String title) {
  BotToast.showSimpleNotification(
    title: title,
    align: const Alignment(0, -0.99),
    dismissDirections: const [DismissDirection.up],
  );
}