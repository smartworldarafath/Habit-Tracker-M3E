import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_m3e/core/extensions/date_extensions.dart';
import 'package:habit_tracker_m3e/core/widgets/keep_built.dart';
import 'package:habit_tracker_m3e/app/theme/app_tokens.dart';
import 'package:habit_tracker_m3e/core/extensions/inset_extensions.dart';
import 'package:habit_tracker_m3e/core/widgets/pane_mark.dart';
import 'package:habit_tracker_m3e/core/widgets/stacked_corners.dart';
import 'package:habit_tracker_m3e/features/settings/state/settings_controller.dart';
import 'package:habit_tracker_m3e/features/habits/data/habit.dart';
import 'package:habit_tracker_m3e/features/habits/widgets/habit_card.dart';
import 'package:habit_tracker_m3e/features/habits/widgets/habit_heatmap.dart';
import 'package:habit_tracker_m3e/features/habits/widgets/habit_entrance.dart';
import 'package:habit_tracker_m3e/features/habits/widgets/slot_transition.dart';
import 'package:habit_tracker_m3e/features/habits/widgets/swipe_check.dart';

class ClassicHabitList extends StatelessWidget {
  const ClassicHabitList({
    super.key,
    required this.habits,
    required this.mode,
    required this.reordering,
    required this.header,
    required this.onReorder,
    required this.onOpen,
    required this.onToggleToday,
    required this.onToggleDay,
    required this.onLongPress,
    this.onSwipe,
    this.leaving = const {},
  });

  final List<Habit> habits;
  final HeatmapMode mode;
  final bool reordering;
  final Set<String> leaving;
  final Widget header;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<Habit> onOpen;
  final ValueChanged<Habit> onToggleToday;
  final void Function(Habit habit, DateTime date) onToggleDay;
  final ValueChanged<Habit> onLongPress;
  final ValueChanged<Habit>? onSwipe;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: context.pagePadding(16, 8, 16, 104),
      itemCount: habits.length,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        onReorder(oldIndex, newIndex);
      },
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        child: child,
      ),
      header: header,
      itemBuilder: (context, index) {
        final habit = habits[index];
        if (reordering) {
          return ReorderableDelayedDragStartListener(
            key: ValueKey(habit.id),
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: HabitCard(
                      habit: habit,
                      mode: mode,
                      onOpen: () {},
                      onToggleToday: () {},
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      LucideIcons.gripVertical,
                      color: context.tokens.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final compact = context.watch<SettingsController>().compactCards;
        return HabitEntrance(
          key: ValueKey(habit.id),
          index: index,
          child: SlotTransition(
            leaving: leaving.contains(habit.id),
            child: Padding(
              padding: EdgeInsets.only(bottom: compact ? 3 : 12),
              child: PaneMark(
                id: habit.id,
                tint: habit.color,
                corners: compact
                    ? stackedCorners(index, habits.length)
                    : BorderRadius.circular(24),
                child: SwipeCheck(
                  done: habit.isCompletedOn(AppClock.today()),
                  tint: habit.color,
                  corners: compact
                      ? stackedCorners(index, habits.length)
                      : BorderRadius.circular(24),
                  onSwipe: onSwipe == null ? null : () => onSwipe!(habit),
                  child: KeepBuilt(
                  keys: [habit, mode, compact, index, habits.length, AppClock.today()],
                  build: () => HabitCard(
                    habit: habit,
                    mode: mode,
                    corners: compact
                        ? stackedCorners(index, habits.length)
                        : null,
                    onOpen: () => onOpen(habit),
                    onToggleToday: () => onToggleToday(habit),
                    onToggleDay: (date) => onToggleDay(habit, date),
                    onLongPress: () => onLongPress(habit),
                  ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
