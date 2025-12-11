import 'package:levelmate/models/device_model.dart';

class DeviceResponse {
  List<Device> devices;
  bool hasMore;

  DeviceResponse({required this.devices, required this.hasMore});

  factory DeviceResponse.fromJson(Map<String, dynamic> json) {
    List<Device> devicesList = (json['data'] as List)
        .map((deviceJson) => Device.fromJson(deviceJson))
        .toList();

    return DeviceResponse(devices: devicesList, hasMore: json['has_more']);
  }
}
