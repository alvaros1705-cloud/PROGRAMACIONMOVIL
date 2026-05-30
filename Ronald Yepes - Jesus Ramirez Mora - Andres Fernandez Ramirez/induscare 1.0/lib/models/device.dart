import 'package:uuid/uuid.dart';

enum DeviceType { pc, laptop, phone }

class Device {
  final String id;
  final DeviceType type;
  String ownerName;
  String? phoneNumber;
  DateTime maintenanceDate;

  Device({
    String? id,
    required this.type,
    required String ownerName,
    this.phoneNumber,
    DateTime? maintenanceDate,
  })  : id = id ?? const Uuid().v4(),
        ownerName = ownerName.trim(),
        maintenanceDate = maintenanceDate ?? DateTime.now();

  // Status: 0=green(0-3mo), 1=yellow(3-9mo), 2=red(9+mo)
  // Note: uses 30-day month approximation for simplicity.
  int get statusLevel {
    final months = DateTime.now().difference(maintenanceDate).inDays / 30;
    if (months <= 3) return 0;
    if (months <= 9) return 1;
    return 2;
  }

  /// Resets the maintenance date to today.
  void resetMaintenance() {
    maintenanceDate = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'ownerName': ownerName,
        'phoneNumber': phoneNumber,
        'maintenanceDate': maintenanceDate.toIso8601String(),
      };

  // Strict sort order required by product rules: PCs, Laptops, Phones.
  static int sortByType(Device a, Device b) {
    return _typeOrder(a.type).compareTo(_typeOrder(b.type));
  }

  static int _typeOrder(DeviceType type) {
    switch (type) {
      case DeviceType.pc:
        return 0;
      case DeviceType.laptop:
        return 1;
      case DeviceType.phone:
        return 2;
    }
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    final ownerFromJson = (json['ownerName'] as String?)?.trim();
    // Backward compatibility: older payloads used `name` for user-entered value.
    final ownerFromLegacyName = (json['name'] as String?)?.trim();
    final ownerName = (ownerFromJson?.isNotEmpty == true)
        ? ownerFromJson!
        : (ownerFromLegacyName?.isNotEmpty == true)
            ? ownerFromLegacyName!
            : 'Unknown';

    return Device(
      id: json['id'],
      type: DeviceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DeviceType.pc,
      ),
      ownerName: ownerName,
      phoneNumber: json['phoneNumber'] as String?,
      maintenanceDate: DateTime.tryParse(
            (json['maintenanceDate'] as String?) ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
