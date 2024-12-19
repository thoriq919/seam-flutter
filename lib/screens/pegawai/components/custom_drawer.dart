import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seam_flutter/blocs/auth/auth_bloc.dart';
import 'package:seam_flutter/blocs/auth/auth_event.dart';
import 'package:seam_flutter/screens/admin/chat/chat.dart';
import 'package:seam_flutter/screens/admin/humidity/kelembapan_screen.dart';
import 'package:seam_flutter/screens/admin/maps/map_screen.dart';
import 'package:seam_flutter/screens/admin/payments/index_screen.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class CustomDrawer extends StatelessWidget {
  final String currentUsername;
  const CustomDrawer({super.key, required this.currentUsername});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.125,
        ),
        decoration: BoxDecoration(
          color: ColorTheme.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorTheme.grey,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: ColorTheme.blackFont,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            currentUsername,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ColorTheme.blackFont,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.chat,
                            color: ColorTheme.blackFont,
                          ),
                          title: Text(
                            'Chat',
                            style: TextStyle(color: ColorTheme.blackFont),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Chat(senderName: currentUsername)),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.map_rounded,
                            color: ColorTheme.blackFont,
                          ),
                          title: Text(
                            'Maps',
                            style: TextStyle(color: ColorTheme.blackFont),
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return TrackingMapScreen();
                              },
                            ));
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: ColorTheme.white,
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<AuthBloc>()
                                      .add(SignOutRequested());
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Logout'),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                                    style:
                                        TextStyle(color: ColorTheme.blackFont),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.exit_to_app_outlined,
                        color: ColorTheme.danger),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
