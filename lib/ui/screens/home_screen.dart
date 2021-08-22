import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mware/models/company.dart';
import 'package:mware/models/process.dart';
import 'package:mware/providers/session.dart';
import 'package:mware/services/companies_service.dart';
import 'package:mware/services/worker_service.dart';
import 'package:mware/ui/widgets/app_bar.dart';
import 'package:mware/ui/widgets/button.dart';
import 'package:mware/utils/process_utils.dart';
import 'package:mware/utils/scanner_utils.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final session = context.read<Session>();
    TextStyle textStyle = Theme.of(context).textTheme.headline6!;

    print(DateTime.now().timeZoneOffset.inMilliseconds);

    return Scaffold(
      appBar: MWAppBar(
        leading: Container(),
        title: Image.asset(
          'assets/logo/logo_with_text.png',
          height: 34,
        ),
        actions: [
          Button(
            child: const Text('Sign Out'),
            onPressed: () async {
              await session.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          DefaultTextStyle(
            style: textStyle,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Welcome to the MWare prototype.'),
                    const SizedBox(height: 32),
                    FutureBuilder<Company?>(
                      future: CompaniesService.instance.getCompanyById(session.user!.companyId),
                      builder: (context, snapshot) {
                        return Text(
                          'You are signed in as ${session.user!.firstName} ${session.user!.lastName} (${session.user!.email}), a Foreman for ${snapshot.data?.name ?? ""}.',
                        );
                      },
                    ),
                    Button(
                      margin: const EdgeInsets.only(top: 32, bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(FontAwesomeIcons.plus),
                          SizedBox(width: 12),
                          Text('Create Worker'),
                        ],
                      ),
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        final result = await Navigator.pushNamed(context, '/createWorker');

                        if (result != null && result is bool && result) {
                          ProcessModel.success(
                            context: context,
                            successText: 'Worker Created',
                          ).showDialog();
                        }
                      },
                    ),
                    Button(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(FontAwesomeIcons.barcode),
                          SizedBox(width: 12),
                          Text('Scan Barcodes'),
                        ],
                      ),
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        final barcode = await ScannerUtils.scanBarcode(context);

                        if (barcode != null) {
                          ProcessModel model = ProcessModel.processing(
                            context: context,
                            popDelayDuration: const Duration(seconds: 3),
                          )..showDialog();

                          try {
                            ScanResult result = await WorkerService.instance.clockWorker(barcode);

                            switch (result.scanType) {
                              case ScanType.clockedIn:
                                model.setSuccessText('Clocked in.');
                                model.setStatus(ProcessStatus.success);
                                break;
                              case ScanType.clockedOut:
                                model.setSuccessText('Clocked out.');
                                model.setStatus(ProcessStatus.success);
                                break;
                              case ScanType.clockedInAndDeactivatedLastSession:
                                model.setFailureText('Clocked in. Deactivated last session.');
                                model.setStatus(ProcessStatus.success);
                                break;
                            }
                          } on WorkerNotFoundException {
                            model.setFailureText('Worker not found.');
                            model.setStatus(ProcessStatus.failure);
                          }
                        }
                      },
                    ),
                    Button(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(FontAwesomeIcons.businessTime),
                          SizedBox(width: 12),
                          Text('Track Work'),
                        ],
                      ),
                      color: Theme.of(context).primaryColor,
                      onPressed: () => Navigator.pushNamed(context, '/trackWork'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: const SafeArea(
              bottom: true,
              child: Text(
                'NOTE: This prototype is a demonstration of basic app functionality. Please note that access levels, UI design, layout, structure, and routes are subject to change.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
