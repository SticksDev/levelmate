import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../models/disk_model.dart';
import '../models/disk_partition_model.dart';
import '../models/memory_model.dart';
import '../models/network_model.dart';
import '../services/api_service.dart';
import '../services/logger_service.dart';

class DeviceDetailView extends StatefulWidget {
  const DeviceDetailView({
    super.key,
    required this.device,
    required this.apiService,
  });

  final Device device;
  final ApiService apiService;

  @override
  State<DeviceDetailView> createState() => _DeviceDetailViewState();
}

class _DeviceDetailViewState extends State<DeviceDetailView> {
  final _logger = LoggerService('DeviceDetailView');
  Device? _fullDevice;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDeviceDetails();
  }

  Future<void> _fetchDeviceDetails() async {
    _logger.info('Fetching full details for device ${widget.device.id}');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final device = await widget.apiService.getDevice(widget.device.id);
      setState(() {
        _fullDevice = device;
        _isLoading = false;
      });
      _logger.info('Device details loaded successfully');
    } catch (e) {
      _logger.error('Failed to fetch device details', e);
      setState(() {
        _errorMessage = 'Failed to load device details: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final device = _fullDevice ?? widget.device;

    return Scaffold(
      appBar: AppBar(
        title: Text(device.nickname ?? device.hostname),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDeviceDetails,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
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
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _fetchDeviceDetails,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DeviceHeader(device: device),
                const SizedBox(height: 24),
                _InfoSection(
                  title: 'General Information',
                  icon: Icons.info_outline,
                  children: [
                    _InfoRow('Hostname', device.hostname),
                    if (device.role != null)
                      _InfoRow('Role', _formatRole(device.role!)),
                    if (device.maintenanceMode)
                      _InfoRow(
                        'Maintenance Mode',
                        'Yes',
                        valueColor: Colors.orange,
                      ),
                    if (device.flag != null) _InfoRow('Flag', device.flag!),
                  ],
                ),
                const SizedBox(height: 16),
                if (device.operatingSystem != null)
                  _InfoSection(
                    title: 'Operating System',
                    icon: Icons.desktop_windows,
                    children: [
                      _InfoRow(
                        'Name',
                        device.operatingSystem!.fullOperatingSystem ??
                            'Unknown',
                      ),
                      if (device.operatingSystem!.majorVersion != null)
                        _InfoRow(
                          'Major Version',
                          device.operatingSystem!.majorVersion!,
                        ),
                      if (device.operatingSystem!.minorVersion != null)
                        _InfoRow(
                          'Minor Version',
                          device.operatingSystem!.minorVersion!,
                        ),
                      if (device.operatingSystem!.architecture != null)
                        _InfoRow(
                          'Architecture',
                          device.operatingSystem!.architecture!,
                        ),
                      if (device.operatingSystem!.installDate != null)
                        _InfoRow(
                          'Install Date',
                          _formatDate(device.operatingSystem!.installDate!),
                        ),
                      if (device.operatingSystem!.endOfLife != null)
                        _InfoRow(
                          'End of Life',
                          device.operatingSystem!.endOfLife! ? 'Yes' : 'No',
                          valueColor: device.operatingSystem!.endOfLife!
                              ? Colors.red
                              : Colors.green,
                        ),
                    ],
                  ),
                const SizedBox(height: 16),
                _InfoSection(
                  title: 'Hardware',
                  icon: Icons.memory,
                  children: [
                    if (device.manufacturer != null)
                      _InfoRow('Manufacturer', device.manufacturer!),
                    if (device.model != null) _InfoRow('Model', device.model!),
                    if (device.architecture != null)
                      _InfoRow('Architecture', device.architecture!),
                    if (device.serialNumber != null)
                      _InfoRow('Serial Number', device.serialNumber!),
                    if (device.cpuCores != null)
                      _InfoRow('CPU Cores', '${device.cpuCores}'),
                    if (device.totalMemory != null)
                      _InfoRow(
                        'Total Memory',
                        _formatMemory(device.totalMemory!),
                      ),
                    if (device.memorySlots != null)
                      _InfoRow('Memory Slots', '${device.memorySlots}'),
                  ],
                ),
                if (device.cpus != null && device.cpus!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _InfoSection(
                    title: 'CPUs',
                    icon: Icons.developer_board,
                    children: [
                      _InfoRow('Count', '${device.cpus!.length}'),
                      if (device.cpus!.isNotEmpty &&
                          device.cpus!.first.model != null)
                        _InfoRow('Model', device.cpus!.first.model!),
                      if (device.cpus!.isNotEmpty &&
                          device.cpus!.first.cores != null)
                        _InfoRow(
                          'Cores per CPU',
                          '${device.cpus!.first.cores}',
                        ),
                      if (device.cpus!.isNotEmpty &&
                          device.cpus!.first.clockSpeed != null)
                        _InfoRow(
                          'Clock Speed',
                          '${device.cpus!.first.clockSpeed} MHz',
                        ),
                    ],
                  ),
                ],
                if (device.memory != null && device.memory!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _InfoSection(
                    title: 'Memory Modules',
                    icon: Icons.memory,
                    children: [
                      _MemorySlotUI(
                        memory: device.memory!,
                        totalSlots: device.memorySlots ?? device.memory!.length,
                      ),
                    ],
                  ),
                ],
                if (device.disks != null && device.disks!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _InfoSection(
                    title: 'Disks',
                    icon: Icons.storage,
                    children: device.disks!
                        .map((disk) => _DiskItem(disk: disk))
                        .toList(),
                  ),
                ],
                if (device.diskPartitions != null &&
                    device.diskPartitions!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _InfoSection(
                    title: 'Disk Partitions',
                    icon: Icons.pie_chart,
                    children: [
                      _DiskPartitionChart(partitions: device.diskPartitions!),
                    ],
                  ),
                ],
                if (device.networkInterfaces != null &&
                    device.networkInterfaces!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _InfoSection(
                    title: 'Network Interfaces',
                    icon: Icons.network_check,
                    children: device.networkInterfaces!
                        .map((network) => _NetworkInterfaceItem(network: network))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),
                _InfoSection(
                  title: 'Location',
                  icon: Icons.location_on,
                  children: [
                    if (device.city != null) _InfoRow('City', device.city!),
                    if (device.country != null)
                      _InfoRow('Country', device.country!),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoSection(
                  title: 'Activity',
                  icon: Icons.history,
                  children: [
                    if (device.lastLoggedInUser != null)
                      _InfoRow('Last Logged In User', device.lastLoggedInUser!),
                    if (device.lastRebootTime != null)
                      _InfoRow(
                        'Last Reboot',
                        _formatDateTime(device.lastRebootTime!),
                      ),
                  ],
                ),
                if (device.notes != null && device.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _InfoSection(
                    title: 'Notes',
                    icon: Icons.note,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(device.notes!),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  String _formatRole(DeviceRole role) {
    switch (role) {
      case DeviceRole.workstation:
        return 'Workstation';
      case DeviceRole.server:
        return 'Server';
      case DeviceRole.domainController:
        return 'Domain Controller';
    }
  }

  String _formatMemory(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
    }
    if (bytes < 1024 * 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
    }
    return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(2)}TB';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DeviceHeader extends StatelessWidget {
  const _DeviceHeader({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: device.online
                        ? Colors.green.withValues(alpha: 0.2)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getPlatformIcon(device.platform),
                    size: 48,
                    color: device.online
                        ? Colors.green
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              device.hostname,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: device.online
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              device.online ? 'Online' : 'Offline',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: device.online
                                    ? Colors.green
                                    : colorScheme.onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        device.operatingSystem?.fullOperatingSystem ?? 'Unknown OS',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      if (device.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: device.tags
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTagColor(tag, colorScheme),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tag,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (device.securityScore != null) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _SecurityScoreGauge(score: device.securityScore!),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTagColor(String tag, ColorScheme colorScheme) {
    final hash = tag.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
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

class _SecurityScoreGauge extends StatelessWidget {
  const _SecurityScoreGauge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getScoreColor(score);

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.security, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              'Security Score',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '$score/100',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: CustomPaint(
            size: const Size(double.infinity, 120),
            painter: _GaugePainter(score: score, color: color),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final radius = math.min(size.width / 2, size.height - 10) - 10;

    // Background arc
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Foreground arc (progress)
    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      foregroundPaint,
    );

    // Draw score markers
    final markerPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i <= 10; i++) {
      final angle = math.pi + (i / 10) * math.pi;
      final innerRadius = radius - 10;
      final outerRadius = radius + 10;

      final startX = center.dx + innerRadius * math.cos(angle);
      final startY = center.dy + innerRadius * math.sin(angle);
      final endX = center.dx + outerRadius * math.cos(angle);
      final endY = center.dy + outerRadius * math.sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        markerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiskPartitionChart extends StatelessWidget {
  const _DiskPartitionChart({required this.partitions});

  final List<DiskPartition> partitions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate total used and free space
    int totalSize = 0;
    int totalUsed = 0;
    for (final partition in partitions) {
      totalSize += partition.size ?? 0;
      final used = (partition.size ?? 0) - (partition.freeSpace ?? 0);
      totalUsed += used;
    }

    final totalFree = totalSize - totalUsed;
    final usedPercentage = totalSize > 0
        ? (totalUsed / totalSize * 100).toStringAsFixed(1)
        : '0';
    final freePercentage = totalSize > 0
        ? (totalFree / totalSize * 100).toStringAsFixed(1)
        : '0';

    // Generate colors for each partition
    final partitionColors = _generatePartitionColors(
      partitions.length,
      colorScheme,
    );

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: CustomPaint(
            size: const Size(200, 200),
            painter: _MultiPartitionPieChartPainter(
              partitions: partitions,
              colors: partitionColors,
              freeColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            // Overall stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total: ${_formatBytes(totalSize)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Used: $usedPercentage%',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                Text(
                  'Free: $freePercentage%',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            // Individual partitions
            ...partitions.asMap().entries.map((entry) {
              final index = entry.key;
              final partition = entry.value;
              final size = partition.size ?? 0;
              final used = size - (partition.freeSpace ?? 0);
              final percentage = size > 0
                  ? (used / size * 100).toStringAsFixed(1)
                  : '0';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: partitionColors[index],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        partition.label ?? partition.mountPoint ?? 'Unknown',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${_formatBytes(size)} ($percentage% used)',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }),
            // Free space row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Free',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${_formatBytes(totalFree)} ($freePercentage% free)',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Color> _generatePartitionColors(int count, ColorScheme colorScheme) {
    if (count == 0) return [];

    final hslColor = HSLColor.fromColor(colorScheme.primary);
    final colors = <Color>[];

    for (int i = 0; i < count; i++) {
      final hue = (hslColor.hue + (i * 360 / count)) % 360;
      colors.add(HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor());
    }

    return colors;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
    }
    if (bytes < 1024 * 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
    }
    return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(2)}TB';
  }
}

class _MultiPartitionPieChartPainter extends CustomPainter {
  _MultiPartitionPieChartPainter({
    required this.partitions,
    required this.colors,
    required this.freeColor,
  });

  final List<DiskPartition> partitions;
  final List<Color> colors;
  final Color freeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Calculate total size and used space per partition
    int totalSize = 0;
    final List<int> usedSizes = [];

    for (final partition in partitions) {
      final size = partition.size ?? 0;
      final used = size - (partition.freeSpace ?? 0);
      totalSize += size;
      usedSizes.add(used);
    }

    if (totalSize == 0) {
      // Draw empty circle if no data
      final paint = Paint()
        ..color = freeColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    double currentAngle = -math.pi / 2;

    // Draw each partition's used space
    for (int i = 0; i < partitions.length; i++) {
      final usedSpace = usedSizes[i];
      final sweepAngle = (usedSpace / totalSize) * 2 * math.pi;

      if (sweepAngle > 0) {
        final paint = Paint()
          ..color = colors[i]
          ..style = PaintingStyle.fill;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          currentAngle,
          sweepAngle,
          true,
          paint,
        );

        currentAngle += sweepAngle;
      }
    }

    // Calculate total free space
    final totalUsed = usedSizes.fold<int>(0, (sum, size) => sum + size);
    final totalFree = totalSize - totalUsed;

    // Draw free space
    if (totalFree > 0) {
      final freeSweepAngle = (totalFree / totalSize) * 2 * math.pi;
      final freePaint = Paint()
        ..color = freeColor
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        freeSweepAngle,
        true,
        freePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MultiPartitionPieChartPainter oldDelegate) {
    return oldDelegate.partitions != partitions ||
        oldDelegate.colors != colors ||
        oldDelegate.freeColor != freeColor;
  }
}

class _MemorySlotUI extends StatelessWidget {
  const _MemorySlotUI({
    required this.memory,
    required this.totalSlots,
  });

  final List<Memory> memory;
  final int totalSlots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter out empty or unknown memory modules
    final validMemory = memory.where((m) => m.size != null && m.size! > 0).toList();

    final totalCapacity = validMemory.fold<int>(0, (sum, m) => sum + (m.size ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${_formatMemory(totalCapacity)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${validMemory.length}/$totalSlots slots used',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.7,
          ),
          itemCount: totalSlots,
          itemBuilder: (context, index) {
            final hasMemory = index < validMemory.length;
            final mem = hasMemory ? validMemory[index] : null;

            return Container(
              decoration: BoxDecoration(
                color: hasMemory
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasMemory
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasMemory ? Icons.memory : Icons.memory_outlined,
                    color: hasMemory
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  if (hasMemory && mem != null) ...[
                    Text(
                      _formatMemory(mem.size ?? 0),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (mem.clockSpeed != null)
                      Text(
                        '${mem.clockSpeed}MHz',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                        ),
                      ),
                  ] else
                    Text(
                      'Empty',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        if (validMemory.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          ...validMemory.map((mem) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        mem.manufacturer ?? 'Unknown',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${mem.memoryType ?? 'Unknown'} - ${_formatMemory(mem.size ?? 0)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  String _formatMemory(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
  }
}

class _DiskItem extends StatelessWidget {
  const _DiskItem({required this.disk});

  final Disk disk;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getDiskTypeIcon(disk.diskType),
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    disk.model ?? 'Unknown Disk',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatBytes(disk.size ?? 0),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (disk.diskType != null) ...[
                  _DetailChip(
                    label: 'Type',
                    value: disk.diskType!,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 8),
                ],
                if (disk.serialNumber != null)
                  _DetailChip(
                    label: 'S/N',
                    value: disk.serialNumber!,
                    colorScheme: colorScheme,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDiskTypeIcon(String? diskType) {
    if (diskType == null) return Icons.storage;
    if (diskType.toLowerCase().contains('ssd')) return Icons.memory;
    if (diskType.toLowerCase().contains('hdd')) return Icons.album;
    return Icons.storage;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
    }
    if (bytes < 1024 * 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
    }
    return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(2)}TB';
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  final String label;
  final String value;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 11,
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _NetworkInterfaceItem extends StatelessWidget {
  const _NetworkInterfaceItem({required this.network});

  final NetworkInterface network;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.network_check,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    network.label ?? network.description ?? 'Unknown Interface',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (network.macAddress != null)
              _NetworkDetailRow(
                icon: Icons.perm_device_info,
                label: 'MAC',
                value: network.macAddress!,
                colorScheme: colorScheme,
                theme: theme,
              ),
            if (network.ipAddresses.isNotEmpty)
              _NetworkDetailRow(
                icon: Icons.language,
                label: 'IP Address',
                value: network.ipAddresses.join(', '),
                colorScheme: colorScheme,
                theme: theme,
              ),
            if (network.gateway != null)
              _NetworkDetailRow(
                icon: Icons.router,
                label: 'Gateway',
                value: network.gateway!,
                colorScheme: colorScheme,
                theme: theme,
              ),
          ],
        ),
      ),
    );
  }
}

class _NetworkDetailRow extends StatelessWidget {
  const _NetworkDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 6),
          Text(
            '$label:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
