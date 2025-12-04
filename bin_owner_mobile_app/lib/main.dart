import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bin_owner_mobile_app/routes.dart';
import 'package:bin_owner_mobile_app/screens/verfication_screen.dart';
import 'package:bin_owner_mobile_app/screens/profile_form_screen.dart';
import 'package:bin_owner_mobile_app/theme/theme.dart';
import 'package:bin_owner_mobile_app/providers/user_provider.dart';
import 'package:bin_owner_mobile_app/providers/bin_provider.dart';
import 'package:bin_owner_mobile_app/screens/new_password_screen.dart';
import 'package:bin_owner_mobile_app/screens/password_reset_verification_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BinProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoRoute',
      theme: customTheme,

      // 👇 Start with Login Page
      initialRoute: AppRoutes.login,

      // 👇 Named route table
      routes: AppRoutes.routes,

      // 👇 Dynamic routes for screens needing arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/verify') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              !args.containsKey('email') ||
              !args.containsKey('token')) {
            return MaterialPageRoute(
              builder:
                  (context) => const Scaffold(
                    body: Center(
                      child: Text('Missing verification email or token'),
                    ),
                  ),
            );
          }
          return MaterialPageRoute(
            builder:
                (context) => VerificationScreen(
                  email: args['email'],
                  userId: args['userId'] ?? '',
                  token: args['token'],
                ),
          );
        } else if (settings.name == '/password-reset-verification') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              !args.containsKey('email') ||
              !args.containsKey('sessionToken')) {
            return MaterialPageRoute(
              builder:
                  (context) => const Scaffold(
                    body: Center(
                      child: Text('Missing password reset verification data'),
                    ),
                  ),
            );
          }
          return MaterialPageRoute(
            builder:
                (context) => PasswordResetVerificationScreen(
                  email: args['email'],
                  sessionToken: args['sessionToken'],
                ),
          );
        } else if (settings.name == '/reset-password-new') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              !args.containsKey('email') ||
              !args.containsKey('verifiedToken')) {
            return MaterialPageRoute(
              builder:
                  (context) => const Scaffold(
                    body: Center(child: Text('Missing password reset data')),
                  ),
            );
          }
          return MaterialPageRoute(
            builder:
                (context) => NewPasswordScreen(
                  email: args['email'],
                  verifiedToken: args['verifiedToken'],
                ),
          );
        } else if (settings.name == '/profile') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ProfileFormScreen(userId: args['userId']),
          );
        }
        return null; // fallback to static routes
      },
    );
  }
}
