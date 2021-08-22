import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mware/providers/session.dart';
import 'package:mware/ui/screens/create_worker_screen.dart';
import 'package:mware/ui/screens/home_screen.dart';
import 'package:mware/ui/screens/landing_screen.dart';
import 'package:mware/ui/screens/login_screen.dart';
import 'package:mware/ui/screens/scanner_screen.dart';
import 'package:mware/ui/screens/signup_screen.dart';
import 'package:mware/ui/screens/track_work_screen.dart';
import 'package:mware/ui/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final session = Session();
  await session.refreshUser();

  runApp(MWareApp(session: session));
}

class MWareApp extends StatelessWidget {
  final Session session;
  final String initialRoute;

  MWareApp({Key? key, required this.session})
      : initialRoute = session.isLoggedIn ? '/home' : '/',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: session,
      builder: (_, __) {
        return MaterialApp(
          title: 'MWare',
          initialRoute: initialRoute,
          theme: theme,
          routes: {
            '/': (_) => const LandingScreen(),
            '/signup': (_) => const SignupScreen(),
            '/login': (_) => const LoginScreen(),
            '/home': (_) => const HomeScreen(),
            '/scanner': (_) => const ScannerScreen(),
            '/createWorker': (_) => const CreateWorkerScreen(),
            '/trackWork': (_) => const TrackWorkScreen(),
          },
        );
      },
    );
  }
}
