import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:rule_dev_tool/utils/utils.dart';
import 'package:rule_dev_tool/bean/dialog/dialog_helper.dart';
import 'package:rule_dev_tool/plugins/plugins.dart';
import 'package:rule_dev_tool/plugins/plugins_controller.dart';
import 'package:rule_dev_tool/bean/appbar/sys_app_bar.dart';

class PluginViewPage extends StatefulWidget {
  const PluginViewPage({super.key});

  @override
  State<PluginViewPage> createState() => _PluginViewPageState();
}

class _PluginViewPageState extends State<PluginViewPage> {
  final PluginsController pluginsController = Modular.get<PluginsController>();

  bool isMultiSelectMode = false;
  final Set<String> selectedNames = {};

  void _handleAdd() {
    KazumiDialog.show(builder: (context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('新建规则'),
                onTap: () {
                  KazumiDialog.dismiss();
                  Modular.to.pushNamed('/settings/plugin/editor',
                      arguments: Plugin.fromTemplate());
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('从规则仓库导入'),
                onTap: () {
                  KazumiDialog.dismiss();
                  Modular.to.pushNamed('/settings/plugin/shop');
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('从剪贴板导入'),
                onTap: () {
                  KazumiDialog.dismiss();
                  _showInputDialog();
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showInputDialog() {
    final TextEditingController textController = TextEditingController();
    final dialogContext = context;
    KazumiDialog.show(builder: (context) {
      return AlertDialog(
        title: const Text('导入规则'),
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: '请粘贴规则链接',
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => KazumiDialog.dismiss(),
            child: Text(
              '取消',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return TextButton(
              onPressed: () async {
                final String msg = textController.text.trim();
                try {
                  pluginsController.updatePlugin(Plugin.fromJson(
                      json.decode(Utils.kazumiBase64ToJson(msg))));
                  KazumiDialog.showToast(message: '导入成功', context: dialogContext);
                  KazumiDialog.dismiss();
                } catch (e) {
                  KazumiDialog.showToast(message: '导入失败 ${e.toString()}', context: dialogContext);
                }
              },
              child: const Text('导入'),
            );
          })
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isMultiSelectMode,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (isMultiSelectMode) {
          setState(() {
            isMultiSelectMode = false;
            selectedNames.clear();
          });
          return;
        }
      },
      child: Scaffold(
        appBar: SysAppBar(
          title: isMultiSelectMode
              ? Text('已选择 ${selectedNames.length} 项')
              : const Text('规则管理'),
          leading: isMultiSelectMode
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      isMultiSelectMode = false;
                      selectedNames.clear();
                    });
                  },
                )
              : null,
          actions: isMultiSelectMode
              ? [
                  IconButton(
                    onPressed: selectedNames.isEmpty
                        ? null
                        : () {
                            _showDeleteDialog();
                          },
                    icon: const Icon(Icons.delete),
                  ),
                ]
              : [],
        ),
        body: AnimatedBuilder(
          animation: pluginsController,
          builder: (context, child) {
            return Stack(
              children: [
              pluginsController.pluginList.isEmpty
                  ? const Center(
                      child: Text('啊咧（⊙.⊙） 没有可用规则的说'),
                    )
                  : Builder(builder: (context) {
                      return ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          proxyDecorator: (child, index, animation) {
                            return Material(
                              elevation: 0,
                              color: Colors.transparent,
                              child: child,
                            );
                          },
                          onReorder: (int oldIndex, int newIndex) {
                            pluginsController.onReorder(oldIndex, newIndex);
                          },
                          itemCount: pluginsController.pluginList.length,
                          itemBuilder: (context, index) {
                            var plugin = pluginsController.pluginList[index];
                            return Card(
                                key: ValueKey(plugin.name),
                                margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: ListTile(
                                  trailing: pluginCardTrailing(index),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  onLongPress: () {
                                    if (!isMultiSelectMode) {
                                      setState(() {
                                        isMultiSelectMode = true;
                                        selectedNames.add(plugin.name);
                                      });
                                    }
                                  },
                                  onTap: () {
                                    if (isMultiSelectMode) {
                                      setState(() {
                                        if (selectedNames.contains(plugin.name)) {
                                          selectedNames.remove(plugin.name);
                                          if (selectedNames.isEmpty) {
                                            isMultiSelectMode = false;
                                          }
                                        } else {
                                          selectedNames.add(plugin.name);
                                        }
                                      });
                                    }
                                  },
                                  selected: selectedNames.contains(plugin.name),
                                  selectedTileColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  title: Text(
                                    plugin.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Version: ${plugin.version}',
                                            style:
                                                const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ));
                          });
                    }),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    _handleAdd();
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    KazumiDialog.show(
      builder: (context) => AlertDialog(
        title: const Text('删除规则'),
        content:
            Text('确定要删除选中的 ${selectedNames.length} 条规则吗？'),
        actions: [
          TextButton(
            onPressed: () => KazumiDialog.dismiss(),
            child: Text(
              '取消',
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .outline),
            ),
          ),
          TextButton(
            onPressed: () {
              pluginsController
                  .removePlugins(selectedNames);
              setState(() {
                isMultiSelectMode = false;
                selectedNames.clear();
              });
              KazumiDialog.dismiss();
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Widget pluginCardTrailing(int index) {
    final plugin = pluginsController.pluginList[index];
    return Row(mainAxisSize: MainAxisSize.min, children: [
      isMultiSelectMode
          ? Checkbox(
              value: selectedNames.contains(plugin.name),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedNames.add(plugin.name);
                  } else {
                    selectedNames.remove(plugin.name);
                    if (selectedNames.isEmpty) {
                      isMultiSelectMode = false;
                    }
                  }
                });
              },
            )
          : popupMenuButton(index),
      ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle),
      )
    ]);
  }

  Widget popupMenuButton(int index) {
    final plugin = pluginsController.pluginList[index];
    return MenuAnchor(
      consumeOutsideTap: true,
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_vert),
        );
      },
      menuChildren: [
        MenuItemButton(
          requestFocusOnHover: false,
          onPressed: () {
            Modular.to.pushNamed('/settings/plugin/editor', arguments: plugin);
          },
          child: Container(
            height: 48,
            constraints: const BoxConstraints(minWidth: 112),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('编辑'),
                ],
              ),
            ),
          ),
        ),
        MenuItemButton(
          requestFocusOnHover: false,
          onPressed: () {
            Modular.to.pushNamed('/settings/plugin/test', arguments: plugin);
          },
          child: Container(
            height: 48,
            constraints: const BoxConstraints(minWidth: 112),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.bug_report_outlined),
                  SizedBox(width: 8),
                  Text('测试'),
                ],
              ),
            ),
          ),
        ),
        MenuItemButton(
          requestFocusOnHover: false,
          onPressed: () {
            KazumiDialog.show(builder: (context) {
              return AlertDialog(
                title: const Text('规则链接'),
                content: SelectableText(
                  Utils.jsonToKazumiBase64(json
                      .encode(pluginsController.pluginList[index].toJson())),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () => KazumiDialog.dismiss(),
                    child: Text(
                      '取消',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: Utils.jsonToKazumiBase64(
                          json.encode(
                            pluginsController.pluginList[index].toJson(),
                          ),
                        ),
                      ));
                      KazumiDialog.showToast(message: '已复制到剪贴板');
                      KazumiDialog.dismiss();
                    },
                    child: const Text('复制到剪贴板'),
                  ),
                ],
              );
            });
          },
          child: Container(
            height: 48,
            constraints: const BoxConstraints(minWidth: 112),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('分享'),
                ],
              ),
            ),
          ),
        ),
        MenuItemButton(
          requestFocusOnHover: false,
          onPressed: () async {
            setState(() {
              pluginsController.removePlugin(plugin);
            });
          },
          child: Container(
            height: 48,
            constraints: const BoxConstraints(minWidth: 112),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('删除'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
