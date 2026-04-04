// Settings Screen - Theme, IAP, About

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_state.dart';
import '../services/iap_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme Toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark/light theme'),
            value: theme == AppThemeMode.dark,
            onChanged: (_) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
            secondary: Icon(
              theme == AppThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            ),
          ),

          const Divider(),

          // IAP Section
          ListTile(
            title: const Text('In-App Purchases'),
            subtitle: const Text('Support the game'),
            leading: const Icon(Icons.shopping_cart),
          ),

          if (!IAPService.instance.adsRemoved)
            ListTile(
              title: const Text('Remove Ads'),
              subtitle: const Text('\$2.99 - One-time purchase'),
              trailing: ElevatedButton(
                onPressed: () async {
                  final success = await IAPService.instance.purchaseRemoveAds();
                  if (context.mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ads removed! Thank you!')),
                    );
                  }
                },
                child: const Text('Buy'),
              ),
            )
          else
            const ListTile(
              title: Text('Remove Ads'),
              subtitle: Text('Purchased - Thank you!'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),

          ListTile(
            title: const Text('Restore Purchases'),
            subtitle: const Text('Restore previous purchases'),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await IAPService.instance.initialize();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchases restored')),
                  );
                }
              },
            ),
          ),

          const Divider(),

          // Game Section
          ListTile(
            title: const Text('Reset Progress'),
            subtitle: const Text('Start from level 1'),
            leading: const Icon(Icons.refresh),
            onTap: () {
              _showResetDialog(context, ref);
            },
          ),

          const Divider(),

          // About Section
          const ListTile(
            title: Text('About'),
            subtitle: Text('Grid Logic v1.0.1\nBy Heldig Lab'),
            leading: Icon(Icons.info),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text('Are you sure you want to reset all progress?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(gameStateProvider.notifier).resetGame();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress reset')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
