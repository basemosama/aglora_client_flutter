import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../aglora/aglora.dart';
import '../aglora/data.dart';

void startBluetoothListener(BluetoothDevice device) {
  try {
    device.connectionState.listen((status) {
      if (status == BluetoothConnectionState.connected) {
        if (kDebugMode) print('Request history');
        checkServices(device);
      }
    });
    if (device.isConnected) {
      checkServices(device);
    }
  } catch (e) {
    print(e);
  }
}

Future<void> checkServices(BluetoothDevice device) async {
  final services = await device.discoverServices();
  BluetoothService? agloraService;
  services.forEach((service) {
    if (service.uuid.toString().startsWith("0000ffa2") ||
        service.uuid.toString().startsWith("0000ffe0") ||
        service.uuid.toString().startsWith("ffa2") ||
        service.uuid.toString().startsWith("ffe0")) {
      agloraService = service;
    }
  });

  if (agloraService != null) {
    var characteristics = agloraService!.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      if (c.uuid.toString().startsWith("0000ffe1") ||
          c.uuid.toString().startsWith("ffe1")) {
        c.setNotifyValue(true);
        c.read();

        List<int> request = requestAllTrackers.codeUnits;
        c.write(request, withoutResponse: true);

        c.onValueReceived.listen((value) {
          newDataReceiver(value);
        });
      }
    }
  }
}
