import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils.dart';
import '../provider/settings_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String themeMode = ref.watch(themeModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.phrase.profile)),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Magnus Carlsen'),
            subtitle: Text(context.phrase.masteredTraps(14, 24)),
          ),
          const Divider(),
          ListTile(
            title: Text(context.phrase.theme),
            trailing: DropdownButton<String>(
              value: themeMode,
              items: [
                DropdownMenuItem(value: 'system', child: Text(context.phrase.system)),
                DropdownMenuItem(value: 'light', child: Text(context.phrase.light)),
                DropdownMenuItem(value: 'dark', child: Text(context.phrase.dark)),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(themeModeNotifierProvider.notifier).setThemeMode(val);
                }
              },
            ),
          ),
          ListTile(title: Text(context.phrase.appLanguage), trailing: Text(context.phrase.english)),
          ListTile(
            title: Text(context.phrase.openSourceLicense),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showLicensePage(context: context);
            },
          ),
          ListTile(
            title: Text(context.phrase.usedPackages),
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(),
          ListTile(
            title: Text(context.phrase.developer),
            subtitle: const Text('More info on me\nFacebook\nLinkedIn'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(onPressed: () {}, child: Text(context.phrase.editProfile)),
                OutlinedButton(onPressed: () {}, child: Text(context.phrase.logout)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
