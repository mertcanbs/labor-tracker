import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mware/models/company.dart';
import 'package:mware/models/process.dart';
import 'package:mware/providers/session.dart';
import 'package:mware/providers/signup_provider.dart';
import 'package:mware/services/auth_service.dart';
import 'package:mware/ui/widgets/app_bar.dart';
import 'package:mware/ui/widgets/button.dart';
import 'package:mware/ui/widgets/dropdown.dart';
import 'package:mware/ui/widgets/text_field.dart';
import 'package:mware/utils/process_utils.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:email_validator/email_validator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with Processable {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  final _firstnameController = TextEditingController();
  final _firstnameNode = FocusNode();

  final _lastnameController = TextEditingController();
  final _lastnameNode = FocusNode();

  final _emailController = TextEditingController();
  final _emailNode = FocusNode();
  String? _emailErrorMessage;

  final _passwordController = TextEditingController();
  final _passwordNode = FocusNode();
  String? _passwordErrorMessage;

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
                                'Create An Account',
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
                    text: 'Sign Up',
                    processStatus: processStatus,
                    onPressed: _signUp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _signUp() async {
    setState(() => autovalidateMode = AutovalidateMode.onUserInteraction);

    if (!_formKey.currentState!.validate()) return;

    setProcessStatus(ProcessStatus.processing);

    try {
      await AuthService.instance.signUpForeman(
        email: _emailController.text,
        password: _passwordController.text,
        companyId: _selectedCompany!.id,
        firstName: _firstnameController.text,
        lastName: _lastnameController.text,
      );

      await context.read<Session>().refreshUser();
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on FirebaseAuthException catch (e) {
      final message = e.message!.toLowerCase();

      setState(() {
        if (message.contains('email')) {
          _emailErrorMessage = message;
        } else if (message.contains('password')) {
          _passwordErrorMessage = message;
        } else {
          _errorMessage = message;
        }
      });
    } finally {
      setProcessStatus(ProcessStatus.idle);
    }
  }
}
