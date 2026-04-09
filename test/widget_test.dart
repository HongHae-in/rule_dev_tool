// 导入部分（必须在文件最顶部）
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'package:rule_dev_tool/main.dart';
import 'package:rule_dev_tool/app_module.dart';

// 主函数和测试代码
void main() {
  testWidgets('App starts and displays empty state', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ModularApp(
        module: AppModule(),
        child: const AppWidget(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.text('规则管理'), findsOneWidget);

    // Verify that the empty state message is displayed when no rules exist
    expect(find.text('啊咧（⊙.⊙） 没有可用规则的说'), findsOneWidget);

    // Verify that the add button is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Add button exists and is enabled', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ModularApp(
        module: AppModule(),
        child: const AppWidget(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the add button exists and is enabled
    final addButton = find.byType(FloatingActionButton);
    expect(addButton, findsOneWidget);

    // Get the FloatingActionButton widget
    final fab = tester.widget<FloatingActionButton>(addButton);
    expect(fab.onPressed, isNotNull);
  });
}
