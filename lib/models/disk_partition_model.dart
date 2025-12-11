class DiskPartition {
  DiskPartition({
    required this.label,
    required this.mountPoint,
    required this.encrypted,
    required this.primary,
    required this.size,
    required this.freeSpace,
    required this.fileSystem,
  });

  final String? label;
  final String? mountPoint;
  final bool? encrypted;
  final bool? primary;
  final int? size;
  final int? freeSpace;
  final String? fileSystem;

  DiskPartition copyWith({
    String? label,
    String? mountPoint,
    bool? encrypted,
    bool? primary,
    int? size,
    int? freeSpace,
    String? fileSystem,
  }) {
    return DiskPartition(
      label: label ?? this.label,
      mountPoint: mountPoint ?? this.mountPoint,
      encrypted: encrypted ?? this.encrypted,
      primary: primary ?? this.primary,
      size: size ?? this.size,
      freeSpace: freeSpace ?? this.freeSpace,
      fileSystem: fileSystem ?? this.fileSystem,
    );
  }

  factory DiskPartition.fromJson(Map<String, dynamic> json) {
    return DiskPartition(
      label: json["label"],
      mountPoint: json["mount_point"],
      encrypted: json["encrypted"],
      primary: json["primary"],
      size: json["size"],
      freeSpace: json["free_space"],
      fileSystem: json["file_system"],
    );
  }

  Map<String, dynamic> toJson() => {
    "label": label,
    "mount_point": mountPoint,
    "encrypted": encrypted,
    "primary": primary,
    "size": size,
    "free_space": freeSpace,
    "file_system": fileSystem,
  };
}
