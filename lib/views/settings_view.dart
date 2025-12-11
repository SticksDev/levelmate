import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/storage_service.dart';

class SettingsView extends StatefulWidget {
  final StorageService storageService;

  const SettingsView({super.key, required this.storageService});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  PackageInfo? _packageInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _clearToken() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Token'),
        content: const Text(
          'Are you sure you want to clear your API token? You will need to sign in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      await widget.storageService.clearToken();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Account Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Account',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Clear API Token'),
            subtitle: const Text('Sign out and remove stored token'),
            enabled: !_isLoading,
            onTap: _clearToken,
          ),

          const Divider(),

          // Version Info Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Version Information',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_packageInfo != null) ...[
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App Version'),
              subtitle: Text('${_packageInfo!.version}+${_packageInfo!.buildNumber}'),
            ),
            ListTile(
              leading: const Icon(Icons.commit),
              title: const Text('Build'),
              subtitle: Text(_packageInfo!.buildNumber),
            ),
          ],
          ListTile(
            leading: const Icon(Icons.flutter_dash),
            title: const Text('Flutter Version'),
            subtitle: FutureBuilder<String>(
              future: _getFlutterVersion(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!);
                }
                return const Text('Loading...');
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Dart Version'),
            subtitle: Text(Platform.version.split(' ').first),
          ),

          const Divider(),

          // About Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'About',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.device_hub),
            title: const Text('LevelMate'),
            subtitle: const Text('Level RMM device management'),
          ),
        ],
      ),
    );
  }

  Future<String> _getFlutterVersion() async {
    try {
      final result = await Process.run('flutter', ['--version']);
      final output = result.stdout.toString();
      final lines = output.split('\n');
      if (lines.isNotEmpty) {
        return lines[0].replaceAll('Flutter ', '');
      }
    } catch (e) {
      // Flutter command not available
    }
    return 'Unknown';
  }
}
