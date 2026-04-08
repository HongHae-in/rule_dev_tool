
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:rule_dev_tool/plugins/plugins.dart';
import 'package:rule_dev_tool/modules/plugin/plugin_http_module.dart';
import 'package:rule_dev_tool/request/request.dart';

class PluginHTTP {
  static const String pluginShop = 'https://raw.githubusercontent.com/Predidit/KazumiRules/main/';

  static Future<List<PluginHTTPItem>> getPluginList() async {
    List<PluginHTTPItem> pluginHTTPItemList = [];
    try {
      var response = await Request().get('${pluginShop}index.json');
      final jsonData = json.decode(response.data);
      for (dynamic pluginJsonItem in jsonData) {
        try {
          PluginHTTPItem pluginHTTPItem = PluginHTTPItem.fromJson(pluginJsonItem);
          pluginHTTPItemList.add(pluginHTTPItem);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Plugin: getPluginList error: $e');
    }
    return pluginHTTPItemList;
  }

  static Future<Plugin?> getPlugin(String name) async {
    Plugin? plugin;
    try {
      var response = await Request().get('$pluginShop$name.json');
      final jsonData = json.decode(response.data);
      plugin = Plugin.fromJson(jsonData);
    } catch (e) {
      debugPrint('Plugin: getPlugin error: $e');
    }
    return plugin;
  }
}
