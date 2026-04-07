import 'package:flutter_modular/flutter_modular.dart';
import 'pages/plugin_editor/plugin_view_page.dart';
import 'pages/plugin_editor/plugin_editor_page.dart';
import 'pages/plugin_editor/plugin_test_page.dart';
import 'pages/plugin_editor/plugin_shop_page.dart';
import 'plugins/plugins_controller.dart';

class AppModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<PluginsController>(() => PluginsController());
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const PluginViewPage());
    r.child('/settings/plugin/editor',
        child: (context) => const PluginEditorPage());
    r.child('/settings/plugin/test',
        child: (context) => const PluginTestPage());
    r.child('/settings/plugin/shop',
        child: (context) => const PluginShopPage());
  }
}
