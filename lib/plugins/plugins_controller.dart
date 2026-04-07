import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'plugins.dart';
import 'package:rule_dev_tool/request/plugin.dart';
import 'package:rule_dev_tool/modules/plugin/plugin_http_module.dart';

class PluginsController extends ChangeNotifier {
  List<Plugin> _pluginList = [];
  List<PluginHTTPItem> pluginHTTPList = [];
  static const String _storageKey = 'plugin_list';

  List<Plugin> get pluginList => _pluginList;

  PluginsController() {
    _loadPlugins();
  }

  Future<void> _loadPlugins() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pluginsJson = prefs.getString(_storageKey);
    if (pluginsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(pluginsJson);
        _pluginList = decoded.map((e) => Plugin.fromJson(e)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Failed to load plugins: $e');
      }
    }
  }

  Future<void> _savePlugins() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_pluginList.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void addPlugin(Plugin plugin) {
    _pluginList.add(plugin);
    _savePlugins();
    notifyListeners();
  }

  Future<void> updatePlugin(Plugin plugin) async {
    final index = _pluginList.indexWhere((p) => p.name == plugin.name);
    if (index != -1) {
      _pluginList[index] = plugin;
    } else {
      _pluginList.add(plugin);
    }
    await _savePlugins();
    notifyListeners();
  }

  void removePlugin(Plugin plugin) {
    _pluginList.removeWhere((p) => p.name == plugin.name);
    _savePlugins();
    notifyListeners();
  }

  void removePlugins(Set<String> names) {
    _pluginList.removeWhere((p) => names.contains(p.name));
    _savePlugins();
    notifyListeners();
  }

  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Plugin item = _pluginList.removeAt(oldIndex);
    _pluginList.insert(newIndex, item);
    _savePlugins();
    notifyListeners();
  }

  String pluginStatus(PluginHTTPItem pluginHTTPItem) {
    String pluginStatus = 'install';
    for (Plugin plugin in _pluginList) {
      if (pluginHTTPItem.name == plugin.name) {
        if (pluginHTTPItem.version == plugin.version) {
          pluginStatus = 'installed';
        } else {
          pluginStatus = 'update';
        }
        break;
      }
    }
    return pluginStatus;
  }

  String pluginUpdateStatus(Plugin plugin) {
    if (!pluginHTTPList.any((p) => p.name == plugin.name)) {
      return "nonexistent";
    }
    PluginHTTPItem p = pluginHTTPList.firstWhere(
      (p) => p.name == plugin.name,
    );
    return p.version == plugin.version ? "latest" : "updatable";
  }

  Future<int> tryUpdatePlugin(Plugin plugin) async {
    return await tryUpdatePluginByName(plugin.name);
  }

  Future<int> tryUpdatePluginByName(String name) async {
    var pluginHTTPItem = await queryPluginHTTP(name);
    if (pluginHTTPItem != null) {
      updatePlugin(pluginHTTPItem);
      return 0;
    }
    return 2;
  }

  Future<int> tryUpdateAllPlugin() async {
    int count = 0;
    for (Plugin plugin in _pluginList) {
      if (pluginUpdateStatus(plugin) == 'updatable') {
        if (await tryUpdatePlugin(plugin) == 0) {
          count++;
        }
      }
    }
    return count;
  }

  Future<void> queryPluginHTTPList() async {
    pluginHTTPList.clear();
    var pluginHTTPListRes = await PluginHTTP.getPluginList();
    pluginHTTPList.addAll(pluginHTTPListRes);
  }

  Future<Plugin?> queryPluginHTTP(String name) async {
    Plugin? plugin;
    plugin = await PluginHTTP.getPlugin(name);
    return plugin;
  }
}
