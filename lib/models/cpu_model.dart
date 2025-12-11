class CPUInfo {
  CPUInfo({required this.model, required this.clockSpeed, required this.cores});

  final String? model;
  final int? clockSpeed;
  final int? cores;

  CPUInfo copyWith({String? model, int? clockSpeed, int? cores}) {
    return CPUInfo(
      model: model ?? this.model,
      clockSpeed: clockSpeed ?? this.clockSpeed,
      cores: cores ?? this.cores,
    );
  }

  factory CPUInfo.fromJson(Map<String, dynamic> json) {
    return CPUInfo(
      model: json["model"],
      clockSpeed: json["clock_speed"],
      cores: json["cores"],
    );
  }

  Map<String, dynamic> toJson() => {
    "model": model,
    "clock_speed": clockSpeed,
    "cores": cores,
  };
}
