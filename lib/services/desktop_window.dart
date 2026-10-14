import 'package:flutter/services.dart';
import 'package:streak/core/utils/app_platform.dart';

class DesktopWindow {
  const DesktopWindow._();

  static const _channel = MethodChannel('streak/window');

  static Future<void> setFullscreen(bool on) async {
    if (!AppPlatform.isWindows && !AppPlatform.isLinux) return;
    try {
      await _channel.invokeMethod<void>('fullscreen', on);
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }
}
