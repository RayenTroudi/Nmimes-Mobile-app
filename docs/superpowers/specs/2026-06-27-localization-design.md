# Localization Design — EN / FR / AR

**Date:** 2026-06-27  
**Status:** Approved

---

## Overview

Add Arabic and French translations to the Nmimes Flutter app while keeping English as the default. Users can switch language from the home screen language pill or from the parent Settings screen. The app also detects the device locale on first launch.

---

## Architecture

### Locale state

A `LocaleNotifier` (`ValueNotifier<Locale>`) is created once in `main.dart` and exposed to the entire widget tree via a `LocaleProvider` inherited widget. `MaterialApp.locale` binds to its value.

Locale resolution order on first launch:
1. Saved preference from `SharedPreferences` key `app_locale` — used if present.
2. Device locale, if it matches one of `['en', 'fr', 'ar']` — used as initial default.
3. Fall back to `Locale('en')`.

When the user selects a language, the new locale is written to both `LocaleNotifier` and `SharedPreferences`.

### `MaterialApp` changes

```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales, // en, fr, ar
  locale: localeNotifier.value,
  ...
)
```

Flutter's `MaterialApp` automatically sets `Directionality.rtl` for the full widget tree when `locale` is `Locale('ar')`. No per-widget RTL handling is needed — chevrons, paddings, and layouts flip automatically.

### ARB files

Location: `lib/l10n/`

| File | Language |
|------|----------|
| `app_en.arb` | English (source of truth) |
| `app_fr.arb` | French |
| `app_ar.arb` | Arabic |

Code generation (via `flutter gen-l10n`) produces `lib/l10n/generated/app_localizations.dart`. Every string is accessed as:

```dart
AppLocalizations.of(context)!.someKey
// or with a convenience alias
context.l10n.someKey
```

The `context.l10n` extension is defined in `lib/l10n/l10n_extension.dart`:

```dart
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
```

`pubspec.yaml` additions:
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  shared_preferences: ^2.3.0

flutter:
  generate: true
```

`l10n.yaml` at project root:
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n/generated
```

---

## Font Strategy

Poppins does not cover Arabic script. The solution is a locale-aware text style helper.

### `AppTextStyles` (extending `lib/theme/text_styles.dart`)

Add locale-aware factory methods:

```dart
static TextStyle headline(BuildContext context, {
  double fontSize = 24,
  FontWeight fontWeight = FontWeight.w700,
  Color? color,
}) {
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
  return isAr
    ? GoogleFonts.cairo(fontSize: fontSize, fontWeight: fontWeight, color: color)
    : GoogleFonts.poppins(fontSize: fontSize, fontWeight: fontWeight, color: color);
}

static TextStyle body(BuildContext context, { ... }) { ... }
static TextStyle label(BuildContext context, { ... }) { ... }
// etc.
```

Each screen replaces `GoogleFonts.poppins(...)` calls with `AppTextStyles.headline(context, ...)` etc. French uses the same Poppins as English — only Arabic switches to Cairo.

---

## Language Switcher

### Home screen pill (existing UI, wired up)

The `🇬🇧 ENG` pill in `_HomeHeader` already exists as static UI. It becomes interactive:

- Tapping it opens a `showModalBottomSheet` with three rows:
  - 🇬🇧 English
  - 🇫🇷 Français  
  - 🇸🇦 العربية
- The active language has a checkmark.
- Selecting an option writes to `LocaleNotifier` + `SharedPreferences`, then closes the sheet.
- The pill label updates reactively: `ENG` / `FR` / `عر` with the matching flag emoji.

### Parent Settings screen

A new `Language` row is added to `SettingsScreen` (between Notifications and Terms & Conditions). Tapping it opens the same bottom sheet.

### Shared bottom sheet

Extracted into a reusable `LanguagePickerSheet` widget in `lib/widgets/language_picker_sheet.dart` so both surfaces use the same component.

---

## String Extraction

### Scope

All user-visible string literals across all ~80 screens and widgets are extracted into ARB keys.

**Not extracted (stay hardcoded):**
- Brand name "Nmimes"
- Asset paths
- Route strings

**Dynamic values** use ARB placeholder syntax:
```json
"homeGreeting": "Hi, {name}",
"@homeGreeting": {
  "placeholders": { "name": { "type": "String" } }
}
```

### Key naming convention

`screenOrWidget_elementType_descriptor`

Examples:
- `onboarding_title_snapIt`
- `childSignIn_hint_username`
- `childSignIn_button_continue`
- `home_label_studyRooms`
- `settings_label_subscription`

### Translation approach

- **English:** Extracted from current hardcoded strings (source of truth).
- **French:** Standard translations.
- **Arabic:** Follows Figma Arabic designs where available; standard translations elsewhere.

---

## File Structure After Implementation

```
lib/
  l10n/
    app_en.arb
    app_fr.arb
    app_ar.arb
    l10n_extension.dart
    generated/              ← git-ignored, produced by flutter gen-l10n
      app_localizations.dart
      app_localizations_en.dart
      app_localizations_fr.dart
      app_localizations_ar.dart
  providers/
    locale_provider.dart    ← LocaleNotifier + LocaleProvider inherited widget
  widgets/
    language_picker_sheet.dart  ← reusable bottom sheet
  theme/
    text_styles.dart        ← extended with locale-aware factory methods
```

---

## RTL Considerations

- Flutter handles layout mirroring automatically for `ar` locale — no manual `Directionality` widgets needed.
- `TextAlign.start` is preferred over `TextAlign.left` in screens (start = left for LTR, right for RTL). Existing `crossAxisAlignment: CrossAxisAlignment.start` already works correctly.
- Any hardcoded `EdgeInsets.only(left: ...)` or `EdgeInsets.only(right: ...)` in screens should be replaced with `EdgeInsetsDirectional.only(start: ...)` during extraction.

---

## Out of Scope

- Translation of image assets (onboarding illustrations, mascot images)
- Per-locale number/date formatting beyond what `intl` provides automatically
- Backend/API locale passing
