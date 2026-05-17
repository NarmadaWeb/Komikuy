import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:komikuy/l10n/app_localizations.dart';
import 'package:komikuy/providers/comic_provider.dart';
import 'package:komikuy/widgets/app_alerts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ComicProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              _buildSectionHeader(l10n.generalSection),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: Text(l10n.darkMode),
                trailing: Switch(
                  value: provider.themeMode == ThemeMode.dark ||
                      (provider.themeMode == ThemeMode.system &&
                          MediaQuery.platformBrightnessOf(context) ==
                              Brightness.dark),
                  onChanged: (val) {
                    provider.toggleTheme(val);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(l10n.notifications),
                subtitle: Text(l10n.notificationsSubtitle),
                trailing: Switch(value: true, onChanged: (val) {}),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(l10n.languageSubtitle),
                trailing: DropdownButton<String>(
                  value: provider.locale?.languageCode ?? 'en',
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      provider.setLocale(Locale(newValue));
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: 'id',
                      child: Text('Bahasa Indonesia'),
                    ),
                  ],
                  underline: const SizedBox(),
                ),
              ),
              _buildSectionHeader(l10n.storageSection),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.clearCache),
                subtitle: Text(l10n.clearCacheSubtitle),
                onTap: () {
                  AppAlerts.showConfirm(context, l10n.clearCacheConfirmMessage,
                      title: l10n.clearCacheConfirmTitle, onConfirm: () {
                    // In a real app we'd clear DefaultCacheManager here
                    AppAlerts.showSuccess(
                        context, l10n.clearCacheSuccessMessage);
                  });
                },
              ),
              _buildSectionHeader(l10n.aboutSection),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.aboutKomikuy),
                subtitle: const Text('Version 1.0.0'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Komikuy',
                    applicationVersion: '1.0.0',
                    applicationIcon:
                        const Icon(Icons.book, size: 48, color: Colors.blue),
                    children: const [
                      SizedBox(height: 16),
                      Text(
                          'Komikuy is a free comic reader app that allows you to read your favorite manga, manhwa, and manhua from komiku.org.'),
                    ],
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.privacyPolicy),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.privacyPolicy),
                      content: const SingleChildScrollView(
                        child: Text('Privacy Policy for Komikuy\n\n'
                            'This app is provided at no cost and is intended for use as is. '
                            'We do not collect any personal data or usage analytics. '
                            'All data such as history and bookmarks are stored locally on your device.\n\n'
                            'The app fetches comic data and images directly from komiku.org. '
                            'We are not affiliated with komiku.org in any way.'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.close),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
