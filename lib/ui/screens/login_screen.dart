import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mware/models/process.dart';
import 'package:mware/providers/session.dart';
import 'package:mware/services/auth_service.dart';
import 'package:mware/ui/widgets/app_bar.dart';
import 'package:mware/ui/widgets/button.dart';
import 'package:mware/ui/widgets/text_field.dart';
import 'package:mware/utils/process_utils.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:email_validator/email_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with Processable {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  final _emailController = TextEditingController();
  final _emailNode = FocusNode();
  String? _emailErrorMessage;

  final _passwordController = TextEditingController();
  final _passwordNode = FocusNode();
  String? _passwordErrorMessage;

  String? _errorMessage;

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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MWAppBar(
        title: AnimatedOpacity(
          opacity: _logoVisible ? 0 : 1,
          duration: const Duration(milliseconds: 150),
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
                          'Log In',
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
                      MWTextFormField(
                        labelText: 'Email',
                        suffixIcon: Icons.mail_outline,
                        controller: _emailController,
                        focusNode: _emailNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        errorMessage: _emailErrorMessage,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email.';
                          } else if (!EmailValidator.validate(value)) {
                            return 'Please enter a valid email.';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (_) {
                          if (_emailErrorMessage != null) {
                            setState(() => _emailErrorMessage = null);
                          }
                        },
                      ),
                      MWTextFormField(
                        labelText: 'Password',
                        suffixIcon: Icons.password_outlined,
                        controller: _passwordController,
                        focusNode: _passwordNode,
                        errorMessage: _passwordErrorMessage,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _logIn(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password.';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters long.';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (_) {
                          if (_passwordErrorMessage != null) {
                            setState(() => _passwordErrorMessage = null);
                          }
                        },
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SubmitButton(
                text: 'Log In',
                processStatus: processStatus,
                onPressed: _logIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logIn() async {
    setState(() => autovalidateMode = AutovalidateMode.onUserInteraction);

    if (!_formKey.currentState!.validate()) return;

    setProcessStatus(ProcessStatus.processing);

    try {
      final user = await AuthService.instance.logIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (user == null) {
        throw Exception();
      }

      await context.read<Session>().refreshUser();
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (_) {
      setState(() {
        _errorMessage = 'Wrong email and/or password.';
      });
    } finally {
      setProcessStatus(ProcessStatus.idle);
    }
  }
}
