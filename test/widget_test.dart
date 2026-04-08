import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';

// 确保导入路径与你的项目名称一致
import 'package:rule_dev_tool/main.dart';
import 'package:rule_dev_tool/app_module.dart';

void main() {
  testWidgets('App initialization and home page smoke test', (WidgetTester tester) async {
    // 1. 初始化应用
    // 注意：如果你的 Request() 构造函数中有真实的底层网络调用（如 Dio），
    // 在 widget 测试中可能会报错，因为测试环境不允许真实网络连接。
    await tester.pumpWidget(
      ModularApp(
        module: AppModule(),
        child: const AppWidget(),
      ),
    );

    // 2. 等待路由跳转和渲染完成
    // 因为 Modular 的 routerConfig 是异步加载初始路由的，
    // 使用 pumpAndSettle 会等待所有动画和路由跳转结束。
    await tester.pumpAndSettle();

    // 3. 验证应用是否渲染了 MaterialApp (这是 AppWidget 的核心)
    expect(find.byType(MaterialApp), findsOneWidget);

    // 4. 验证页面内容
    // 既然你的 MaterialApp 设置了 title 为 '规则开发工具'，
    // 我们可以尝试寻找这个文本。
    // 注意：find.text 会寻找屏幕上显示的文本组件。
    expect(find.text('规则开发工具'), findsWidgets);

    // 5. (可选) 验证特定的业务组件
    // 如果你确定首页一定会显示某个文字（比如“欢迎”或某个按钮文本），请在此修改：
    // expect(find.text('登录'), findsOneWidget);
  });
}
