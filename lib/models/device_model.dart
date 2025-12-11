import 'package:levelmate/models/cpu_model.dart';
import 'package:levelmate/models/disk_model.dart';
import 'package:levelmate/models/disk_partition_model.dart';
import 'package:levelmate/models/memory_model.dart';
import 'package:levelmate/models/network_model.dart';
import 'package:levelmate/models/os_model.dart';

/// Device roles in the Level RMM API.
/// The `workstation` role is used for devices that are not servers or domain controllers.
/// The `server` role is used for devices that are servers.
/// The `domainController` role is used for devices that are domain controllers.
enum DeviceRole { workstation, server, domainController }

extension DeviceRoleExtension on DeviceRole {
  static DeviceRole? fromString(String? value) {
    switch (value) {
      case 'workstation':
        return DeviceRole.workstation;
      case 'server':
        return DeviceRole.server;
      case 'domain_controller':
        return DeviceRole.domainController;
      default:
        return null;
    }
  }

  String toApiString() {
    switch (this) {
      case DeviceRole.workstation:
        return 'workstation';
      case DeviceRole.server:
        return 'server';
      case DeviceRole.domainController:
        return 'domain_controller';
    }
  }
}

/// Device platforms in the Level RMM API.
/// The `windows` platform is used for devices running Windows operating systems.
/// The `linux` platform is used for devices running Linux operating systems.
/// The `macos` platform is used for devices running macOS operating systems.
enum DevicePlatform { windows, linux, macos }

extension DevicePlatformExtension on DevicePlatform {
  static DevicePlatform? fromString(String? value) {
    switch (value) {
      case 'Windows':
        return DevicePlatform.windows;
      case 'Linux':
        return DevicePlatform.linux;
      case 'Mac':
        return DevicePlatform.macos;
      default:
        return null;
    }
  }

  String toApiString() {
    switch (this) {
      case DevicePlatform.windows:
        return 'windows';
      case DevicePlatform.linux:
        return 'linux';
      case DevicePlatform.macos:
        return 'macos';
    }
  }
}

/// A device in the Level RMM API.
/// Most of the fields are nullable because of Level's realtime nature. A device may be checking in and not have all the information yet.
/// The fields that are not nullable are the ones that are always present in the API response.
class Device {
  Device({
    required this.id,
    required this.hostname,
    required this.nickname,
    required this.role,
    required this.groupId,
    required this.tags,
    required this.flag,
    required this.maintenanceMode,
    required this.online,
    required this.notes,
    required this.manufacturer,
    required this.model,
    required this.architecture,
    required this.serialNumber,
    required this.totalMemory,
    required this.memorySlots,
    required this.cpuCores,
    required this.lastLoggedInUser,
    required this.lastRebootTime,
    required this.city,
    required this.country,
    required this.securityScore,
    required this.platform,
    required this.operatingSystem,
    required this.cpus,
    required this.memory,
    required this.disks,
    required this.diskPartitions,
    required this.networkInterfaces,
  });

  /// Unique identifier for the device
  final String id;

  /// Hostname of the device
  final String hostname;

  /// The nickname of the device, if any
  final String? nickname;

  /// The role of the device, if any
  final DeviceRole? role;

  /// The group it's assigned to, if any
  final String? groupId;

  /// The tags assigned to the device, if any
  final List<String> tags;

  /// Active flags on the device, if any
  final String? flag;

  /// Maintenance mode status of the device. If `true`, the device is in maintenance mode, otherwise `false`
  final bool maintenanceMode;

  /// Online status of the device. If `true`, the device is online, otherwise `false`
  final bool online;

  /// Additional notes about the device, if any
  final String? notes;

  /// The device manufacturer, if available
  final String? manufacturer;

  /// The device model, if available
  final String? model;

  /// The device architecture, if available
  final String? architecture;

  /// The device serial number, if available
  final String? serialNumber;

  /// The total amount of memory in the device, if available
  final int? totalMemory;

  /// The number of memory slots in the device, if available
  final int? memorySlots;

  /// The number of CPU cores in the device, if available
  final int? cpuCores;

  /// The last user who logged in to the device, if available
  final String? lastLoggedInUser;

  /// The last time the device was rebooted, if available
  final DateTime? lastRebootTime;

  /// The city where the device is located, if available
  final String? city;

  /// The country where the device is located, if available
  final String? country;

  /// The security score of the device, if available
  final int? securityScore;

  /// The platform of the device, if available
  final DevicePlatform? platform;

  /// Available only if `include_operating_system` is set to `true` in the request
  final OperatingSystem? operatingSystem;

  /// Available only if `include_cpus` is set to `true` in the request
  final List<CPUInfo>? cpus;

  /// Available only if `include_memory` is set to `true` in the request
  final List<Memory>? memory;

  /// Available only if `include_disks` is set to `true` in the request
  final List<Disk>? disks;

  /// Available only if `include_disk_partitions` is set to `true` in the request
  final List<DiskPartition>? diskPartitions;

  /// Available only if `include_network_interfaces` is set to `true` in the request
  final List<NetworkInterface>? networkInterfaces;

  Device copyWith({
    String? id,
    String? hostname,
    String? nickname,
    DeviceRole? role,
    String? groupId,
    List<String>? tags,
    String? flag,
    bool? maintenanceMode,
    bool? online,
    String? notes,
    String? manufacturer,
    String? model,
    String? architecture,
    String? serialNumber,
    int? totalMemory,
    int? memorySlots,
    int? cpuCores,
    String? lastLoggedInUser,
    DateTime? lastRebootTime,
    String? city,
    String? country,
    int? securityScore,
    DevicePlatform? platform,
    OperatingSystem? operatingSystem,
    List<CPUInfo>? cpus,
    List<Memory>? memory,
    List<Disk>? disks,
    List<DiskPartition>? diskPartitions,
    List<NetworkInterface>? networkInterfaces,
  }) {
    return Device(
      id: id ?? this.id,
      hostname: hostname ?? this.hostname,
      nickname: nickname ?? this.nickname,
      role: role ?? this.role,
      groupId: groupId ?? this.groupId,
      tags: tags ?? this.tags,
      flag: flag ?? this.flag,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      online: online ?? this.online,
      notes: notes ?? this.notes,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      architecture: architecture ?? this.architecture,
      serialNumber: serialNumber ?? this.serialNumber,
      totalMemory: totalMemory ?? this.totalMemory,
      memorySlots: memorySlots ?? this.memorySlots,
      cpuCores: cpuCores ?? this.cpuCores,
      lastLoggedInUser: lastLoggedInUser ?? this.lastLoggedInUser,
      lastRebootTime: lastRebootTime ?? this.lastRebootTime,
      city: city ?? this.city,
      country: country ?? this.country,
      securityScore: securityScore ?? this.securityScore,
      platform: platform ?? this.platform,
      operatingSystem: operatingSystem ?? this.operatingSystem,
      cpus: cpus ?? this.cpus,
      memory: memory ?? this.memory,
      disks: disks ?? this.disks,
      diskPartitions: diskPartitions ?? this.diskPartitions,
      networkInterfaces: networkInterfaces ?? this.networkInterfaces,
    );
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json["id"],
      hostname: json["hostname"],
      nickname: json["nickname"],
      role: DeviceRoleExtension.fromString(json["role"]),
      groupId: json["group_id"],
      tags: json["tags"] == null
          ? []
          : List<String>.from(json["tags"]!.map((x) => x)),
      flag: json["flag"],
      maintenanceMode: json["maintenance_mode"],
      online: json["online"],
      notes: json["notes"],
      manufacturer: json["manufacturer"],
      model: json["model"],
      architecture: json["architecture"],
      serialNumber: json["serial_number"],
      totalMemory: json["total_memory"],
      memorySlots: json["memory_slots"],
      cpuCores: json["cpu_cores"],
      lastLoggedInUser: json["last_logged_in_user"],
      lastRebootTime: DateTime.tryParse(json["last_reboot_time"] ?? ""),
      city: json["city"],
      country: json["country"],
      securityScore: json["security_score"],
      platform: DevicePlatformExtension.fromString(json["platform"]),
      operatingSystem: json["operating_system"] != null
          ? OperatingSystem.fromJson(json["operating_system"])
          : null,
      cpus: json["cpus"] != null
          ? List<CPUInfo>.from(json["cpus"].map((x) => CPUInfo.fromJson(x)))
          : null,
      memory: json["memory"] != null
          ? List<Memory>.from(json["memory"].map((x) => Memory.fromJson(x)))
          : null,
      disks: json["disks"] != null
          ? List<Disk>.from(json["disks"].map((x) => Disk.fromJson(x)))
          : null,
      diskPartitions: json["disk_partitions"] != null
          ? List<DiskPartition>.from(
              json["disk_partitions"].map((x) => DiskPartition.fromJson(x)),
            )
          : null,
      networkInterfaces: json["network_interfaces"] != null
          ? List<NetworkInterface>.from(
              json["network_interfaces"].map(
                (x) => NetworkInterface.fromJson(x),
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "hostname": hostname,
    "nickname": nickname,
    "role": role?.toApiString(),
    "group_id": groupId,
    "tags": tags.map((x) => x).toList(),
    "flag": flag,
    "maintenance_mode": maintenanceMode,
    "online": online,
    "notes": notes,
    "manufacturer": manufacturer,
    "model": model,
    "architecture": architecture,
    "serial_number": serialNumber,
    "total_memory": totalMemory,
    "memory_slots": memorySlots,
    "cpu_cores": cpuCores,
    "last_logged_in_user": lastLoggedInUser,
    "last_reboot_time": lastRebootTime?.toIso8601String(),
    "city": city,
    "country": country,
    "security_score": securityScore,
    "platform": platform?.toApiString(),
    "operating_system": operatingSystem?.toJson(),
    "cpus": cpus?.map((x) => x.toJson()).toList(),
    "memory": memory?.map((x) => x.toJson()).toList(),
    "disks": disks?.map((x) => x.toJson()).toList(),
    "disk_partitions": diskPartitions?.map((x) => x.toJson()).toList(),
    "network_interfaces": networkInterfaces?.map((x) => x.toJson()).toList(),
  };
}
