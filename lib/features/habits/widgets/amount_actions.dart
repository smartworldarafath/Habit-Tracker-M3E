import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_m3e/core/extensions/date_extensions.dart';
import 'package:habit_tracker_m3e/core/i18n/l10n.dart';
import 'package:habit_tracker_m3e/core/widgets/number_keypad_dialog.dart';
import 'package:habit_tracker_m3e/features/habits/data/habit.dart';
import 'package:habit_tracker_m3e/features/habits/state/habits_controller.dart';
import 'package:habit_tracker_m3e/features/habits/widgets/unscheduled_day_dialog.dart';

Future<void> addCustomAmount(BuildContext context, Habit habit) async {
  if (habit.kind != HabitKind.quantitative) return;

  final today = AppClock.now();
  if (!await confirmUnscheduledDay(context, habit: habit, date: today)) return;
  if (!context.mounted) return;

  final amount = await showNumberKeypadDialog(
    context,
    title: context.l10n.quant_add_title,
    value: 0,
    unit: habit.unitLabel,
    decimals: true,
    clock: habit.isTimeAmount,
    accent: habit.color,
  );
  if (amount == null || amount <= 0 || !context.mounted) return;

  await context.read<HabitsController>().addProgress(habit.id, today, amount);
}
