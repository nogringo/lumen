import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';

/// Each supported language in its own words, in the order the picker lists
/// them.
final languageNames = {
  const Locale('de'): 'Deutsch',
  const Locale('en'): 'English',
  const Locale('es'): 'Español',
  const Locale('fr'): 'Français',
  const Locale('it'): 'Italiano',
  const Locale('pt', 'BR'): 'Português (Brasil)',
  const Locale('pt'): 'Português (Portugal)',
  const Locale('fi'): 'Suomi',
  const Locale('ru'): 'Русский',
  const Locale('ja'): '日本語',
  const Locale('zh'): '简体中文',
};

abstract interface class LanguageStore {
  /// The saved language tag, such as `pt-BR`.
  Future<String?> read();

  /// Saves [tag], or forgets it when null.
  Future<void> write(String? tag);
}

/// Kept out of secure storage: the language is not secret, it has to apply on
/// the lock screen, and resetting Lumen keeps it.
final class PrefsLanguageStore implements LanguageStore {
  final _prefs = SharedPreferencesAsync();

  static const storageKey = 'lumen.language';

  @override
  Future<String?> read() => _prefs.getString(storageKey);

  @override
  Future<void> write(String? tag) => tag == null
      ? _prefs.remove(storageKey)
      : _prefs.setString(storageKey, tag);
}

final class MemoryLanguageStore implements LanguageStore {
  MemoryLanguageStore([this.tag]);

  String? tag;

  @override
  Future<String?> read() async => tag;

  @override
  Future<void> write(String? tag) async => this.tag = tag;
}

/// The language picked in Settings, or null to follow the device.
class LanguageSetting extends ChangeNotifier {
  LanguageSetting(this._store);

  final LanguageStore _store;

  Locale? get locale => _locale;
  Locale? _locale;

  Future<void> load() async {
    final tag = await _store.read();
    _locale = AppLocalizations.supportedLocales
        .where((locale) => locale.toLanguageTag() == tag)
        .firstOrNull;
    notifyListeners();
  }

  Future<void> choose(Locale? locale) async {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
    await _store.write(locale?.toLanguageTag());
  }
}

class LanguageScope extends InheritedNotifier<LanguageSetting> {
  const LanguageScope({
    super.key,
    required LanguageSetting language,
    required super.child,
  }) : super(notifier: language);

  /// Rebuilds [context] when another language is picked.
  static LanguageSetting of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LanguageScope>()!.notifier!;
}
