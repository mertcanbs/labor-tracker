import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mware/models/company.dart';
import 'package:mware/models/worker.dart';
import 'package:mware/services/companies_service.dart';

class TrackWorkProvider extends ChangeNotifier {
  Map<String, Worker>? _workers;
  Map<String, Worker>? get workers => _workers;

  Map<String, Company>? _companies;
  Map<String, Company>? get companies => _companies;

  late StreamSubscription<QuerySnapshot> _subscription;

  final CollectionReference<Map<String, dynamic>> _collectionReference =
      FirebaseFirestore.instance.collection('workers');

  TrackWorkProvider() {
    _getWorkers();
    _getCompanies();

    _subscription = _collectionReference.snapshots().listen((event) {
      if (_workers == null) return;

      for (var change in event.docChanges) {
        Worker worker = Worker.fromSnapshot(change.doc);

        switch (change.type) {
          case DocumentChangeType.added:
            _workers![worker.barcode] = worker;
            break;
          case DocumentChangeType.modified:
            _workers![worker.barcode] = worker;
            break;
          case DocumentChangeType.removed:
            _workers!.remove(worker.barcode);
            break;
        }
      }

      notifyListeners();
    });
  }

  _getWorkers() async {
    final result = await _collectionReference.get();
    final list = result.docs.map((doc) => Worker.fromSnapshot(doc));
    _workers = Map<String, Worker>.fromIterable(list, key: (worker) => worker.barcode);
    notifyListeners();
  }

  _getCompanies() async {
    final list = await CompaniesService.instance.getCompanies();
    _companies = Map.fromIterable(list, key: (company) => company.id);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
