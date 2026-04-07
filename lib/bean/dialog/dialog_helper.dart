import 'dart:async';
import 'package:flutter/material.dart';

class KazumiDialog {
  static final KazumiDialogObserver observer = KazumiDialogObserver();

  KazumiDialog._internal();

  static Future<T?> show<T>({
    BuildContext? context,
    bool? clickMaskDismiss,
    VoidCallback? onDismiss,
    required WidgetBuilder builder,
  }) async {
    final ctx = context ?? observer.currentContext;
    if (ctx != null && ctx.mounted) {
      try {
        final result = await showDialog<T>(
          context: ctx,
          barrierDismissible: clickMaskDismiss ?? true,
          builder: builder,
          routeSettings: const RouteSettings(name: 'KazumiDialog'),
        );
        onDismiss?.call();
        return result;
      } catch (e) {
        debugPrint('Kazumi Dialog Error: Failed to show dialog: $e');
        return null;
      }
    } else {
      debugPrint(
          'Kazumi Dialog Error: No context available to show the dialog');
      return null;
    }
  }

  static void showToast({
    required String message,
    BuildContext? context,
    bool showActionButton = false,
    String? actionLabel,
    Function()? onActionPressed,
    Duration duration = const Duration(seconds: 2),
  }) {
    final ctx = context ?? observer.scaffoldContext;
    if (ctx != null && ctx.mounted) {
      try {
        ScaffoldMessenger.of(ctx)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
              duration: duration,
              persist: false,
              action: showActionButton
                  ? SnackBarAction(
                      label: actionLabel ?? 'Dismiss',
                      onPressed: () {
                        onActionPressed?.call();
                        ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
                      },
                    )
                  : null,
            ),
          );
      } catch (e) {
        debugPrint('Kazumi Dialog Error: Failed to show toast: $e');
      }
    } else {
      debugPrint(
          'Kazumi Dialog Error: No Scaffold context available to show Toast');
    }
  }

  static Future<void> showLoading({
    BuildContext? context,
    String? msg,
    bool barrierDismissible = false,
    Function()? onDismiss,
  }) async {
    final ctx = context ?? observer.currentContext;
    if (ctx != null && ctx.mounted) {
      try {
        await showDialog(
          context: ctx,
          barrierDismissible: barrierDismissible,
          builder: (BuildContext context) {
            return Center(
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        msg ?? 'Loading...',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          routeSettings: const RouteSettings(name: 'KazumiDialog'),
        );
        onDismiss?.call();
      } catch (e) {
        debugPrint('Kazumi Dialog Error: Failed to show loading dialog: $e');
      }
    } else {
      debugPrint(
          'Kazumi Dialog Error: No context available to show the loading dialog');
    }
  }

  static void dismiss<T>({T? popWith}) {
    if (observer.hasKazumiDialog && observer.kazumiDialogContext != null) {
      try {
        Navigator.of(observer.kazumiDialogContext!).pop(popWith);
      } catch (e) {
        debugPrint('Kazumi Dialog Error: Failed to dismiss dialog: $e');
      }
    } else {
      debugPrint('Kazumi Dialog Debug: No active KazumiDialog to dismiss');
    }
  }
}

class KazumiDialogObserver extends NavigatorObserver {
  final List<Route<dynamic>> _kazumiDialogRoutes = [];
  BuildContext? _currentContext;
  BuildContext? _rootContext;
  BuildContext? _scaffoldContext;

  BuildContext? get currentContext => _currentContext;
  BuildContext? get rootContext => _rootContext;
  BuildContext? get scaffoldContext => _scaffoldContext;
  bool get hasKazumiDialog => _kazumiDialogRoutes.isNotEmpty;
  BuildContext? get kazumiDialogContext =>
      _kazumiDialogRoutes.isNotEmpty ? _kazumiDialogRoutes.last.navigator?.context : null;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is MaterialPageRoute || route is PopupRoute) {
      _currentContext = route.navigator?.context;
    }
    if (route.settings.name == 'KazumiDialog') {
      _kazumiDialogRoutes.add(route);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == 'KazumiDialog') {
      _kazumiDialogRoutes.remove(route);
    }
    if (_kazumiDialogRoutes.isEmpty && previousRoute != null) {
      _currentContext = previousRoute.navigator?.context;
    }
  }

  void setRootContext(BuildContext context) {
    _rootContext = context;
  }

  void setScaffoldContext(BuildContext context) {
    _scaffoldContext = context;
  }
}
