import 'package:aglora_client/utils/bluetooth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../aglora/data.dart';
import '../utils/saved_parameters.dart';
import 'widgets/widget_lora_tracker_tile.dart';
import 'widgets/widget_use_compass.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  @override
  void initState() {
    super.initState();
    connectToDevice(widget.device);
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      startBluetoothListener(device);
    } catch (e) {
      print(e);
    }
  }

  Widget _buildTrackersTiles(List<AGLORATrackerPoint> _trackersDataList) {
    return Column(
      children: _trackersDataList
          .map((e) => LORAtrackerTile(
              time: e.time,
              lat: e.latitude,
              lon: e.longitude,
              identifier: e.identifier,
              sensors: e.sensors,
              useCompass: useCompass))
          .toList(),
    );
    //return Text('Not AGLORA data.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.device.platformName),
          actions: <Widget>[
            StreamBuilder<BluetoothConnectionState>(
              stream: widget.device.connectionState,
              initialData: BluetoothConnectionState.connecting,
              builder: (c, snapshot) {
                VoidCallback? onPressed;
                String text;
                switch (snapshot.data) {
                  case BluetoothConnectionState.connecting:
                    text = 'waiting...';
                    break;
                  case BluetoothConnectionState.disconnecting:
                    text = 'disconnecting...';
                    break;
                  case BluetoothConnectionState.connected:
                    onPressed = () => widget.device.disconnect();
                    text = 'Disconnect';
                    widget.device.discoverServices();
                    break;
                  case BluetoothConnectionState.disconnected:
                    onPressed = () => widget.device.connect();
                    text = 'Connect';
                    break;
                  default:
                    onPressed = null;
                    text = snapshot.data.toString().substring(21).toUpperCase();
                    break;
                }
                return Row(
                  children: [
                    OutlinedButton(
                        onPressed: onPressed,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          text,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelLarge
                              ?.copyWith(color: Colors.white),
                        )),
                    SizedBox(width: 10),
                    bluetoothStatusIcon(device: widget.device),
                    SizedBox(width: 10),
                  ],
                );
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<List<AGLORATrackerPoint>>(
                stream: trackersListStream,
                initialData: [],
                builder: (c, snapshot) {
                  print('BLE RECIVED :${snapshot.data}');
                  return _buildTrackersTiles(snapshot.data!);
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: WidgetUseCompass(),
        ));
  }
}

class discoveringServicesIcon extends StatelessWidget {
  const discoveringServicesIcon({
    Key? key,
    required this.device,
  }) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: device.isDiscoveringServices,
      initialData: false,
      builder: (c, snapshot) => IndexedStack(
        index: snapshot.data! ? 1 : 0,
        children: <Widget>[
          Icon(Icons.account_tree),
          SizedBox(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey),
            ),
            width: 18.0,
            height: 18.0,
          ),
        ],
      ),
    );
  }
}

class bluetoothStatusIcon extends StatelessWidget {
  const bluetoothStatusIcon({
    Key? key,
    required this.device,
  }) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothConnectionState>(
      stream: device.connectionState,
      initialData: BluetoothConnectionState.connecting,
      builder: (c, snapshot) =>
          (snapshot.data == BluetoothConnectionState.connected)
              ? Icon(CupertinoIcons.bluetooth,
                  color: Colors.lightGreenAccent.shade100)
              : Icon(Icons.bluetooth_disabled, color: Colors.redAccent),
    );
  }
}
