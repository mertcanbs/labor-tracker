import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mware/ui/widgets/button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'MWare',
                            style: Theme.of(context).textTheme.headline3,
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            'Real-time tracking of work hours and project progress',
                            style: Theme.of(context).textTheme.headline6,
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Image.asset('assets/logo/logo.png', width: 72),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Button.dense(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_circle_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 84,
                    ),
                    Text(
                      'Log In',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black.withOpacity(0.03),
              padding: const EdgeInsets.all(8),
              child: SafeArea(
                top: false,
                left: false,
                right: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New to MWare?',
                          style: Theme.of(context).textTheme.overline,
                        ),
                        const SizedBox(width: 8),
                        Button.dense(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: const Text(
                        'NOTE: This prototype is a demonstration of basic app functionality. Please note that access levels, UI design, layout, structure, and routes are subject to change.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
