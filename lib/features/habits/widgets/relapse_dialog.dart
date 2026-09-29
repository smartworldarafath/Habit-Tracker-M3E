import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:habit_tracker_m3e/core/i18n/l10n.dart';
import 'package:habit_tracker_m3e/core/widgets/app_confirm_dialog.dart';
import 'package:habit_tracker_m3e/core/extensions/date_extensions.dart';
import 'package:habit_tracker_m3e/features/habits/data/habit.dart';

bool isRelapse(Habit habit, DateTime date) =>
    habit.completions.containsKey(date.dayKey);

Future<bool> confirmRelapse(BuildContext context, Habit habit) async {
  final confirmed = await showAppConfirmDialog(
    context,
    title: context.l10n.log_relapse_title,
    message: context.l10n.log_relapse_body(habit.name),
    confirmLabel: context.l10n.log_relapse_confirm,
    icon: LucideIcons.ban,
  );
  if (confirmed != true) return false;
  return true;
}
