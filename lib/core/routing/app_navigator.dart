import 'package:flutter/cupertino.dart';
import 'package:streak/app/app_background.dart';
import 'package:streak/core/widgets/page_motion.dart';

abstract interface class FullWidthPage {}

class AppNavigator {
  const AppNavigator._();

  static final key = GlobalKey<NavigatorState>();

  static final paneKey = GlobalKey<NavigatorState>();

  static final paneItem = ValueNotifier<String?>(null);

  static NavigatorState? get _pane {
    final root = key.currentState;
    if (root == null || root.canPop()) return null;
    return paneKey.currentState;
  }

  static Future<T?> push<T>(
    Widget page, {
    bool fullscreenDialog = false,
    bool fade = false,
    String? name,
  }) {
    final pane = page is FullWidthPage ? null : _pane;
    final target = pane ?? key.currentState!;
    return target.push<T>(
      route(page, fullscreenDialog: fullscreenDialog, fade: fade, name: name),
    );
  }

  static void pop<T>([T? result]) {
    final root = key.currentState;
    if (root != null && root.canPop()) {
      root.pop<T>(result);
      return;
    }
    final pane = paneKey.currentState;
    if (pane != null && pane.canPop()) pane.pop<T>(result);
  }

  static void clearPane() {
    paneItem.value = null;
    final pane = paneKey.currentState;
    if (pane != null && pane.canPop()) pane.popUntil((route) => route.isFirst);
  }

  static bool isShowing(String name) {
    for (final navigator in [key.currentState, paneKey.currentState]) {
      if (navigator == null) continue;
      var found = false;
      navigator.popUntil((route) {
        found = found || route.settings.name == name;
        return true;
      });
      if (found) return true;
    }
    return false;
  }

  static Route<T> route<T>(
    Widget page, {
    bool fullscreenDialog = false,
    bool fade = false,
    String? name,
  }) {
    if (fullscreenDialog || fade) {
      return PageRouteBuilder<T>(
        settings: RouteSettings(name: name),
        fullscreenDialog: fullscreenDialog,
        transitionDuration: const Duration(milliseconds: 340),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        opaque: true,
        pageBuilder: (_, __, ___) => AppBackground(child: page),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (fullscreenDialog) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
              ),
              child: child,
            );
          }
          return FadeThrough(animation: animation, child: child);
        },
      );
    }

    return AppPredictivePageRoute<T>(
      settings: RouteSettings(name: name),
      fullscreenDialog: false,
      builder: (_) => AppBackground(child: page),
    );
  }
}

class AppPredictivePageRoute<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin<T> {
  AppPredictivePageRoute({
    required this.builder,
    super.settings,
    super.fullscreenDialog,
  });

  final WidgetBuilder builder;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  String? get title => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 320);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 280);
}
