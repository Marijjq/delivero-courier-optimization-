import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_street_map/data/notifiers.dart';
import 'package:open_street_map/data/theme_notifier.dart';
import 'package:open_street_map/data/language_notifier.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final languageNotifier = Provider.of<LanguageNotifier>(context);

    final List<Map<String, Object>> languages = [
      {'locale': const Locale('en'), 'name': 'English'},
      {'locale': const Locale('sq'), 'name': 'Shqip'},
      {'locale': const Locale('mk'), 'name': 'Македонски'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => selectedPageNotifier.value = 0,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(
              'settings.dark_mode'.tr(),
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
            value: themeNotifier.themeMode == ThemeMode.dark,
            onChanged: (val) => themeNotifier.toggleTheme(val),
            secondary: Icon(
              themeNotifier.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'settings.language'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          ...languages.map((lang) {
            return RadioListTile<Locale>(
              title: Text(
                lang['name'] as String,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
              value: lang['locale'] as Locale,
              groupValue: languageNotifier.locale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  context.setLocale(newLocale);
                  languageNotifier.setLocale(newLocale);
                }
              },
              activeColor: theme.colorScheme.secondary,
            );
          }).toList(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'settings.more_coming'.tr(),
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
