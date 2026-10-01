import 'dart:convert';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

class ReleaseAsset {
  const ReleaseAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
    required this.contentType,
  });

  final String name;
  final String downloadUrl;
  final int size;
  final String contentType;

  bool get isApk => name.toLowerCase().endsWith('.apk');

  factory ReleaseAsset.fromJson(Map<String, dynamic> json) {
    return ReleaseAsset(
      name: json['name'] as String? ?? '',
      downloadUrl: json['browser_download_url'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      contentType: json['content_type'] as String? ?? '',
    );
  }
}

class AppRelease {
  const AppRelease({
    required this.tagName,
    required this.name,
    required this.body,
    required this.htmlUrl,
    required this.publishedAt,
    required this.assets,
    required this.isPrerelease,
  });

  final String tagName;
  final String name;
  final String body;
  final String htmlUrl;
  final DateTime? publishedAt;
  final List<ReleaseAsset> assets;
  final bool isPrerelease;

  ReleaseAsset? get apkAsset {
    for (final asset in assets) {
      if (asset.isApk) return asset;
    }
    return null;
  }

  factory AppRelease.fromJson(Map<String, dynamic> json) {
    final rawAssets = json['assets'] as List<dynamic>? ?? const [];
    final assets = rawAssets
        .whereType<Map<String, dynamic>>()
        .map(ReleaseAsset.fromJson)
        .toList();

    DateTime? published;
    final publishedStr = json['published_at'] as String?;
    if (publishedStr != null) {
      published = DateTime.tryParse(publishedStr);
    }

    return AppRelease(
      tagName: json['tag_name'] as String? ?? '',
      name: json['name'] as String? ?? '',
      body: json['body'] as String? ?? '',
      htmlUrl: json['html_url'] as String? ??
          'https://github.com/smartworldarafath/Habit-Tracker-M3E/releases',
      publishedAt: published,
      assets: assets,
      isPrerelease: json['prerelease'] as bool? ?? false,
    );
  }
}

class UpdateCheckResult {
  const UpdateCheckResult({
    required this.currentVersion,
    this.latestRelease,
    required this.hasUpdate,
    this.errorMessage,
  });

  final String currentVersion;
  final AppRelease? latestRelease;
  final bool hasUpdate;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;
}

class UpdateService {
  const UpdateService._();

  static const String repoOwner = 'smartworldarafath';
  static const String repoName = 'Habit-Tracker-M3E';
  static const String releasesUrl =
      'https://github.com/$repoOwner/$repoName/releases';
  static const String releasesApiUrl =
      'https://api.github.com/repos/$repoOwner/$repoName/releases';

  static Future<String> getCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final v = info.version.trim();
      return v.isNotEmpty ? v : '1.2.0';
    } catch (_) {
      return '1.2.0';
    }
  }

  static Future<UpdateCheckResult> checkForUpdates() async {
    final currentVersion = await getCurrentVersion();
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 12);

    try {
      final uri = Uri.parse(releasesApiUrl);
      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'HabitTrackerApp');
      request.headers.set('Accept', 'application/vnd.github.v3+json');

      final response = await request.close();
      if (response.statusCode == 404) {
        // No releases published yet
        return UpdateCheckResult(
          currentVersion: currentVersion,
          hasUpdate: false,
        );
      }

      if (response.statusCode != 200) {
        return UpdateCheckResult(
          currentVersion: currentVersion,
          hasUpdate: false,
          errorMessage: 'Server responded with status ${response.statusCode}',
        );
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(responseBody);

      if (decoded is! List || decoded.isEmpty) {
        return UpdateCheckResult(
          currentVersion: currentVersion,
          hasUpdate: false,
        );
      }

      final releases = decoded
          .whereType<Map<String, dynamic>>()
          .map(AppRelease.fromJson)
          .where((r) => !r.isPrerelease)
          .toList();

      if (releases.isEmpty) {
        return UpdateCheckResult(
          currentVersion: currentVersion,
          hasUpdate: false,
        );
      }

      final latest = releases.first;
      final hasUpdate = isNewerVersion(currentVersion, latest.tagName);

      return UpdateCheckResult(
        currentVersion: currentVersion,
        latestRelease: latest,
        hasUpdate: hasUpdate,
      );
    } catch (e) {
      return UpdateCheckResult(
        currentVersion: currentVersion,
        hasUpdate: false,
        errorMessage: e.toString(),
      );
    } finally {
      client.close();
    }
  }

  /// Compares semantic versions, e.g. "1.0.1" vs "1.0.0"
  static bool isNewerVersion(String current, String remote) {
    try {
      final cleanCurrent = _normalizeVersion(current);
      final cleanRemote = _normalizeVersion(remote);

      final currentParts =
          cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final remoteParts =
          cleanRemote.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLen = currentParts.length > remoteParts.length
          ? currentParts.length
          : remoteParts.length;

      for (var i = 0; i < maxLen; i++) {
        final c = i < currentParts.length ? currentParts[i] : 0;
        final r = i < remoteParts.length ? remoteParts[i] : 0;
        if (r > c) return true;
        if (r < c) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static String _normalizeVersion(String raw) {
    var v = raw.trim();
    if (v.startsWith('v') || v.startsWith('V')) {
      v = v.substring(1);
    }
    // Remove any build metadata like +12
    if (v.contains('+')) {
      v = v.split('+').first;
    }
    // Remove any prerelease metadata like -beta
    if (v.contains('-')) {
      v = v.split('-').first;
    }
    return v;
  }
}
