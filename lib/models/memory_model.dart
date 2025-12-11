class Memory {
  Memory({
    required this.location,
    required this.manufacturer,
    required this.memoryType,
    required this.clockSpeed,
    required this.size,
    required this.serialNumber,
    required this.partNumber,
    required this.formFactor,
  });

  final String? location;
  final String? manufacturer;
  final String? memoryType;
  final int? clockSpeed;
  final int? size;
  final String? serialNumber;
  final String? partNumber;
  final String? formFactor;

  Memory copyWith({
    String? location,
    String? manufacturer,
    String? memoryType,
    int? clockSpeed,
    int? size,
    String? serialNumber,
    String? partNumber,
    String? formFactor,
  }) {
    return Memory(
      location: location ?? this.location,
      manufacturer: manufacturer ?? this.manufacturer,
      memoryType: memoryType ?? this.memoryType,
      clockSpeed: clockSpeed ?? this.clockSpeed,
      size: size ?? this.size,
      serialNumber: serialNumber ?? this.serialNumber,
      partNumber: partNumber ?? this.partNumber,
      formFactor: formFactor ?? this.formFactor,
    );
  }

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      location: json["location"],
      manufacturer: json["manufacturer"],
      memoryType: json["memory_type"],
      clockSpeed: json["clock_speed"],
      size: json["size"],
      serialNumber: json["serial_number"],
      partNumber: json["part_number"],
      formFactor: json["form_factor"],
    );
  }

  Map<String, dynamic> toJson() => {
    "location": location,
    "manufacturer": manufacturer,
    "memory_type": memoryType,
    "clock_speed": clockSpeed,
    "size": size,
    "serial_number": serialNumber,
    "part_number": partNumber,
    "form_factor": formFactor,
  };
}
