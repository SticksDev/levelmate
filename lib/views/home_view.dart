import 'package:flutter/material.dart';
import '../controllers/device_controller.dart';
import '../models/device_model.dart';
import '../services/api_service.dart';
import 'device_detail_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.controller, required this.apiService});

  final DeviceController controller;
  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LevelMate'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (controller.isLoading && controller.devices.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null && controller.devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: controller.refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.devices_other,
                    size: 64,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Devices',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No devices found in your Level RMM account.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: controller.devices.length,
              itemBuilder: (context, index) {
                final device = controller.devices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeviceDetailView(
                            device: device,
                            apiService: apiService,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: device.online
                          ? Colors.green.withValues(alpha: 0.2)
                          : colorScheme.surfaceContainerHighest,
                      child: Icon(
                        _getPlatformIcon(device.platform),
                        color: device.online
                            ? Colors.green
                            : colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    title: Text(
                      device.nickname ?? device.hostname,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          device.operatingSystem?.fullOperatingSystem ??
                              'Unknown OS',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (device.manufacturer != null)
                          Text(
                            '${device.manufacturer} ${device.model ?? ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: device.online
                                ? Colors.green.withValues(alpha: 0.2)
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            device.online ? 'Online' : 'Offline',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: device.online
                                  ? Colors.green
                                  : colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getPlatformIcon(DevicePlatform? platform) {
    switch (platform) {
      case DevicePlatform.windows:
        return Icons.desktop_windows;
      case DevicePlatform.linux:
        return Icons.terminal;
      case DevicePlatform.macos:
        return Icons.laptop_mac;
      case null:
        return Icons.device_unknown;
    }
  }
}
