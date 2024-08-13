import 'dart:async';

class AGLoRaSensor {
  AGLoRaSensor({required this.name, required this.value});

  String name;
  String value;

  @override
  String toString() {
    return 'AGLoRaSensor{name: $name, value: $value}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AGLoRaSensor && other.name == name && other.value == value;
  }
}

class AGLORATrackerPoint {
  AGLORATrackerPoint(
      {required this.identifier,
      required this.latitude,
      required this.longitude,
      required this.time,
      this.sensors});

  String identifier;
  double latitude;
  double longitude;
  DateTime time;

  List<AGLoRaSensor>? sensors;

  @override
  String toString() {
    return 'AGLoRaTrackerPoint{identifier: $identifier, latitude: $latitude, longitude: $longitude, time: $time, sensors: $sensors}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AGLORATrackerPoint &&
        other.identifier == identifier &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.time == time;
  }

  @override
  int get hashCode {
    return identifier.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        time.hashCode ^
        sensors.hashCode;
  }
}

var dataStreamController =
    StreamController<List<AGLORATrackerPoint>>.broadcast();

Stream<List<AGLORATrackerPoint>> get trackersListStream =>
    dataStreamController.stream;

const String packagePrefix = 'AGLoRa-';
const String packagePostfix = '|';

const requestAllTrackers = 'all';
