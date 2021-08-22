import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mware/models/company.dart';
import 'package:mware/models/process.dart';
import 'package:mware/providers/signup_provider.dart';
import 'package:mware/services/worker_service.dart';
import 'package:mware/ui/widgets/app_bar.dart';
import 'package:mware/ui/widgets/button.dart';
import 'package:mware/ui/widgets/dropdown.dart';
import 'package:mware/ui/widgets/text_field.dart';
import 'package:mware/utils/process_utils.dart';
import 'package:mware/utils/scanner_utils.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CreateWorkerScreen extends StatefulWidget {
  const CreateWorkerScreen({Key? key}) : super(key: key);

  @override
  _CreateWorkerScreenState createState() => _CreateWorkerScreenState();
}

class _CreateWorkerScreenState extends State<CreateWorkerScreen> with Processable {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  final _firstnameController = TextEditingController();
  final _firstnameNode = FocusNode();

  final _lastnameController = TextEditingController();
  final _lastnameNode = FocusNode();

  String? _barcode;

  String? _companyErrorMessage;

  String? _errorMessage;

  Company? _selectedCompany;

  bool _logoVisible = true;

  @override
  void initState() {
    VisibilityDetectorController.instance.updateInterval = const Duration(milliseconds: 50);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomOffset = mq.viewInsets.bottom + mq.padding.bottom;

    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      builder: (context, child) {
        SignupProvider provider = context.watch<SignupProvider>();

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: MWAppBar(
            title: AnimatedOpacity(
              opacity: _logoVisible ? 0 : 1,
              duration: const Duration(milliseconds: 100),
              child: Image.asset(
                'assets/logo/logo_with_text.png',
                height: 40,
              ),
            ),
          ),
          body: Stack(
            children: [
              Container(
                height: double.maxFinite,
                padding: EdgeInsets.only(bottom: bottomOffset),
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: autovalidateMode,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            VisibilityDetector(
                              key: const Key('logo'),
                              onVisibilityChanged: (info) {
                                if (mounted) {
                                  setState(() => _logoVisible = info.visibleFraction != 0);
                                }
                              },
                              child: Center(
                                child: Image.asset(
                                  'assets/logo/logo_with_text.png',
                                  width: min(MediaQuery.of(context).size.width * 2 / 3, 300),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(top: 24, bottom: 12),
                              child: Text(
                                'Create Worker',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12, bottom: 24),
                              child: Text(
                                _errorMessage ?? '',
                                style: TextStyle(color: Theme.of(context).errorColor),
                              ),
                            ),
                            MWDropdownFormField<Company>(
                              hint: const Text('Select Company'),
                              value: _selectedCompany,
                              errorMessage: _companyErrorMessage,
                              validator: (company) {
                                if (company == null) {
                                  return 'Please select a company.';
                                } else {
                                  return null;
                                }
                              },
                              onChanged: provider.companies == null
                                  ? null
                                  : (company) {
                                      setState(() {
                                        _companyErrorMessage = null;
                                        _selectedCompany = company;
                                      });
                                    },
                              items: provider.companies?.map((e) {
                                    return DropdownMenuItem<Company>(
                                      child: Text(e.name),
                                      value: e,
                                    );
                                  }).toList() ??
                                  [],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32.0),
                              child: InputDecorator(
                                decoration: const InputDecoration()
                                    .applyDefaults(Theme.of(context).inputDecorationTheme),
                                child: Button.dense(
                                  child: Row(
                                    children: [
                                      const Icon(FontAwesomeIcons.barcode),
                                      const SizedBox(width: 8),
                                      Text(_barcode == null ? 'Scan Barcode' : 'Scanned Barcode: $_barcode'),
                                    ],
                                  ),
                                  onPressed: () async {
                                    final barcode = await ScannerUtils.scanBarcode(context);

                                    if (barcode != null) {
                                      setState(() {
                                        _barcode = barcode;
                                        _errorMessage = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: MWTextFormField(
                                    labelText: 'First Name',
                                    controller: _firstnameController,
                                    focusNode: _firstnameNode,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization: TextCapitalization.words,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your first name.';
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: MWTextFormField(
                                    labelText: 'Last Name',
                                    controller: _lastnameController,
                                    focusNode: _lastnameNode,
                                    keyboardType: TextInputType.text,
                                    textCapitalization: TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your last name.';
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: SubmitButton(
                    text: 'Create Worker',
                    processStatus: processStatus,
                    onPressed: _createWorker,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _createWorker() async {
    setState(() => autovalidateMode = AutovalidateMode.onUserInteraction);

    if (_barcode == null) {
      setState(() => _errorMessage = 'Please scan your barcode');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setProcessStatus(ProcessStatus.processing);

    try {
      await WorkerService.instance.createWorker(
        barcode: _barcode!,
        companyId: _selectedCompany!.id,
        firstName: _firstnameController.text,
        lastName: _lastnameController.text,
      );

      Navigator.pop(context, true);
    } on WorkerExistsException {
      setState(() {
        _errorMessage = 'This barcode is unavailable. Please try another one.';
        _barcode = null;
      });
    } finally {
      setProcessStatus(ProcessStatus.idle);
    }
  }
}
