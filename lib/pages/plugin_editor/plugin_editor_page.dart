import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:card_settings_ui/tile/settings_tile_info.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:rule_dev_tool/plugins/plugins.dart';
import 'package:rule_dev_tool/plugins/anti_crawler_config.dart';
import 'package:rule_dev_tool/plugins/plugins_controller.dart';
import 'package:rule_dev_tool/bean/appbar/sys_app_bar.dart';

class PluginEditorPage extends StatefulWidget {
  const PluginEditorPage({
    super.key,
  });

  @override
  State<PluginEditorPage> createState() => _PluginEditorPageState();
}

class _PluginEditorPageState extends State<PluginEditorPage> {
  final PluginsController pluginsController = Modular.get<PluginsController>();
  final TextEditingController apiController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController versionController = TextEditingController();
  final TextEditingController userAgentController = TextEditingController();
  final TextEditingController baseURLController = TextEditingController();
  final TextEditingController searchURLController = TextEditingController();
  final TextEditingController searchListController = TextEditingController();
  final TextEditingController searchNameController = TextEditingController();
  final TextEditingController searchResultController = TextEditingController();
  final TextEditingController chapterRoadsController = TextEditingController();
  final TextEditingController chapterResultController = TextEditingController();
  final TextEditingController refererController = TextEditingController();
  bool muliSources = true;
  bool useWebview = true;
  bool useNativePlayer = true;
  bool usePost = false;
  bool useLegacyParser = false;
  bool adBlocker = false;

  // AntiCrawler fields
  final TextEditingController captchaImageController = TextEditingController();
  final TextEditingController captchaInputController = TextEditingController();
  final TextEditingController captchaButtonController = TextEditingController();
  bool antiCrawlerEnabled = false;
  int captchaType = CaptchaType.imageCaptcha;
  final MenuController captchaTypeMenuController = MenuController();

  static const Map<int, String> _captchaTypeMap = {
    CaptchaType.imageCaptcha: '图片验证码',
    CaptchaType.autoClickButton: '自动点击按钮',
  };

  @override
  void initState() {
    super.initState();
    final Plugin plugin = Modular.args.data as Plugin;
    apiController.text = plugin.api;
    typeController.text = plugin.type;
    nameController.text = plugin.name;
    versionController.text = plugin.version;
    userAgentController.text = plugin.userAgent;
    baseURLController.text = plugin.baseUrl;
    searchURLController.text = plugin.searchURL;
    searchListController.text = plugin.searchList;
    searchNameController.text = plugin.searchName;
    searchResultController.text = plugin.searchResult;
    chapterRoadsController.text = plugin.chapterRoads;
    chapterResultController.text = plugin.chapterResult;
    refererController.text = plugin.referer;
    muliSources = plugin.muliSources;
    useWebview = plugin.useWebview;
    useNativePlayer = plugin.useNativePlayer;
    usePost = plugin.usePost;
    useLegacyParser = plugin.useLegacyParser;
    adBlocker = plugin.adBlocker;
    antiCrawlerEnabled = plugin.antiCrawlerConfig.enabled;
    captchaType = plugin.antiCrawlerConfig.captchaType;
    captchaImageController.text = plugin.antiCrawlerConfig.captchaImage;
    captchaInputController.text = plugin.antiCrawlerConfig.captchaInput;
    captchaButtonController.text = plugin.antiCrawlerConfig.captchaButton;
  }

  @override
  Widget build(BuildContext context) {
    final Plugin plugin = Modular.args.data as Plugin;
    final fontFamily = Theme.of(context).textTheme.bodyMedium?.fontFamily;

    return Scaffold(
      appBar: const SysAppBar(
        title: Text('规则编辑器'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: (MediaQuery.of(context).size.width > 1000) ? 1000 : null,
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    helperText: '规则名称，用于标识和显示规则',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: versionController,
                  decoration: const InputDecoration(
                    labelText: 'Version',
                    border: OutlineInputBorder(),
                    helperText: '规则版本号，用于版本管理和更新',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: baseURLController,
                  decoration: const InputDecoration(
                    labelText: 'BaseURL',
                    border: OutlineInputBorder(),
                    helperText: '网站基础URL，所有相对路径将基于此URL',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: searchURLController,
                  decoration: const InputDecoration(
                    labelText: 'SearchURL',
                    border: OutlineInputBorder(),
                    helperMaxLines: 3,
                    helperText: '当你在kazumi内键入关键词时，其需要调用的搜索链接。我们只需要将搜索结果网址中的搜索关键字或编码人为替换为@keyword即可',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: searchListController,
                  decoration: const InputDecoration(
                    labelText: 'SearchList',
                    border: OutlineInputBorder(),
                    helperMaxLines: 4,
                    helperText: '在键入某个关键词并进行搜索以后，所得到的搜索结果。我们需要查看搜索结果网页的HTML代码，找到搜索结果的字段的结构，复制父级结构的完整Xpath，然后需要将/html/body替换成/，最后加上//和子级搜索结果开头字段',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: searchNameController,
                  decoration: const InputDecoration(
                    labelText: 'SearchName',
                    border: OutlineInputBorder(),
                    helperMaxLines: 4,
                    helperText: '指引软件在搜索结果中找到对应结果的标题。我们需要复制标题的完整Xpath，然后需要将/html/body替换成/，然后去掉与SearchList重复的字段，保留//和结尾字段',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: searchResultController,
                  decoration: const InputDecoration(
                    labelText: 'SearchResult',
                    border: OutlineInputBorder(),
                    helperMaxLines: 3,
                    helperText: '提取影视详细界面的URL。我们只需复制影视详细按钮的完整Xpath，与之前的Name处理相同',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: chapterRoadsController,
                  decoration: const InputDecoration(
                    labelText: 'ChapterRoads',
                    border: OutlineInputBorder(),
                    helperMaxLines: 4,
                    helperText: '用于定位播放列表容器。我们需要找到所有播放路线容器的父级容器，然后复制完整Xpath，将/html/body替换成/，结尾加上//开头字段',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: chapterResultController,
                  decoration: const InputDecoration(
                    labelText: 'ChapterResult',
                    border: OutlineInputBorder(),
                    helperMaxLines: 4,
                    helperText: '用于提取每集的播放URL。这里我们可以随意点击任意集数，并且复制完整Xpath，然后需要将/html/body替换成/，然后去掉与SearchList重复的字段，保留//和结尾字段',
                  ),
                ),
                const SizedBox(height: 20),
                ExpansionTile(
                  title: const Text('高级选项'),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  children: [
                    SettingsSection(
                      title: Text('行为设置', style: TextStyle(fontFamily: fontFamily)),
                      tiles: [
                        _buildSwitchTile(
                          title: '简易解析',
                          description: '使用简易解析器而不是现代解析器',
                          value: useLegacyParser,
                          fontFamily: fontFamily,
                          onChanged: (v) => setState(() => useLegacyParser = v ?? !useLegacyParser),
                        ),
                        _buildSwitchTile(
                          title: 'POST',
                          description: '使用 POST 而不是 GET 进行检索',
                          value: usePost,
                          fontFamily: fontFamily,
                          onChanged: (v) => setState(() => usePost = v ?? !usePost),
                        ),
                        _buildSwitchTile(
                          title: '内置播放器',
                          description: '使用内置播放器播放视频',
                          value: useNativePlayer,
                          fontFamily: fontFamily,
                          onChanged: (v) => setState(() => useNativePlayer = v ?? !useNativePlayer),
                        ),
                        _buildSwitchTile(
                          title: '广告过滤',
                          description: '启用 HLS 广告过滤',
                          value: adBlocker,
                          fontFamily: fontFamily,
                          onChanged: (v) => setState(() => adBlocker = v ?? !adBlocker),
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: Text('网络设置', style: TextStyle(fontFamily: fontFamily)),
                      tiles: [
                        CustomSettingsTile(
                          child: (info) => _buildTextFieldTile(
                            context, info,
                            controller: userAgentController,
                            label: 'UserAgent',
                            helper: '自定义用户代理字符串，用于模拟特定浏览器访问',
                          ),
                        ),
                        CustomSettingsTile(
                          child: (info) => _buildTextFieldTile(
                            context, info,
                            controller: refererController,
                            label: 'Referer',
                            helper: 'HTTP请求的来源地址，用于绕过某些反爬虫检测',
                          ),
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: Text('反反爬虫配置', style: TextStyle(fontFamily: fontFamily)),
                      tiles: [
                        _buildSwitchTile(
                          title: '启用反反爬虫',
                          description: '检索失败时显示验证码验证按钮而非重试',
                          value: antiCrawlerEnabled,
                          fontFamily: fontFamily,
                          onChanged: (v) => setState(() => antiCrawlerEnabled = v ?? !antiCrawlerEnabled),
                        ),
                        if (antiCrawlerEnabled) ...[
                          SettingsTile.navigation(
                            onPressed: (_) {
                              if (captchaTypeMenuController.isOpen) {
                                captchaTypeMenuController.close();
                              } else {
                                captchaTypeMenuController.open();
                              }
                            },
                            title: Text('验证类型', style: TextStyle(fontFamily: fontFamily)),
                            description: Text(
                              captchaType == CaptchaType.imageCaptcha
                                  ? '图片验证码（展示验证码图片，用户手动输入）'
                                  : '自动点击验证按钮（检测到按钮后自动模拟点击）',
                              style: TextStyle(fontFamily: fontFamily),
                            ),
                            value: MenuAnchor(
                              consumeOutsideTap: true,
                              controller: captchaTypeMenuController,
                              builder: (_, __, ___) => Text(
                                _captchaTypeMap[captchaType] ?? '未知',
                                style: TextStyle(fontFamily: fontFamily),
                              ),
                              menuChildren: [
                                for (final entry in _captchaTypeMap.entries)
                                  MenuItemButton(
                                    requestFocusOnHover: false,
                                    onPressed: () => setState(() => captchaType = entry.key),
                                    child: Container(
                                      height: 48,
                                      constraints: const BoxConstraints(minWidth: 160),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          entry.value,
                                          style: TextStyle(
                                            color: entry.key == captchaType
                                                ? Theme.of(context).colorScheme.primary
                                                : null,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (captchaType == CaptchaType.imageCaptcha) ...[
                            CustomSettingsTile(
                              child: (info) => _buildTextFieldTile(
                                context, info,
                                controller: captchaImageController,
                                label: 'CaptchaImage (XPath)',
                                hint: '//img[@class="captcha"]',
                                helper: '验证码图片元素的 XPath',
                              ),
                            ),
                            CustomSettingsTile(
                              child: (info) => _buildTextFieldTile(
                                context, info,
                                controller: captchaInputController,
                                label: 'CaptchaInput (XPath)',
                                hint: '//input[@name="captcha"]',
                                helper: '验证码输入框元素的 XPath',
                              ),
                            ),
                          ],
                          CustomSettingsTile(
                            child: (info) => _buildTextFieldTile(
                              context, info,
                              controller: captchaButtonController,
                              label: captchaType == CaptchaType.imageCaptcha
                                  ? 'CaptchaButton (XPath)'
                                  : 'VerifyButton (XPath)',
                              hint: '//button[@type="submit"]',
                              helper: captchaType == CaptchaType.imageCaptcha
                                  ? '验证提交按钮元素的 XPath'
                                  : '验证按钮元素的 XPath，检测到后自动点击',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.bug_report),
            onPressed: () async {
              Plugin pluginText = Plugin(
                  api: apiController.text,
                  type: typeController.text,
                  name: nameController.text,
                  version: versionController.text,
                  muliSources: muliSources,
                  useWebview: useWebview,
                  useNativePlayer: useNativePlayer,
                  usePost: usePost,
                  useLegacyParser: useLegacyParser,
                  adBlocker: adBlocker,
                  userAgent: userAgentController.text,
                  baseUrl: baseURLController.text,
                  searchURL: searchURLController.text,
                  searchList: searchListController.text,
                  searchName: searchNameController.text,
                  searchResult: searchResultController.text,
                  chapterRoads: chapterRoadsController.text,
                  chapterResult: chapterResultController.text,
                  referer: refererController.text,
                  antiCrawlerConfig: AntiCrawlerConfig(
                    enabled: antiCrawlerEnabled,
                    captchaType: captchaType,
                    captchaImage: captchaImageController.text,
                    captchaInput: captchaInputController.text,
                    captchaButton: captchaButtonController.text,
                  ));
              Modular.to.pushNamed('/settings/plugin/test', arguments: pluginText);
            },
          ),
          const SizedBox(width: 15),
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.save),
            onPressed: () async {
              plugin.api = apiController.text;
              plugin.type = typeController.text;
              plugin.name = nameController.text;
              plugin.version = versionController.text;
              plugin.userAgent = userAgentController.text;
              plugin.baseUrl = baseURLController.text;
              plugin.searchURL = searchURLController.text;
              plugin.searchList = searchListController.text;
              plugin.searchName = searchNameController.text;
              plugin.searchResult = searchResultController.text;
              plugin.chapterRoads = chapterRoadsController.text;
              plugin.chapterResult = chapterResultController.text;
              plugin.muliSources = muliSources;
              plugin.useWebview = useWebview;
              plugin.useNativePlayer = useNativePlayer;
              plugin.usePost = usePost;
              plugin.useLegacyParser = useLegacyParser;
              plugin.adBlocker = adBlocker;
              plugin.referer = refererController.text;
              plugin.antiCrawlerConfig = AntiCrawlerConfig(
                enabled: antiCrawlerEnabled,
                captchaType: captchaType,
                captchaImage: captchaImageController.text,
                captchaInput: captchaInputController.text,
                captchaButton: captchaButtonController.text,
              );
              await pluginsController.updatePlugin(plugin);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldTile(
    BuildContext context,
    SettingsTileInfo info, {
    required TextEditingController controller,
    required String label,
    String? hint,
    String? helper,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(info.isTopTile ? 20 : 3),
            bottom: Radius.circular(info.isBottomTile ? 20 : 3),
          ),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                helperText: helper,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(info.isTopTile ? 20 : 3),
                    bottom: Radius.circular(info.isBottomTile ? 20 : 3),
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  AbstractSettingsTile _buildSwitchTile({
    required String title,
    required String description,
    required bool value,
    required String? fontFamily,
    required void Function(bool?) onChanged,
  }) {
    if (kIsWeb) {
      // 在Web平台上使用自定义的SwitchTile，避免使用SettingsTile.switchTile
      return CustomSettingsTile(
        child: (info) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      );
    } else {
      // 在非Web平台上使用SettingsTile.switchTile
      return SettingsTile.switchTile(
        title: Text(title, style: TextStyle(fontFamily: fontFamily)),
        description: Text(description, style: TextStyle(fontFamily: fontFamily)),
        initialValue: value,
        onToggle: onChanged,
      );
    }
  }
}
