import 'dart:ui';

import 'package:habit_tracker_m3e/l10n/app_localizations.dart';

const shippedLanguages = {
  'de', 'en', 'es', 'fr', 'ko', 'pt', 'ru', 'uk', 'zh',
};

List<Locale> get shippedLocales => AppLocalizations.supportedLocales
    .where((l) => shippedLanguages.contains(l.languageCode))
    .toList();

Locale pickLocale(Iterable<Locale>? wanted) {
  for (final locale in wanted ?? const <Locale>[]) {
    if (shippedLanguages.contains(locale.languageCode)) {
      return Locale(locale.languageCode);
    }
  }
  return const Locale('en');
}
