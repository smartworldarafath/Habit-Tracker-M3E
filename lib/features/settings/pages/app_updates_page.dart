import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:streak/app/theme/app_tokens.dart';
import 'package:streak/core/extensions/inset_extensions.dart';
import 'package:streak/core/utils/app_snackbar.dart';
import 'package:streak/core/widgets/entrance.dart';
import 'package:streak/core/express/express_page.dart';
import 'package:streak/features/settings/state/settings_controller.dart';
import 'package:streak/services/update_service.dart';
import 'package:streak/core/widgets/fluid_water_waves.dart';

class AppUpdatesPage extends StatefulWidget {
  const AppUpdatesPage({super.key});

  @override
  State<AppUpdatesPage> createState() => _AppUpdatesPageState();
}

class _AppUpdatesPageState extends State<AppUpdatesPage> {
  bool _isLoading = false;
  UpdateCheckResult? _result;
  String _currentVersion = '1.3.1';

  @override
  void initState() {
    super.initState();
    _initAndCheck();
  }

  Future<void> _initAndCheck() async {
    final v = await UpdateService.getCurrentVersion();
    if (mounted) setState(() => _currentVersion = v);
    await _check();
  }

  Future<void> _check() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final res = await UpdateService.checkForUpdates();
      if (mounted) {
        setState(() {
          _result = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = UpdateCheckResult(
            currentVersion: _currentVersion,
            hasUpdate: false,
            errorMessage: e.toString(),
          );
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, url);
    }
  }

  Future<void> _startDownload(ReleaseAsset asset) async {
    // If external download requested or starting:
    // First try opening the download URL directly so the system browser/installer handles it
    // This gives the best user experience on Android:
    final apkUrl = asset.downloadUrl;
    if (apkUrl.isEmpty) {
      _openUrl(UpdateService.releasesUrl);
      return;
    }

    // Direct browser launch handles download + 1-tap install on Android
    await _openUrl(apkUrl);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final muted = context.tokens.muted;
    final isExpress = context.watch<SettingsController>().isExpressStyle;

    final hasUpdate = _result?.hasUpdate ?? false;
    final release = _result?.latestRelease;
    final apkAsset = release?.apkAsset;

    return Scaffold(
      appBar: isExpress
          ? expressBar()
          : AppBar(
              title: const Text('App Updates'),
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
      body: RefreshIndicator(
        onRefresh: _check,
        child: ListView(
          padding: context.pagePadding(16, 12, 16, 80),
          children: [
            // App Icon Header
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/app_icons/icon_default.png',
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Habit Tracker M3E',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'v$_currentVersion',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Status Card
            Entrance(
              child: FluidWaterWaveWidget(
                active: hasUpdate,
                primaryColor: scheme.primary,
                child: Card(
                  elevation: 0,
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: hasUpdate
                          ? scheme.primary.withValues(alpha: 0.5)
                          : scheme.outlineVariant.withValues(alpha: 0.3),
                      width: hasUpdate ? 1.5 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: hasUpdate
                              ? scheme.primary.withValues(alpha: 0.15)
                              : scheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: _isLoading
                            ? Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: scheme.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                hasUpdate
                                    ? LucideIcons.arrowUpCircle
                                    : (_result?.errorMessage != null
                                        ? LucideIcons.triangleAlert
                                        : LucideIcons.checkCheck),
                                size: 32,
                                color: hasUpdate
                                    ? scheme.primary
                                    : (_result?.errorMessage != null
                                        ? context.tokens.danger
                                        : Colors.green),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isLoading
                            ? 'Checking for updates...'
                            : (hasUpdate
                                ? 'New Update Available!'
                                : (_result?.errorMessage != null
                                    ? 'Check Failed'
                                    : "You're up to date")),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isLoading
                            ? 'Connecting to GitHub Releases...'
                            : (hasUpdate
                                ? 'Version ${release?.tagName ?? ''} is now available to download.'
                                : (_result?.errorMessage != null
                                    ? 'Could not connect to GitHub. Pull down or tap below to retry.'
                                    : 'Habit Tracker is running the latest version (v$_currentVersion).')),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonalIcon(
                        onPressed: _isLoading ? null : _check,
                        icon: const Icon(LucideIcons.refreshCw, size: 16),
                        label: Text(_isLoading ? 'Checking...' : 'Check Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

            // If Update Available: New Release Details
            if (hasUpdate && release != null) ...[
              Entrance(
                index: 1,
                child: Card(
                  elevation: 0,
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                release.tagName,
                                style: TextStyle(
                                  color: scheme.onPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (release.publishedAt != null)
                              Text(
                                '${release.publishedAt!.year}-${release.publishedAt!.month.toString().padLeft(2, '0')}-${release.publishedAt!.day.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: muted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        if (release.name.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            release.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                        if (release.body.trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: scheme.outlineVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            child: SelectableText(
                              release.body.trim(),
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: scheme.onSurface.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        if (apkAsset != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: scheme.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.fileBox, size: 20, color: scheme.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        apkAsset.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                      Text(
                                        'Package Size: ${(apkAsset.size / (1024 * 1024)).toStringAsFixed(1)} MB',
                                        style: TextStyle(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => _startDownload(apkAsset),
                              icon: const Icon(LucideIcons.download, size: 18),
                              label: Text(
                                apkAsset.size > 0
                                    ? 'Download APK (${(apkAsset.size / (1024 * 1024)).toStringAsFixed(1)} MB)'
                                    : 'Download & Install APK',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _openUrl(release.htmlUrl),
                            icon: const Icon(LucideIcons.externalLink, size: 16),
                            label: const Text('View Release on GitHub'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // App & Environment Information
            Entrance(
              index: 2,
              child: Card(
                elevation: 0,
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(LucideIcons.tag, color: scheme.primary),
                      title: const Text('Current Version'),
                      trailing: Text(
                        'v$_currentVersion',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: scheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                    ListTile(
                      leading: Icon(LucideIcons.globe, color: scheme.primary),
                      title: const Text('Release Channel'),
                      subtitle: const Text('github.com/smartworldarafath/Habit-Tracker-M3E'),
                      trailing: const Icon(LucideIcons.chevronRight, size: 18),
                      onTap: () => _openUrl(UpdateService.releasesUrl),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
