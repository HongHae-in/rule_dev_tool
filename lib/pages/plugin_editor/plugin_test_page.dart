import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:flutter_modular/flutter_modular.dart';
import 'package:rule_dev_tool/bean/dialog/dialog_helper.dart';
import 'package:rule_dev_tool/bean/appbar/sys_app_bar.dart';
import 'package:rule_dev_tool/plugins/plugins.dart';
import 'package:html/dom.dart' show Element;
import 'package:html/parser.dart' show parse;
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';

const _h8 = SizedBox(height: 8.0);
const _h12 = SizedBox(height: 12.0);

enum CoreColorType { error, success, waiting }

extension CoreColorExtension on ThemeData {
  Color getCoreColor(CoreColorType type) {
    switch (type) {
      case CoreColorType.error:
        return colorScheme.error;
      case CoreColorType.success:
        return colorScheme.primary;
      case CoreColorType.waiting:
        return colorScheme.onSurfaceVariant;
    }
  }
}

class PluginTestPage extends StatefulWidget {
  const PluginTestPage({super.key});

  @override
  State<PluginTestPage> createState() => _PluginTestPageState();
}

class _PluginTestPageState extends State<PluginTestPage> {
  late final Plugin plugin;
  final testKeywordController = TextEditingController();
  final htmlScrollController = ScrollController();
  final chapterScrollController = ScrollController();
  final itemHtmlScrollController = ScrollController();

  String searchHtml = "";
  PluginSearchResponse? searchRes;
  List<Road>? chapters;
  bool isTesting = false;
  String errorMsg = "";
  final Map<int, String> _itemHtmlMap = {};
  int? _showItemHtmlIdx;

  bool get _hasSearchHtml => searchHtml.isNotEmpty;
  bool get _hasSearchData => searchRes?.data.isNotEmpty ?? false;
  bool get _hasChapters => chapters?.isNotEmpty ?? false;
  bool get _needChapterParse => plugin.chapterRoads.isNotEmpty;

  CancelToken? _testSearchRequestCancelToken;
  CancelToken? _testRoadsCancelToken;

  @override
  void initState() {
    super.initState();
    plugin = Modular.args.data as Plugin;
    testKeywordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _testSearchRequestCancelToken?.cancel();
    _testRoadsCancelToken?.cancel();
    testKeywordController.dispose();
    htmlScrollController.dispose();
    chapterScrollController.dispose();
    itemHtmlScrollController.dispose();
    super.dispose();
  }

  void onBackPressed() =>
      KazumiDialog.observer.hasKazumiDialog ? KazumiDialog.dismiss() : null;

  void resetState() => setState(() {
        _testSearchRequestCancelToken?.cancel();
        _testSearchRequestCancelToken = null;
        _testRoadsCancelToken?.cancel();
        _testRoadsCancelToken = null;
        searchHtml = "";
        searchRes = null;
        chapters = null;
        errorMsg = "";
        _itemHtmlMap.clear();
        _showItemHtmlIdx = null;
      });

  String _parseItemHtml(int index) {
    if (_itemHtmlMap.containsKey(index)) return _itemHtmlMap[index]!;
    try {
      final node = (parse(searchHtml)
          .documentElement!
          .queryXPath(plugin.searchList)
          .nodes[index]
          .node as Element);
      return _itemHtmlMap[index] = node.outerHtml;
    } catch (e) {
      return "解析失败：$e";
    }
  }

  void _toggleItemHtml(int index) {
    if (_showItemHtmlIdx == index) {
      return setState(() => _showItemHtmlIdx = null);
    }
    setState(() => isTesting = true);
    _parseItemHtml(index);
    setState(() {
      _showItemHtmlIdx = index;
      isTesting = false;
    });
  }

  Future<void> startTest() async {
    final keyword = testKeywordController.text.trim();
    resetState();
    setState(() => isTesting = true);
    try {
      _testSearchRequestCancelToken?.cancel();
      _testSearchRequestCancelToken = CancelToken();
      searchHtml = await plugin.testSearchRequest(keyword,
          shouldRethrow: true, cancelToken: _testSearchRequestCancelToken);
      searchRes = plugin.testQueryBangumi(searchHtml);
      if (_hasSearchData && _needChapterParse) {
        final firstItem = searchRes!.data.first;
        if (firstItem.src.isNotEmpty) {
          _testRoadsCancelToken?.cancel();
          _testRoadsCancelToken = CancelToken();
          chapters = await plugin.querychapterRoads(firstItem.src,
              cancelToken: _testRoadsCancelToken);
        }
      }
    } catch (e) {
      errorMsg = _formatError(e);
    } finally {
      if (mounted) setState(() => isTesting = false);
    }
  }

  String _formatError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return '连接超时：服务器响应时间过长，请检查网络连接或稍后重试';
        case DioExceptionType.sendTimeout:
          return '发送超时：请求数据发送超时，请检查网络连接';
        case DioExceptionType.receiveTimeout:
          return '接收超时：服务器响应超时，请稍后重试';
        case DioExceptionType.badResponse:
          return '服务器错误：HTTP ${error.response?.statusCode} - ${error.response?.statusMessage ?? '未知错误'}';
        case DioExceptionType.cancel:
          return '请求已取消';
        case DioExceptionType.connectionError:
          return '连接错误：无法连接到服务器，请检查URL是否正确或网络连接';
        case DioExceptionType.badCertificate:
          return '证书错误：SSL证书验证失败';
        case DioExceptionType.unknown:
          return '未知错误：${error.message}';
      }
    }
    if (error is CaptchaRequiredException) {
      return '验证码要求：该网站需要验证码验证，无法自动完成测试';
    }
    if (error is NoResultException) {
      return '无搜索结果：未找到匹配的搜索结果，请检查XPath配置是否正确';
    }
    if (error is SearchErrorException) {
      return '搜索错误：${error.toString()}';
    }
    // 对于其他错误，显示简化的错误信息
    final errorStr = error.toString();
    if (errorStr.length > 200) {
      return '错误：${errorStr.substring(0, 200)}...';
    }
    return '错误：$errorStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) => !didPop ? onBackPressed() : null,
      child: Scaffold(
        appBar: SysAppBar(
          title: Text('${plugin.name} 测试'),
          actions: [
            IconButton(
              onPressed: (isTesting || testKeywordController.text.trim().isEmpty) ? null : startTest,
              icon: const Icon(Icons.bug_report_outlined),
              tooltip: '开始测试',
            ),
            IconButton(
              onPressed: (isTesting || testKeywordController.text.trim().isEmpty) ? null : resetState,
              icon: const Icon(Icons.refresh),
              tooltip: '重置',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKeywordInput(theme),
                    _h12,
                    _buildErrorWidget(theme),
                    _buildExpansionTile(
                      theme: theme,
                      title: '1. 搜索请求测试',
                      subtitle: _getSearchSubtitle(),
                      expanded: false,
                      child: _buildSearchContent(theme),
                    ),
                    _h12,
                    _buildExpansionTile(
                      theme: theme,
                      title: '2. 搜索解析测试',
                      subtitle: _getParseSubtitle(),
                      expanded: false,
                      child: _buildParseContent(theme),
                    ),
                    _h12,
                    _buildExpansionTile(
                      theme: theme,
                      title: '3. 章节列表测试',
                      subtitle: _getChapterSubtitle(),
                      expanded: _hasSearchData,
                      child: _buildChapterContent(theme),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionTile({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required bool expanded,
    required Widget child,
  }) {
    return ExpansionTile(
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: 12.0, color: _getSubtitleColor(subtitle, theme))),
      initiallyExpanded: expanded,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      iconColor: theme.getCoreColor(CoreColorType.success),
      collapsedIconColor: theme.getCoreColor(CoreColorType.waiting),
      children: [_h8, child, _h8],
    );
  }

  Widget _buildKeywordInput(ThemeData theme) => TextField(
        controller: testKeywordController,
        decoration: InputDecoration(
          labelText: '测试关键词',
          border: OutlineInputBorder(
              borderSide:
                  BorderSide(color: theme.getCoreColor(CoreColorType.waiting))),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: theme.getCoreColor(CoreColorType.success))),
          labelStyle:
              TextStyle(color: theme.getCoreColor(CoreColorType.waiting)),
        ),
        enabled: !isTesting,
        onSubmitted: (_) => startTest(),
        style: theme.textTheme.bodyLarge,
      );

  Widget _buildErrorWidget(ThemeData theme) => errorMsg.isEmpty || isTesting
      ? const SizedBox.shrink()
      : Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            border: Border.all(color: theme.getCoreColor(CoreColorType.error)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.getCoreColor(CoreColorType.error).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: theme.getCoreColor(CoreColorType.error),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '测试失败',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMsg,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                      onPressed: startTest,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('重试测试'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onErrorContainer,
                        backgroundColor: 
                              theme.getCoreColor(CoreColorType.error)
                                .withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
              ],
            ),
          ]),
        );

  Widget _buildLoading(ThemeData theme) => Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(
              theme.getCoreColor(CoreColorType.success)),
        ),
      );

  Widget _buildEmpty(String text, ThemeData theme, {bool isError = false}) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isError
                  ? theme.getCoreColor(CoreColorType.error)
                  : theme.getCoreColor(CoreColorType.waiting),
            ),
          ),
        ),
      );

  String _getSearchSubtitle() {
    if (isTesting) return '测试中...';
    if (!_hasSearchHtml) return '未执行测试';
    return 'HTML长度：${searchHtml.length} 字符';
  }

  Color _getSubtitleColor(String subtitle, ThemeData theme) {
    if (subtitle.contains('测试中') ||
        subtitle.contains('获取中') ||
        subtitle.contains('解析中')) {
      return theme.getCoreColor(CoreColorType.waiting);
    }
    if (subtitle.contains('失败') ||
        subtitle.contains('无可用') ||
        subtitle.contains('无有效')) {
      return theme.getCoreColor(CoreColorType.error);
    }
    return theme.getCoreColor(CoreColorType.success);
  }

  Widget _buildSearchContent(ThemeData theme) {
    if (isTesting) return _buildLoading(theme);
    if (!_hasSearchHtml) return _buildEmpty('点击顶部「开始测试」按钮执行', theme);
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.getCoreColor(CoreColorType.waiting)),
        color: theme.colorScheme.surface,
      ),
      height: 250,
      child: SingleChildScrollView(
        controller: htmlScrollController,
        physics: const ClampingScrollPhysics(),
        child: SelectableText(
          searchHtml,
          style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
        ),
      ),
    );
  }

  String _getParseSubtitle() {
    if (isTesting && _showItemHtmlIdx == null) return '解析中...';
    if (!_hasSearchHtml) return '未执行解析';
    if (!_hasSearchData) return '未解析到结果';
    return '解析到 ${searchRes?.data.length ?? 0} 条结果';
  }

  Widget _buildParseContent(ThemeData theme) {
    if (isTesting && _showItemHtmlIdx == null) return _buildLoading(theme);
    if (!_hasSearchHtml) return _buildEmpty('请先完成搜索请求测试', theme);
    if (!_hasSearchData) return _buildEmpty('未解析到搜索结果', theme, isError: true);

    return Column(children: [
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: searchRes!.data.length,
        itemBuilder: (_, i) =>
            _buildSearchItemCard(searchRes!.data[i], i, theme),
      ),
      _h8,
    ]);
  }

  Widget _buildSearchItemCard(SearchItem item, int i, ThemeData theme) {
    final isShowHtml = _showItemHtmlIdx == i;
    final itemHtml = _itemHtmlMap[i] ?? '加载中...';

    return Column(children: [
      Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Text(
                  '${i + 1}：${item.name}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: isTesting ? null : () => _toggleItemHtml(i),
                icon: Icon(
                  isShowHtml ? Icons.keyboard_arrow_up : Icons.code,
                  size: 18,
                  color: theme.getCoreColor(CoreColorType.success),
                ),
                tooltip: isShowHtml ? '隐藏HTML' : '查看HTML',
              ),
            ]),
            _h8,
            Text('链接：${item.src}',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.getCoreColor(CoreColorType.waiting))),
          ]),
        ),
      ),
      if (isShowHtml)
        Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: theme.getCoreColor(CoreColorType.waiting)),
            color: theme.colorScheme.surface,
          ),
          height: 250,
          child: SingleChildScrollView(
            controller: itemHtmlScrollController,
            physics: const ClampingScrollPhysics(),
            child: SelectableText(
              itemHtml,
              style:
                  theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ),
    ]);
  }

  String _getChapterSubtitle() {
    if (isTesting) return '获取中...';
    if (!_hasSearchHtml) return '未执行测试';
    if (!_hasSearchData) return '无有效搜索结果';
    if (!_needChapterParse) return '无需解析章节';
    if (chapters == null) return '未获取章节数据';
    return '获取到 ${chapters?.length ?? 0} 个播放列表';
  }

  Widget _buildChapterContent(ThemeData theme) {
    if (!_needChapterParse) return _buildEmpty('未填写章节规则', theme);
    if (isTesting) return _buildLoading(theme);
    if (!_hasSearchData) return _buildEmpty('请先解析到有效结果', theme);
    if (chapters == null) return _buildEmpty('未获取章节数据', theme, isError: true);
    if (!_hasChapters) return _buildEmpty('无可用章节', theme, isError: true);

    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 280,
      child: ListView.builder(
        controller: chapterScrollController,
        itemCount: chapters?.length ?? 0,
        itemBuilder: (_, i) => _buildChapterCard(chapters![i], i, theme),
      ),
    );
  }

  Widget _buildChapterCard(Road road, int i, ThemeData theme) => Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '播放列表 ${i + 1}：${road.name}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                _h8,
                Text('章节数量：${road.data.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.getCoreColor(CoreColorType.waiting))),
                _h8,
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...road.identifier.asMap().entries.map((e) => Text(
                                '${e.key + 1}. ${e.value}',
                                style: theme.textTheme.bodySmall,
                              )),
                        ]),
                  ),
                ),
              ]),
        ),
      );
}
