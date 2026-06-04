import 'package:flutter_test/flutter_test.dart';
import 'package:induscare/models/device.dart';
import 'package:induscare/models/workspace.dart';
import 'package:induscare/models/user.dart';

void main() {
  group('Device Model', () {
    test('Device status is green when maintained recently', () {
      final device = Device(
        type: DeviceType.pc,
        ownerName: 'Alice',
        maintenanceDate: DateTime.now(),
      );
      expect(device.statusLevel, 0);
    });

    test('Device status is yellow when 5 months old', () {
      final device = Device(
        type: DeviceType.laptop,
        ownerName: 'Bob',
        maintenanceDate: DateTime.now().subtract(const Duration(days: 150)),
      );
      expect(device.statusLevel, 1);
    });

    test('Device status is red when 10 months old', () {
      final device = Device(
        type: DeviceType.phone,
        ownerName: 'Carla',
        maintenanceDate: DateTime.now().subtract(const Duration(days: 300)),
      );
      expect(device.statusLevel, 2);
    });

    test('Device serializes to JSON and back', () {
      final device = Device(
        type: DeviceType.pc,
        ownerName: 'My Owner',
        phoneNumber: null,
        maintenanceDate: DateTime(2024, 1, 15),
      );
      final json = device.toJson();
      final restored = Device.fromJson(json);
      expect(restored.ownerName, device.ownerName);
      expect(restored.type, device.type);
    });

    test('Device supports legacy JSON migration from name field', () {
      final restored = Device.fromJson({
        'id': 'legacy-1',
        'type': 'phone',
        'name': 'Legacy Owner',
        'maintenanceDate': DateTime(2024, 2, 2).toIso8601String(),
      });
      expect(restored.ownerName, 'Legacy Owner');
      expect(restored.type, DeviceType.phone);
    });
  });

  group('Workspace Model', () {
    test('Workspace starts with empty devices', () {
      final ws = Workspace(id: '1', name: 'Test WS');
      expect(ws.devices, isEmpty);
    });

    test('Workspace serializes to JSON and back', () {
      final ws = Workspace(id: 'ws1', name: 'Office');
      final json = ws.toJson();
      final restored = Workspace.fromJson(json);
      expect(restored.id, ws.id);
      expect(restored.name, ws.name);
    });
  });

  group('User Model', () {
    test('User serializes to JSON and back', () {
      final user = User(name: 'John');
      final json = user.toJson();
      final restored = User.fromJson(json);
      expect(restored.name, user.name);
    });
  });
}
