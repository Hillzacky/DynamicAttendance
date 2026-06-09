import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';

class UserDetailView extends StatelessWidget {
  final User user;
  final UserController userController = Get.find();

  UserDetailView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed('/user-form', arguments: user),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Text(
                      user.fullname[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullname,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.posisi ?? 'No Position',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: user.status == 'active' ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Basic Information
            _buildSection('Basic Information', [
              _buildDetailRow('Username', user.username),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Full Name', user.fullname),
              _buildDetailRow('Contact', user.kontak ?? '-'),
            ]),

            const SizedBox(height: 16),

            // Employment Information
            _buildSection('Employment Information', [
              _buildDetailRow('NIP', user.nip ?? '-'),
              _buildDetailRow('Department', user.departement ?? '-'),
              _buildDetailRow('Position', user.posisi ?? '-'),
              _buildDetailRow('Client', user.client ?? '-'),
            ]),

            const SizedBox(height: 16),

            // Additional Information
            _buildSection('Additional Information', [
              _buildDetailRow('BPJS No', user.no_bpjs ?? '-'),
              _buildDetailRow('JMO No', user.no_jmo ?? '-'),
              _buildDetailRow('Device', user.device ?? '-'),
            ]),

            const SizedBox(height: 16),

            // Timestamps
            _buildSection('Timestamps', [
              _buildDetailRow('Created At', user.createdAt.toString().split('.')[0]),
              _buildDetailRow('Updated At', user.updatedAt.toString().split('.')[0]),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              userController.deleteUser(user.id);
              Get.back();
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}