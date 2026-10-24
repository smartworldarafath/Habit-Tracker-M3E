import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:streak/app/theme/app_tokens.dart';
import 'package:streak/core/widgets/verified_badge.dart';
import 'package:streak/core/utils/responsive.dart';
import 'package:streak/features/settings/widgets/minimal_settings_widgets.dart';

Widget settingsDivider(BuildContext context) => Divider(
      height: 1,
      indent: bareRows(context) ? 16 : 60,
      endIndent: 16,
      color: context.colors.surfaceContainerHighest,
    );

class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, this.tint});

  final IconData icon;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? context.colors.onSurface;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: tint == null
            ? context.colors.surfaceContainerHighest
            : tint!.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.icon,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final bool enabled;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, box) => _row(context, box.maxWidth));

  Widget _row(BuildContext context, double width) {
    final stacked = stackedRows(context);
    final inner = width - 32;
    final segmented = trailing is Segmented ? trailing as Segmented : null;
    final longest = _longestWord(context);
    final heading = textWidth(context, title, _titleStyle);
    final compact = segmented != null &&
        (stacked
            ? segmented.naturalWidth(context) > inner - 44
            : inner - 56 - segmented.naturalWidth(context) <
                (heading > 100 ? heading : 100));
    final shown = compact
        ? SegmentedSelect(segmented: segmented, title: title)
        : trailing;
    final side = stacked
        ? 0.0
        : compact
            ? SegmentedSelect.width
            : segmented?.naturalWidth(context) ?? 64;
    final bare = bareRows(context) ||
        longest > inner - 44 - (stacked ? 0 : side + 12);
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (!bare) IconBadge(icon: icon),
          if (!bare) const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 13, color: context.tokens.muted),
                  ),
                ],
                if (stacked) ...[
                  const SizedBox(height: 10),
                  shown,
                ],
              ],
            ),
          ),
          if (!stacked) const SizedBox(width: 12),
          if (!stacked) shown,
        ],
      ),
    );
    if (enabled) return row;
    return IgnorePointer(child: Opacity(opacity: 0.45, child: row));
  }

  static const _titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

  double _longestWord(BuildContext context) {
    var longest = 0.0;
    for (final word in title.split(' ')) {
      final width = textWidth(context, word, _titleStyle);
      if (width > longest) longest = width;
    }
    return longest;
  }
}

double textWidth(BuildContext context, String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: DefaultTextStyle.of(context).style.merge(style)),
    textScaler: MediaQuery.textScalerOf(context),
    textDirection: Directionality.of(context),
    maxLines: 1,
  )..layout();
  return painter.width;
}

class NavRow extends StatelessWidget {
  const NavRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.value,
    this.badge,
    this.tint,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback onTap;
  final String? badge;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final stacked = stackedRows(context) && value != null;
    final shown = value == null
        ? null
        : Text(
            value!,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.tokens.muted,
            ),
          );
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: bareRows(context) ? null : IconBadge(icon: icon, tint: tint),
      title: Row(
        children: [
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            TagPill(label: badge!),
          ],
        ],
      ),
      subtitle: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(subtitle!, style: TextStyle(color: context.tokens.muted)),
                const SizedBox(height: 4),
                shown!,
              ],
            )
          : subtitle == null
          ? null
          : Text(subtitle!, style: TextStyle(color: context.tokens.muted)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!stacked && shown != null) shown,
          const SizedBox(width: 6),
          Icon(LucideIcons.chevronRight,
              size: 18, color: context.tokens.muted),
        ],
      ),
      onTap: onTap,
    );
  }
}

class TagPill extends StatelessWidget {
  const TagPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }
}

class LinkRow extends StatelessWidget {
  const LinkRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: bareRows(context) ? null : IconBadge(icon: icon),
      horizontalTitleGap: 14,
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: TextStyle(color: context.tokens.muted)),
      trailing:
          Icon(LucideIcons.chevronRight, size: 18, color: context.tokens.muted),
      onTap: onTap,
    );
  }
}

class PickerRow extends StatelessWidget {
  const PickerRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final stacked = stackedRows(context);
    final bare = bareRows(context);
    final shown = value == null
        ? null
        : Text(
            value!,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.tokens.muted,
            ),
          );
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (!bare) IconBadge(icon: icon),
              if (!bare) const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.tokens.muted,
                        ),
                      ),
                    ],
                    if (stacked && shown != null) ...[
                      const SizedBox(height: 4),
                      shown,
                    ],
                  ],
                ),
              ),
              if (!stacked && shown != null) ...[
                const SizedBox(width: 12),
                shown,
              ],
              if (trailing != null) trailing!,
              const SizedBox(width: 6),
              Icon(LucideIcons.chevronRight,
                  size: 18, color: context.tokens.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class Segmented extends StatelessWidget {
  const Segmented({
    super.key,
    required this.options,
    required this.index,
    required this.onChanged,
    this.customItemWidth,
  });

  final List<String> options;
  final int index;
  final ValueChanged<int> onChanged;
  final double? customItemWidth;

  static const _label = TextStyle(fontSize: 12, fontWeight: FontWeight.w700);

  double naturalWidth(BuildContext context) {
    var total = 5.0;
    for (final option in options) {
      total += textWidth(context, option, _label) + 18;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final count = options.length;
    if (count == 0) return const SizedBox.shrink();

    final safeIndex = index.clamp(0, count - 1);
    final maxChars = options.fold<int>(0, (prev, s) => math.max(prev, s.length));
    final double itemWidth = customItemWidth ??
        math.max(36.0, (maxChars * 7.0 + 12.0).clamp(36.0, 56.0));
    final double totalWidth = itemWidth * count;

    return Container(
      width: totalWidth + 8.0,
      height: 34,
      padding: const EdgeInsets.all(3),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: SizedBox(
        width: totalWidth,
        height: 26,
        child: Stack(
        children: [
          // Animated sliding dock pill thumb
          AnimatedPositioned(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            left: safeIndex * itemWidth,
            top: 0,
            bottom: 0,
            width: itemWidth,
            child: Container(
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.35),
                    blurRadius: 5,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
            ),
          ),
          // Option touch targets & texts
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < count; i++)
                SizedBox(
                  width: itemWidth,
                  height: double.infinity,
                  child: Semantics(
                    button: true,
                    selected: i == safeIndex,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (i != safeIndex) {
                          HapticFeedback.selectionClick();
                          onChanged(i);
                        }
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: i == safeIndex
                                ? scheme.onPrimary
                                : context.tokens.muted,
                            fontFamily: 'Figtree',
                          ),
                          child: Text(
                            options[i],
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class AppIconDockSlider extends StatefulWidget {
  const AppIconDockSlider({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  State<AppIconDockSlider> createState() => _AppIconDockSliderState();
}

class _AppIconDockSliderState extends State<AppIconDockSlider> {
  final ScrollController _scrollController = ScrollController();

  static const _items = [
    (name: 'Default', asset: 'assets/app_icons/icon_default.png'),
    (name: 'Green', asset: 'assets/app_icons/icon_green.png'),
    (name: 'Tricolor', asset: 'assets/app_icons/icon_tricolor.png'),
    (name: 'Orange', asset: 'assets/app_icons/icon_orange.png'),
  ];

  static const double _itemWidth = 64.0;

  @override
  void didUpdateWidget(covariant AppIconDockSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _scrollToIndex(widget.index);
    }
  }

  void _scrollToIndex(int idx) {
    if (!_scrollController.hasClients) return;
    final target = (idx * _itemWidth) - 40;
    _scrollController.animateTo(
      target.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final count = _items.length;
    final safeIndex = widget.index.clamp(0, count - 1);

    return Container(
      width: 198,
      height: 38,
      padding: const EdgeInsets.all(3),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: _itemWidth * count,
          height: 32,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                left: safeIndex * _itemWidth,
                top: 0,
                bottom: 0,
                width: _itemWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.35),
                        blurRadius: 5,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < count; i++)
                    SizedBox(
                      width: _itemWidth,
                      height: double.infinity,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (i != safeIndex) {
                            HapticFeedback.selectionClick();
                            widget.onChanged(i);
                            _scrollToIndex(i);
                          }
                        },
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.asset(
                                  _items[i].asset,
                                  width: 15,
                                  height: 15,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _items[i].name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: i == safeIndex
                                        ? scheme.onPrimary
                                        : context.tokens.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerifiedBadgeDockSlider extends StatelessWidget {
  const VerifiedBadgeDockSlider({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const double _itemWidth = 49.0;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final count = VerifiedBadgeType.values.length;
    final safeIndex = index.clamp(0, count - 1);
    final totalWidth = _itemWidth * count;

    return Container(
      width: totalWidth + 8.0,
      height: 34,
      padding: const EdgeInsets.all(3),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: SizedBox(
        width: totalWidth,
        height: 26,
        child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            left: safeIndex * _itemWidth,
            top: 0,
            bottom: 0,
            width: _itemWidth,
            child: Container(
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.35),
                    blurRadius: 5,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < count; i++)
                SizedBox(
                  width: _itemWidth,
                  height: double.infinity,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (i != safeIndex) {
                        HapticFeedback.selectionClick();
                        onChanged(i);
                      }
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (i > 0) ...[
                            VerifiedBadge(
                              color: VerifiedBadgeType.values[i].color,
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                          ],
                          Text(
                            VerifiedBadgeType.values[i].label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: i == safeIndex
                                  ? scheme.onPrimary
                                  : context.tokens.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class SegmentedSelect extends StatelessWidget {
  const SegmentedSelect({
    super.key,
    required this.segmented,
    required this.title,
  });

  static const width = 140.0;

  final Segmented segmented;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: () => showOptionSheet(
          context,
          title: title,
          options: segmented.options,
          index: segmented.index,
          onSelected: segmented.onChanged,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: width),
          padding: const EdgeInsets.fromLTRB(12, 7, 9, 7),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  segmented.options[segmented.index.clamp(0, segmented.options.length - 1)],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(LucideIcons.chevronsUpDown, size: 15, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
