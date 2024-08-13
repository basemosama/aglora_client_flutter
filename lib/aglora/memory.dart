import 'package:flutter/foundation.dart';

import 'data.dart';

Memory agloraAppMemory = Memory();

class Memory {
  String myID = '';
  List<AGLORATrackerPoint> memory = [];
  List<AGLORATrackerPoint> trackers = [];

  void setIdTo(String? newID) {
    if (newID != null) {
      myID = newID;
    }
  }

  /// add new point to memory
  void addPoint(AGLORATrackerPoint? newPoint) {
    bool isPointNew = true;
    if (newPoint != null) {
      // save point to memory if it doesn't exist
      final pointsToBeRemoved = <int>[];
      for (int i = 0; i < memory.length; i++) {
        final point = memory[i];

        // The most reliable way  :-)
        if (point == newPoint) {
          if (kDebugMode) print('MEMORY: Point already exists');
          isPointNew = false;
          pointsToBeRemoved.add(i);
        }
      }

      if (!isPointNew) {
        for (int i = pointsToBeRemoved.length - 1; i >= 0; i--) {
          memory.removeAt(pointsToBeRemoved[i]);
        }
      }

      memory.add(newPoint);

      if (kDebugMode) {
        print('MEMORY: Point has been added. '
            'Total ${memory.length} points');
        print('Name: ${newPoint.identifier}');
        newPoint.sensors?.forEach((sensor) {
          print('${sensor.name}: ${sensor.value}');
        });
      }
    }

    recalculateTrackers();
    updateTrackersInUI();
  }

  /// find fresh tracker's points in the memory
  recalculateTrackers() {
    trackers.clear();

    memory.forEach((point) {
      bool noTrackerYet = true;

      for (var i = 0; i < trackers.length; i++) {
        if (trackers[i].identifier == point.identifier) {
          noTrackerYet = false;
          if (point.time.isAfter(trackers[i].time)) {
            trackers[i] = point;
          }
        }
      }
      if (noTrackerYet) {
        trackers.add(point);
      }
    });
  }

  /// send a new list of trackers to the UI
  void updateTrackersInUI() {
    if (dataStreamController.hasListener) {
      dataStreamController.add(trackers);
      if (kDebugMode) print('MEMORY: ${trackers.length} trackers in memory');
    }
  }

  /// clear all track points
  void eraseAllData() {
    memory.clear();
  }
}
