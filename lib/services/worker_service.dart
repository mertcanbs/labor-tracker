import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mware/models/worker.dart';
import 'package:intl/intl.dart';
import 'package:mware/utils/datetime_utils.dart';

class WorkerService {
  static final WorkerService instance = WorkerService._internal();

  factory WorkerService() {
    return instance;
  }

  WorkerService._internal();

  Future<ScanResult> clockWorker(String barcode) async {
    final doc = await FirebaseFirestore.instance.collection('workers').doc(barcode).get();

    if (!doc.exists) {
      throw WorkerNotFoundException();
    }

    Worker worker = Worker.fromSnapshot(doc);

    if (worker.activeSession != null) {
      final workSession = worker.activeSession!;
      final clockInTimeInSessionLocale = workSession.clockInTime.add(workSession.timeZoneOffset);
      final nowInSessionLocale = DateTime.now().toUtc().add(workSession.timeZoneOffset);

      // if (nowInSessionLocale.isSameDay(clockInTimeInSessionLocale)) {
        await doc.reference.update({
          'active_session': FieldValue.delete(),
          'past_sessions': FieldValue.arrayUnion(
            [
              {
                'clock_in': Timestamp.fromDate(worker.activeSession!.clockInTime),
                'clock_out': Timestamp.now(),
              }
            ],
          ),
        });

        return ScanResult(ScanType.clockedOut, worker);
      // } else {
      //   final workEndTimeAtSessionLocale = DateTime(
      //     clockInTimeInSessionLocale.year,
      //     clockInTimeInSessionLocale.month,
      //     clockInTimeInSessionLocale.day,
      //     17,
      //     30,
      //   );

      //   if (clockInTimeInSessionLocale.isBefore(workEndTimeAtSessionLocale)) {}

      //   await doc.reference.update({
      //     'active_session': {
      //       'clock_in': Timestamp.now(),
      //       'time_zone_offset': DateTime.now().timeZoneOffset.inMilliseconds,
      //     },
      //     if (clockInTimeInSessionLocale.isBefore(workEndTimeAtSessionLocale))
      //       'past_sessions': FieldValue.arrayUnion(
      //         [
      //           {
      //             'clock_in': Timestamp.fromDate(worker.activeSession!.clockInTime),
      //             'clock_out': Timestamp.fromDate(workEndTimeAtSessionLocale),
      //           }
      //         ],
      //       ),
      //   });
      // }
    } else {
      await doc.reference.update({
        'active_session': {
          'clock_in': Timestamp.now(),
          'time_zone_offset': DateTime.now().timeZoneOffset.inMilliseconds,
        },
      });

      return ScanResult(ScanType.clockedIn, worker);
    }
  }

  /// Creates a worker in the database.
  /// If the barcode is already in use, throws WorkerExistsException.
  Future<void> createWorker({
    required String barcode,
    required String firstName,
    required String lastName,
    required String companyId,
  }) async {
    final doc = await FirebaseFirestore.instance.collection('workers').doc(barcode).get();

    if (doc.exists) {
      throw WorkerExistsException();
    }

    await doc.reference.set({
      'barcode': barcode,
      'company_id': companyId,
      'name': {
        'first': firstName,
        'last': lastName,
      }
    });
  }
}

class WorkerExistsException implements Exception {}

class WorkerNotFoundException implements Exception {}

enum ScanType { clockedIn, clockedOut, clockedInAndDeactivatedLastSession }

class ScanResult {
  final ScanType scanType;
  final Worker worker;

  ScanResult(this.scanType, this.worker);
}
