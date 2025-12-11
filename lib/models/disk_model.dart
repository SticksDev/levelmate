class Disk {
  Disk({
    required this.diskType,
    required this.model,
    required this.serialNumber,
    required this.size,
  });

  final String? diskType;
  final String? model;
  final String? serialNumber;
  final int? size;

  Disk copyWith({
    String? diskType,
    String? model,
    String? serialNumber,
    int? size,
  }) {
    return Disk(
      diskType: diskType ?? this.diskType,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      size: size ?? this.size,
    );
  }

  factory Disk.fromJson(Map<String, dynamic> json) {
    return Disk(
      diskType: json["disk_type"],
      model: json["model"],
      serialNumber: json["serial_number"],
      size: json["size"],
    );
  }

  Map<String, dynamic> toJson() => {
    "disk_type": diskType,
    "model": model,
    "serial_number": serialNumber,
    "size": size,
  };
}
