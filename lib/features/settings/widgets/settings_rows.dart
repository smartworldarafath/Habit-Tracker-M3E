import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:streak/app/theme/app_tokens.dart';
import 'package:streak/core/widgets/verified_badge.dart';

Widget settingsDivider(BuildContext context) => Divider(
      height: 1,
      indent: 60,
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
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconBadge(icon: icon),
          const SizedBox(width: 14),
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
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
    if (enabled) return row;
    return IgnorePointer(child: Opacity(opacity: 0.45, child: row));
  }
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: IconBadge(icon: icon, tint: tint),
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
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: TextStyle(color: context.tokens.muted)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.tokens.muted,
              ),
            ),
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
      leading: IconBadge(icon: icon),
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
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconBadge(icon: icon),
              const SizedBox(width: 14),
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
                  ],
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.tokens.muted,
                  ),
                ),
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

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final count = options.length;
    if (count == 0) return const SizedBox.shrink();

    final safeIndex = index.clamp(0, count - 1);
    final maxChars = options.fold<int>(0, (prev, s) => math.max(prev, s.length));
    final double itemWidth = customItemWidth ??
        math.max(38.0, (maxChars * 7.2 + 14.0).clamp(38.0, 58.0));
    final double totalWidth = itemWidth * count;

    return Container(
      width: totalWidth + 6,
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
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

  static const double _itemWidth = 52.0;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final count = VerifiedBadgeType.values.length;
    final safeIndex = index.clamp(0, count - 1);
    final totalWidth = _itemWidth * count;

    return Container(
      width: totalWidth + 6,
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
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
    );
  }
}
