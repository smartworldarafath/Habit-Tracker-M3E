import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_m3e/core/i18n/app_locale.dart';
import 'package:habit_tracker_m3e/app/app_background.dart';
import 'package:habit_tracker_m3e/app/app_lock.dart';
import 'package:habit_tracker_m3e/app/home_shell.dart';
import 'package:habit_tracker_m3e/app/theme/app_theme.dart';
import 'package:habit_tracker_m3e/core/i18n/l10n.dart';
import 'package:habit_tracker_m3e/core/routing/app_navigator.dart';
import 'package:habit_tracker_m3e/core/utils/responsive.dart';
import 'package:habit_tracker_m3e/features/focus/widgets/focus_island.dart';
import 'package:habit_tracker_m3e/features/habits/state/habits_controller.dart';
import 'package:habit_tracker_m3e/features/onboarding/pages/onboarding_page.dart';
import 'package:habit_tracker_m3e/features/settings/state/settings_controller.dart';
import 'package:habit_tracker_m3e/services/home_widget_service.dart';

class StreakApp extends StatelessWidget {
  const StreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return MaterialApp(
      title: 'Habit Tracker M3E',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.key,
      theme: AppTheme.light(settings.accentColor, settings.appStyle),
      darkTheme: AppTheme.dark(settings.accentColor, settings.appStyle),
      themeMode: settings.themeMode,
      builder: (context, child) {
        HomeWidgetService.localize(
          AppLocalizations.of(context),
          () => context.read<HabitsController>().asMap,
        );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.systemBars(Theme.of(context).brightness),
          child: AppLockGate(
            child: AppBackground(
              child: _DesktopFrame(
                shell: settings.onboardingDone,
                child: FocusIsland(child: child ?? const SizedBox.shrink()),
              ),
            ),
          ),
        );
      },
      locale: settings.locale,
      supportedLocales: shippedLocales,
      localeListResolutionCallback: (wanted, _) => pickLocale(wanted),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: settings.onboardingDone
          ? const HomeShell()
          : const OnboardingPage(),
    );
  }
}

class _DesktopFrame extends StatelessWidget {
  const _DesktopFrame({required this.shell, required this.child});

  final bool shell;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || (shell && hasSideRail(context))) return child;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: phoneWidth),
        child: SizedBox.expand(child: child),
      ),
    );
  }
}
