import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mware/utils/datetime_utils.dart';

class Worker {
  late String barcode;
  late String firstName;
  late String lastName;
  late String companyId;

  String get fullName => '$firstName $lastName';

  WorkSession? activeSession;
  bool get isActive => activeSession != null;

  List<WorkSession> pastSessions = [];

  List<WorkSession> get todaysSessions {
    final list =
        pastSessions.where((session) => session.clockInTime.isSameDay(DateTime.now())).toList();

    if (activeSession != null) {
      if (activeSession!.clockInTime.isSameDay(DateTime.now())) {
        list.add(activeSession!);
      }
    }

    return list;
  }

  List<WorkSession> get yesterdaysSessions {
    return pastSessions
        .where((session) =>
            session.clockInTime.isSameDay(DateTime.now().subtract(const Duration(days: 1))))
        .toList();
  }

  List<WorkSession> get lastSevenDaysSessions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = today.subtract(const Duration(days: 7));

    final list =
        pastSessions.where((session) => session.clockInTime.isAfter(sevenDaysAgo)).toList();

    if (activeSession != null) {
      if (activeSession!.clockInTime.isWithinRange(DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ))) {
        list.add(activeSession!);
      }
    }

    return list;
  }

  Worker.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    barcode = doc.id;
    firstName = data['name']['first'] ?? '';
    lastName = data['name']['last'] ?? '';
    companyId = data['company_id'];

    activeSession =
        data['active_session'] != null ? WorkSession.fromMap(data['active_session']) : null;

    pastSessions = data['past_sessions'] != null
        ? (data['past_sessions'] as List).map((map) => WorkSession.fromMap(map)).toList()
        : [];

    pastSessions.sort((a, b) => a.clockInTime.compareTo(b.clockInTime));
  }

  Duration calculateWorkDurationOnDay(DateTime day) {
    final validSessions = pastSessions.where((session) {
      return session.clockInTime.isSameDay(day) && session.clockOutTime!.isSameDay(day);
    });

    Duration workDuration = validSessions.fold(Duration.zero, (a, b) => a + b.duration);

    if (activeSession != null && day.isSameDay(DateTime.now())) {
      workDuration += activeSession!.duration;
    }

    return workDuration;
  }

  Duration calculateWorkDurationBetween(DateTimeRange range) {
    final validSessions = pastSessions.where((session) {
      return session.clockInTime.isWithinRange(range);
    });

    Duration workDuration = validSessions.fold(Duration.zero, (a, b) => a + b.duration);

    if (activeSession != null && activeSession!.clockInTime.isWithinRange(range)) {
      workDuration += activeSession!.duration;
    }

    return workDuration;
  }
}

class WorkSession {
  late DateTime clockInTime;
  DateTime? clockOutTime;
  late Duration timeZoneOffset;

  bool get isComplete => clockOutTime != null;

  Duration get duration {
    return DateTimeRange(start: clockInTime, end: clockOutTime ?? DateTime.now()).duration;
  }

  WorkSession.fromMap(Map<String, dynamic> map) {
    // TODO: Convert these to local times according to timeZoneOffset
    clockInTime = (map['clock_in'] as Timestamp).toDate();
    clockOutTime = map['clock_out'] != null ? (map['clock_out'] as Timestamp).toDate() : null;
    timeZoneOffset = Duration(milliseconds: map['time_zone_offset'] ?? 0);
  }
}
