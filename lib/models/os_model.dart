class OperatingSystem {
  OperatingSystem({
    required this.fullOperatingSystem,
    required this.majorVersion,
    required this.minorVersion,
    required this.architecture,
    required this.installDate,
    required this.endOfLife,
  });

  final String? fullOperatingSystem;
  final String? majorVersion;
  final String? minorVersion;
  final String? architecture;
  final DateTime? installDate;
  final bool? endOfLife;

  OperatingSystem copyWith({
    String? fullOperatingSystem,
    String? majorVersion,
    String? minorVersion,
    String? architecture,
    DateTime? installDate,
    bool? endOfLife,
  }) {
    return OperatingSystem(
      fullOperatingSystem: fullOperatingSystem ?? this.fullOperatingSystem,
      majorVersion: majorVersion ?? this.majorVersion,
      minorVersion: minorVersion ?? this.minorVersion,
      architecture: architecture ?? this.architecture,
      installDate: installDate ?? this.installDate,
      endOfLife: endOfLife ?? this.endOfLife,
    );
  }

  factory OperatingSystem.fromJson(Map<String, dynamic> json) {
    return OperatingSystem(
      fullOperatingSystem: json["full_operating_system"],
      majorVersion: json["major_version"],
      minorVersion: json["minor_version"],
      architecture: json["architecture"],
      installDate: DateTime.tryParse(json["install_date"] ?? ""),
      endOfLife: json["end_of_life"],
    );
  }

  Map<String, dynamic> toJson() => {
    "full_operating_system": fullOperatingSystem,
    "major_version": majorVersion,
    "minor_version": minorVersion,
    "architecture": architecture,
    "install_date": installDate?.toIso8601String(),
    "end_of_life": endOfLife,
  };
}
