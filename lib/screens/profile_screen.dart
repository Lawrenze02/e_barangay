import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../data/db_helper.dart';
import '../models/appointment_model.dart';
import '../widgets/appointment_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Appointment> _history = [];
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user != null) {
      final apps = await _dbHelper.getAppointmentsByUserId(user.id!);
      setState(() {
        // History: completed, rejected, cancelled
        _history = apps.where((a) => ['completed', 'rejected', 'cancelled'].contains(a.status.toLowerCase())).toList();
        _imagePath = user.profilePicture;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user != null) {
        await _dbHelper.updateUserImage(user.id!, pickedFile.path);
        setState(() {
          _imagePath = pickedFile.path;
        });
        // Update auth service
        final updatedUser = await _dbHelper.getUserById(user.id!);
        if (updatedUser != null && mounted) {
          Provider.of<AuthService>(context, listen: false).setUser(updatedUser);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: user == null 
        ? const Center(child: Text("Not logged in"))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _imagePath != null && File(_imagePath!).existsSync()
                          ? FileImage(File(_imagePath!))
                          : null,
                        backgroundColor: Colors.blueAccent,
                        child: _imagePath == null
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  "@${user.username}",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text("Role"),
                  subtitle: Text(user.role.toUpperCase()),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("Account ID"),
                  subtitle: Text("#${user.id}"),
                ),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.history, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "Appointment History",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _history.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No previous appointments.", style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _history.length,
                      itemBuilder: (context, index) => AppointmentCard(appointment: _history[index]),
                    ),
              ],
            ),
          ),
    );
  }
}
