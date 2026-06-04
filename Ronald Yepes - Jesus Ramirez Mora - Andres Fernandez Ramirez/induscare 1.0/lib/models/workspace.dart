import 'device.dart';

class Workspace {
  final String id;
  String name;
  List<Device> devices;

  Workspace({
    required this.id,
    required this.name,
    List<Device>? devices,
  }) : devices = devices ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'devices': devices.map((d) => d.toJson()).toList(),
      };

  factory Workspace.fromJson(Map<String, dynamic> json) => Workspace(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      devices: ((json['devices'] as List<dynamic>?) ?? <dynamic>[])
      .whereType<Map<String, dynamic>>()
      .map(Device.fromJson)
    .toList()
      ..sort(Device.sortByType),
      );
}
