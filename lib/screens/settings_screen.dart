import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:komikuy/providers/comic_provider.dart';
import 'package:komikuy/widgets/app_alerts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ComicProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              _buildSectionHeader('General'),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: provider.themeMode == ThemeMode.dark || (provider.themeMode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark),
                  onChanged: (val) {
                    provider.toggleTheme(val);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                subtitle: const Text('Get updates for your library'),
                trailing: Switch(value: true, onChanged: (val) {}),
              ),

              _buildSectionHeader('Storage'),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Clear Cache'),
                subtitle: const Text('Free up space by clearing image cache'),
                onTap: () {
                  AppAlerts.showConfirm(
                    context,
                    'Are you sure you want to clear the image cache?',
                    title: 'Clear Cache',
                    onConfirm: () {
                      // In a real app we'd clear DefaultCacheManager here
                      AppAlerts.showSuccess(context, 'Image cache cleared successfully');
                    }
                  );
                },
              ),

              _buildSectionHeader('About'),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Komikuy'),
                subtitle: const Text('Version 1.0.0'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                onTap: () {},
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
