import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';
const _supported = ['en', 'fr', 'ar'];

Future<Locale> resolveInitialLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_kLocaleKey);
  if (saved != null && _supported.contains(saved)) {
    return Locale(saved);
  }
  final deviceLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  if (_supported.contains(deviceLang)) {
    return Locale(deviceLang);
  }
  return const Locale('en');
}

class LocaleNotifier extends ValueNotifier<Locale> {
  LocaleNotifier(super.value);

  Future<void> setLocale(Locale locale) async {
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }
}

class LocaleProvider extends InheritedWidget {
  final LocaleNotifier notifier;

  const LocaleProvider({
    super.key,
    required this.notifier,
    required super.child,
  });

  static LocaleNotifier of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocaleProvider>()!
        .notifier;
  }

  @override
  bool updateShouldNotify(LocaleProvider oldWidget) =>
      notifier != oldWidget.notifier;
}
