import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mware/models/company.dart';
import 'package:mware/models/worker.dart';
import 'package:mware/providers/track_work_provider.dart';
import 'package:mware/ui/widgets/active_indicator.dart';
import 'package:mware/ui/widgets/app_bar.dart';
import 'package:mware/ui/widgets/loader.dart';
import 'package:mware/utils/datetime_utils.dart';
import 'package:provider/provider.dart';

class TrackWorkScreen extends StatefulWidget {
  const TrackWorkScreen({Key? key}) : super(key: key);

  @override
  _TrackWorkScreenState createState() => _TrackWorkScreenState();
}

class _TrackWorkScreenState extends State<TrackWorkScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackWorkProvider(),
      builder: (context, __) {
        TrackWorkProvider provider = context.watch<TrackWorkProvider>();
        List<Company>? companies = provider.companies?.values.toList();
        List<Worker>? workers = provider.workers?.values.toList();

        if (companies != null) companies.sort((a, b) => a.name.compareTo(b.name));

        return Scaffold(
          appBar: const MWAppBar(
            title: Text('Track Work'),
          ),
          body: companies == null || workers == null
              ? const Center(
                  child: Loader(),
                )
              : ListView.builder(
                  itemCount: companies.length,
                  itemBuilder: (context, index) {
                    Company company = companies[index];
                    List<Worker> companyWorkers = workers
                        .where((element) => element.companyId == company.id)
                        .toList()
                      ..sort((a, b) => a.lastName.compareTo(b.lastName));

                    return CompanyWorkTracker(
                      company: company,
                      workers: companyWorkers,
                    );
                  },
                ),
        );
      },
    );
  }
}

class CompanyWorkTracker extends StatefulWidget {
  final Company company;
  final List<Worker> workers;

  const CompanyWorkTracker({
    Key? key,
    required this.company,
    required this.workers,
  }) : super(key: key);

  @override
  State<CompanyWorkTracker> createState() => _CompanyWorkTrackerState();
}

class _CompanyWorkTrackerState extends State<CompanyWorkTracker> {
  late Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Worker> companyWorkers = widget.workers
        .where((worker) => worker.companyId == widget.company.id)
        .toList()
      ..sort((a, b) => a.lastName.compareTo(b.lastName));

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.company.name,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: companyWorkers.length,
            itemBuilder: (context, index) {
              Worker worker = companyWorkers[index];

              String todaysWorkDuration = worker.calculateWorkDurationOnDay(DateTime.now()).format();
              int todaysSessionCount = worker.todaysSessions.length;

              String yesterdaysWorkDuration = worker
                  .calculateWorkDurationOnDay(DateTime.now().subtract(const Duration(days: 1)))
                  .format();
              int yesterdaysSessionCount = worker.yesterdaysSessions.length;

              String lastSevenDaysWorkDuration = worker
                  .calculateWorkDurationBetween(DateTimeRange(
                    start: DateTime.now().subtract(const Duration(days: 7)),
                    end: DateTime.now(),
                  ))
                  .format();
              int lastSevenDaysSessionCount = worker.lastSevenDaysSessions.length;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(worker.fullName, style: Theme.of(context).textTheme.headline6),
                        const SizedBox(width: 6),
                        ActiveIndicator(active: worker.isActive),
                      ],
                    ),
                    Text(
                      'Today: $todaysWorkDuration ($todaysSessionCount session${todaysSessionCount == 1 ? '' : 's'})',
                    ),
                    Text(
                      'Yesterday: $yesterdaysWorkDuration ($yesterdaysSessionCount session${yesterdaysSessionCount == 1 ? '' : 's'})',
                    ),
                    Text(
                      'Last Seven Days: $lastSevenDaysWorkDuration ($lastSevenDaysSessionCount session${lastSevenDaysSessionCount == 1 ? '' : 's'})',
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
