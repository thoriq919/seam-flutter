// settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seam_flutter/blocs/auth/auth_bloc.dart';
import 'package:seam_flutter/blocs/auth/auth_state.dart';
import 'package:seam_flutter/blocs/auth/auth_event.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Profile',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: ColorTheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is Authenticated) {
                          return Column(
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  'Name',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  state.user.nama,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.email,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  'Email',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  state.user.email,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  'Phone',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  state.user.telp,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: ListTile(
                                  leading: const Icon(Icons.logout,
                                      color: Colors.red),
                                  title: const Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Logout'),
                                          content: const Text(
                                              'Are you sure you want to logout?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                context
                                                    .read<AuthBloc>()
                                                    .add(SignOutRequested());
                                                Navigator.pop(
                                                    context); // Close dialog
                                              },
                                              child: const Text(
                                                'Logout',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        } else if (state is AuthLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return const Center(
                            child: Text('No profile data available'),
                          );
                        }
                      },
                    ),
                  ))
            ],
          ),
        )),
      ),
    );
  }
}
