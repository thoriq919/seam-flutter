import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seam_flutter/models/user.dart';
import 'package:seam_flutter/screens/auth/register_screen.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class PegawaiScreen extends StatelessWidget {
  const PegawaiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, size),
            Expanded(child: _buildUserList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size size) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: size.height * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pegawai',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => _navigateToRegister(context),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  Widget _buildUserList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'pegawai')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingWidget();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyWidget();
          }

          return _buildUserListView(context, snapshot.data!.docs);
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Text(
        'Error: $error',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Text(
        'No users found',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildUserListView(
      BuildContext context, List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>;
        final user = UserModel.fromMap({...data, 'uid': doc.id});

        return _buildUserCard(context, user);
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    return InkWell(
      onLongPress: () => _showDeleteConfirmationDialog(context, user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildUserAvatar(user),
            const SizedBox(width: 12),
            Expanded(child: _buildUserDetails(user)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(UserModel user) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: user.foto != null && user.foto!.isNotEmpty
          ? Image.network(
              user.foto!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildDefaultAvatar(),
            )
          : _buildDefaultAvatar(),
    );
  }

  Widget _buildUserDetails(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.nama,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (user.email != null) _buildInfoRow(Icons.email, user.email!),
        if (user.telp != null) _buildInfoRow(Icons.phone, user.telp!),
        if (user.alamat != null) _buildInfoRow(Icons.location_on, user.alamat!),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.person, size: 30),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteUser(user);
                Navigator.of(context).pop(); // Close the dialog after deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      print('User deleted successfully');
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}
