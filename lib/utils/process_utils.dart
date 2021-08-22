import 'package:flutter/material.dart';
import 'package:mware/models/process.dart';
import 'package:mware/utils/dialog_utils.dart';
import 'package:provider/provider.dart';

mixin Processable<T extends StatefulWidget> on State<T> {
  ProcessStatus processStatus = ProcessStatus.idle;

  void setProcessStatus(ProcessStatus status) {
    setState(() => processStatus = status);
  }
}

class ProcessModel extends ChangeNotifier {
  BuildContext context;

  ProcessStatus _processStatus = ProcessStatus.idle;
  ProcessStatus get processStatus => _processStatus;

  String? processingText;
  String? successText;
  String? failureText;

  bool _showingDialog = false;
  bool shouldPopOnSuccess = false;
  bool shouldPopOnFailure = false;

  bool get isIdle => _processStatus == ProcessStatus.idle;

  Duration popDelayDuration = const Duration(milliseconds: 1500);

  ProcessModel.processing({
    required this.context,
    this.processingText,
    this.successText,
    this.failureText,
    this.popDelayDuration = const Duration(milliseconds: 1500),
  }) {
    _processStatus = ProcessStatus.processing;
  }

  ProcessModel.idle({
    required this.context,
    this.popDelayDuration = const Duration(milliseconds: 1500),
  }) {
    _processStatus = ProcessStatus.idle;
  }

  ProcessModel.success({
    required this.context,
    this.successText,
    this.popDelayDuration = const Duration(milliseconds: 1500),
  }) {
    _processStatus = ProcessStatus.success;
    _handleSuccess();
  }

  void setProcessingText(String text) {
    processingText = text;
    notifyListeners();
  }

  void setSuccessText(String text) {
    successText = text;
    notifyListeners();
  }

  void setFailureText(String text) {
    failureText = text;
    notifyListeners();
  }

  void setStatus(ProcessStatus status) {
    _processStatus = status;
    if (_processStatus == ProcessStatus.failure) _handleFailure();
    if (_processStatus == ProcessStatus.success) _handleSuccess();
    notifyListeners();
  }

  _handleFailure() async {
    await Future.delayed(popDelayDuration);

    if (_showingDialog || shouldPopOnFailure) {
      Navigator.pop(context);
      await Future.delayed(popDelayDuration);
    }

    _processStatus = ProcessStatus.idle;
    notifyListeners();
  }

  _handleSuccess() async {
    await Future.delayed(popDelayDuration);

    if (_showingDialog || shouldPopOnSuccess) {
      Navigator.pop(context);
      await Future.delayed(popDelayDuration);
    }

    _processStatus = ProcessStatus.idle;
    notifyListeners();
  }

  Color get processColor {
    switch (processStatus) {
      case ProcessStatus.processing:
        return Theme.of(context).primaryColor;
      case ProcessStatus.success:
        return Theme.of(context).focusColor;
      case ProcessStatus.failure:
        return Colors.redAccent;
      default:
        return Colors.transparent;
    }
  }

  Widget get processWidget {
    switch (processStatus) {
      case ProcessStatus.processing:
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        );
      case ProcessStatus.success:
        return const Center(
          child: Icon(
            Icons.done,
            size: 48,
            color: Colors.white,
          ),
        );
      case ProcessStatus.failure:
        return const Center(
          child: Icon(
            Icons.cancel,
            size: 48,
            color: Colors.white,
          ),
        );
      default:
        return Container();
    }
  }

  String? get processText {
    switch (processStatus) {
      case ProcessStatus.processing:
        return processingText;
      case ProcessStatus.success:
        return successText;
      case ProcessStatus.failure:
        return failureText;
      default:
        return null;
    }
  }

  void showDialog() {
    _showingDialog = true;

    showMWDialog(
      barrierDismissible: false,
      context: context,
      dialog: ChangeNotifierProvider.value(
        value: this,
        child: _ProcessDialog(),
      ),
    );
  }
}

class _ProcessDialog extends StatefulWidget {
  @override
  _ProcessDialogState createState() => _ProcessDialogState();
}

class _ProcessDialogState extends State<_ProcessDialog> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProcessModel>(
      builder: (context, model, child) {
        final canPop = model.processStatus == ProcessStatus.idle;

        return WillPopScope(
          onWillPop: () => Future.value(canPop),
          child: SimpleDialog(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            children: [
              AnimatedContainer(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  color: model.processColor,
                ),
                padding: const EdgeInsets.all(12),
                duration: kThemeAnimationDuration,
                width: 120,
                height: 160,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      model.processWidget,
                      if (model.processText != null)
                        Column(
                          children: [
                            const SizedBox(height: 24),
                            Text(
                              model.processText!,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class ProcessableDialog extends StatelessWidget {
  final ProcessModel processModel;
  final Widget child;

  const ProcessableDialog({
    Key? key,
    required this.processModel,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProcessModel>.value(
      value: processModel..shouldPopOnSuccess = true,
      child: Consumer<ProcessModel>(
        builder: (context, model, _) {
          return AnimatedSwitcher(
            duration: kThemeAnimationDuration,
            child: processModel.processStatus != ProcessStatus.idle ? _ProcessDialog() : child,
          );
        },
      ),
    );
  }
}

class ProcessContainer extends StatefulWidget {
  final ProcessModel process;

  const ProcessContainer({Key? key, required this.process}) : super(key: key);
  @override
  _ProcessContainerState createState() => _ProcessContainerState();
}

class _ProcessContainerState extends State<ProcessContainer> {
  bool hasPopped = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProcessModel>.value(
      value: widget.process,
      child: Consumer<ProcessModel>(
        builder: (context, model, child) {
          return AnimatedContainer(
            duration: kThemeAnimationDuration,
            color: model.processColor,
            child: Center(child: model.processWidget),
          );
        },
      ),
    );
  }
}
