import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seam_flutter/blocs/auth/auth_bloc.dart';
import 'package:seam_flutter/firebase_options.dart';
import 'package:seam_flutter/screens/admin/admin_layout.dart';
import 'package:seam_flutter/screens/admin/penjualan/index_screen.dart';
import 'package:seam_flutter/screens/auth/login_screen.dart';
import 'package:seam_flutter/screens/admin/employee/create.dart';
import 'package:seam_flutter/screens/pegawai/pegawai_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SEAM',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/penjualan': (context) => IndexScreen()
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/home') {
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => HomeScreen(
                currentUser: args,
              ),
            );
          } else if (settings.name == '/user_dashboard') {
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => PegawaiLayout(
                currentUser: args,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
