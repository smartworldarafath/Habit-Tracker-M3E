import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_m3e/app/theme/app_tokens.dart';
import 'package:habit_tracker_m3e/core/extensions/date_extensions.dart';
import 'package:habit_tracker_m3e/core/i18n/l10n.dart';
import 'package:habit_tracker_m3e/core/routing/app_navigator.dart';
import 'package:habit_tracker_m3e/core/utils/responsive.dart';
import 'package:habit_tracker_m3e/core/widgets/sheet_action.dart';
import 'package:habit_tracker_m3e/core/widgets/sheet_type.dart';
import 'package:habit_tracker_m3e/features/habits/data/habit.dart';
import 'package:habit_tracker_m3e/features/habits/pages/note_editor_page.dart';
import 'package:habit_tracker_m3e/features/habits/pages/notes_page.dart';
import 'package:habit_tracker_m3e/features/habits/state/habits_controller.dart';
import 'package:habit_tracker_m3e/features/habits/state/notes_controller.dart';
import 'package:habit_tracker_m3e/features/habits/widgets/habit_checklist.dart';

Future<void> showDayActionsSheet(
  BuildContext context, {
  required Habit habit,
  required DateTime date,
  required bool notesEnabled,
}) {
  final count = context.read<NotesController>().countFor(habit.id, date.dayKey);
  final locale = Localizations.localeOf(context).toString();
  final habits = context.read<HabitsController>();
  final paused = habit.isPausedOn(date);

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxWidth: phoneWidth,
      maxHeight: MediaQuery.sizeOf(context).height * 0.85,
    ),
    builder: (sheet) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                DateFormat.yMMMMEEEEd(locale).format(date),
                style: sheetTitleStyle(context, size: 17),
              ),
            ),
            if (habit.hasSubsteps &&
                !date.atMidnight.isAfter(AppClock.today())) ...[
              Consumer<HabitsController>(
                builder: (inner, controller, _) => HabitChecklist(
                  habit: controller.byId(habit.id) ?? habit,
                  date: date,
                  dense: true,
                  header: true,
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (!habit.isRestDay(date) &&
                !date.atMidnight.isAfter(AppClock.today())) ...[
              SheetAction(
                icon: LucideIcons.palmtree,
                label: paused
                    ? context.l10n.vacation_day_off
                    : context.l10n.vacation_day_on,
                accent: context.tokens.info,
                highlighted: paused,
                onTap: () {
                  Navigator.of(sheet).pop();
                  habits.toggleVacationDay(habit.id, date);
                },
              ),
              const SizedBox(height: 6),
            ],
            if (notesEnabled) ...[
              SheetAction(
                icon: LucideIcons.notebookPen,
                label: context.l10n.view_notes,
                badge: count > 0 ? '$count' : null,
                accent: habit.color,
                highlighted: true,
                trailing: LucideIcons.chevronRight,
                onTap: () {
                  Navigator.of(sheet).pop();
                  AppNavigator.push(
                    NotesPage(
                      habitId: habit.id,
                      date: date,
                      accent: habit.color,
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              SheetAction(
                icon: LucideIcons.circlePlus,
                label: context.l10n.add_note,
                onTap: () {
                  Navigator.of(sheet).pop();
                  AppNavigator.push(
                    NoteEditorPage(
                      habitId: habit.id,
                      dayKey: date.dayKey,
                      accent: habit.color,
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(sheet).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.surfaceContainerHighest,
                  foregroundColor: context.colors.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  context.l10n.cancel,
                  style: sheetActionStyle(context),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
