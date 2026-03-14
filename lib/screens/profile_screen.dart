import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Magnus Carlsen'),
            subtitle: Text('14 Mastered traps (24%)'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<String>(
              value: themeMode,
              items: const [
                DropdownMenuItem(value: 'system', child: Text('System')),
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(themeModeNotifierProvider.notifier).setThemeMode(val);
                }
              },
            ),
          ),
          const ListTile(
            title: Text('App Language'),
            trailing: Text('English'),
          ),
          const ListTile(
            title: Text('Open source license'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            title: Text('Packages that were used'),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          const ListTile(
            title: Text('Developer'),
            subtitle: Text('More info on me\nFacebook\nLinkedIn'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(onPressed: () {}, child: const Text('Edit Profile')),
                OutlinedButton(onPressed: () {}, child: const Text('Logout')),
              ],
            ),
          )
        ],
      ),
    );
  }
}
