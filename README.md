# 规则开发工具

这是一个独立的规则开发工具应用，用于创建、编辑和测试插件规则。

## 功能特性

- 规则编辑：创建和编辑插件规则
- 规则测试：测试规则的搜索和解析功能
- 规则管理：导入、导出、分享规则
- 跨平台支持：支持 Android、iOS、Windows、macOS、Linux

## 安装说明

### 前置要求

- Flutter SDK 3.0.0 或更高版本
- Dart SDK 3.0.0 或更高版本

### 安装步骤

1. 克隆或下载本项目

2. 进入项目目录
```bash
cd rule_dev_tool
```

3. 获取依赖
```bash
flutter pub get
```

4. 运行应用
```bash
flutter run
```

## 使用说明

### 创建新规则

1. 点击右上角的"+"按钮
2. 选择"新建规则"
3. 填写规则配置信息
4. 点击测试按钮测试规则
5. 点击保存按钮保存规则

### 编辑规则

1. 长按规则卡片进入多选模式
2. 点击规则卡片右侧的菜单按钮
3. 选择"编辑"

### 测试规则

1. 打开规则编辑页面
2. 点击右上角的测试按钮（虫子图标）
3. 输入测试关键词
4. 点击"开始测试"按钮
5. 查看测试结果

### 导入规则

1. 点击右上角的"+"按钮
2. 选择"从剪贴板导入"
3. 粘贴规则链接
4. 点击"导入"按钮

### 导出规则

1. 长按规则卡片进入多选模式
2. 点击规则卡片右侧的菜单按钮
3. 选择"分享"
4. 复制规则链接到剪贴板

## 规则配置说明

### 基本配置

- **Name**: 规则名称
- **Version**: 规则版本
- **BaseURL**: 网站基础URL
- **SearchURL**: 搜索URL（使用@keyword作为关键词占位符）
- **SearchList**: 搜索结果列表的XPath
- **SearchName**: 搜索结果名称的XPath
- **SearchResult**: 搜索结果链接的XPath
- **ChapterRoads**: 章节列表的XPath
- **ChapterResult**: 章节链接的XPath

### 高级配置

- **简易解析**: 使用简易解析器而不是现代解析器
- **POST**: 使用POST而不是GET进行检索
- **内置播放器**: 使用内置播放器播放视频
- **广告过滤**: 启用HLS广告过滤
- **UserAgent**: 自定义User-Agent
- **Referer**: 自定义Referer
- **反反爬虫配置**: 配置验证码处理方式

## 开发说明

### 项目结构

```
lib/
├── main.dart                 # 应用入口
├── app_module.dart          # 应用模块配置
├── plugins/                 # 插件相关
│   ├── plugins.dart         # Plugin类定义
│   ├── plugins_controller.dart # 插件控制器
│   └── anti_crawler_config.dart # 反爬虫配置
├── pages/                   # 页面
│   └── plugin_editor/       # 插件编辑器页面
│       ├── plugin_view_page.dart    # 规则管理页面
│       ├── plugin_editor_page.dart  # 规则编辑页面
│       └── plugin_test_page.dart   # 规则测试页面
├── bean/                    # 组件
│   ├── appbar/             # 应用栏组件
│   └── dialog/             # 对话框组件
└── utils/                   # 工具类
    └── utils.dart          # 通用工具函数
```

### 技术栈

- Flutter: 跨平台UI框架
- flutter_modular: 模块化路由和依赖注入
- mobx: 状态管理
- dio: HTTP请求
- html: HTML解析
- xpath_selector_html_parser: XPath选择器

## 许可证

本项目基于原Kazumi项目的规则编辑功能开发。

## 致谢

感谢Kazumi项目提供的规则编辑功能。
