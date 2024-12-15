import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seam_flutter/blocs/auth/auth_bloc.dart';
import 'package:seam_flutter/firebase_options.dart';
import 'package:seam_flutter/page/realtime.dart';
import 'package:seam_flutter/screens/admin/home_screen.dart';
import 'package:seam_flutter/screens/admin/penjualan/index_screen.dart';
import 'package:seam_flutter/screens/admin/penjualan/penjualan_screen.dart';
import 'package:seam_flutter/screens/auth/login_screen.dart';
import 'package:seam_flutter/screens/auth/register_screen.dart';
import 'package:seam_flutter/page/catat.dart';

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
          '/home': (context) => const HomeScreen(),
          '/register': (context) => const RegisterScreen(),
          '/catat': (context) => const Catat(),
          '/monitoring': (context) => const Realtime(),
          '/penjualan': (context) => IndexScreen()
        },
      ),
    );
  }
}
