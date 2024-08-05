import 'package:aglora_client/screens/widgets/widget_scan_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../utils/bluetooth.dart';
import 'screen_device.dart';
import 'widgets/widget_connected_device_tile.dart';

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find AGLORA tracker'),
//        backgroundColor: Colors.purple,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBluePlus.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                  stream: Stream.periodic(Duration(seconds: 2))
                      .asyncMap((_) => FlutterBluePlus.connectedDevices),
                  initialData: [],
                  builder: (c, snapshot) => Column(
                        children: snapshot.data!
                            .map((d) => ConnectedDeviceTile(d: d))
                            .toList(),
                      )),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            r.device.connect();
                            r.device.discoverServices();
                            startBluetoothListener(r.device);
                            return DeviceScreen(device: r.device);
                          })),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBluePlus.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBluePlus.stopScan(),
              backgroundColor: Colors.red.shade100,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () =>
                    FlutterBluePlus.startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}
