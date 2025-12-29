import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/appointment_model.dart';
import '../models/announcement_model.dart';
import '../data/db_helper.dart';
import '../widgets/appointment_card.dart';
import '../widgets/announcement_card.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DBHelper _dbHelper = DBHelper();
  List<Appointment> _allAppointments = [];
  List<Announcement> _announcements = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }

  Future<void> _refreshData() async {
    final apps = await _dbHelper.getAllAppointments();
    final anns = await _dbHelper.getAnnouncements();
    setState(() {
      _allAppointments = apps;
      _announcements = anns;
    });
  }

  void _showAppointmentActions(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Appointment #${appointment.id}'),
        content: Text('Service: ${appointment.serviceType}\nUser ID: ${appointment.userId}\n\nCurrent Status: ${appointment.status}'),
        actions: [
          if (appointment.status == 'pending')
            TextButton(
              onPressed: () => _updateStatus(appointment.id!, 'approved'),
              child: const Text('Approve', style: TextStyle(color: Colors.green)),
            ),
          if (appointment.status != 'rejected' && appointment.status != 'completed')
            TextButton(
              onPressed: () => _updateStatus(appointment.id!, 'rejected'),
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),
           if (appointment.status == 'approved')
            TextButton(
              onPressed: () => _updateStatus(appointment.id!, 'completed'),
              child: const Text('Complete', style: TextStyle(color: Colors.blue)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _updateStatus(int id, String status) async {
    Navigator.pop(context);
    await _dbHelper.updateAppointmentStatus(id, status);
    _refreshData();
  }

  void _showCreateAnnouncementDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Post Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content'), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                final announcement = Announcement(
                  title: titleController.text,
                  content: contentController.text,
                  createdAt: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                );
                await _dbHelper.insertAnnouncement(announcement);
                Navigator.pop(context);
                _refreshData();
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
  
  void _deleteAnnouncement(int id) async {
    await _dbHelper.deleteAnnouncement(id);
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
         bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Appointments', icon: Icon(Icons.list)),
            Tab(text: 'Announcements', icon: Icon(Icons.campaign)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthService>(context, listen: false).logout(),
          )
        ],
      ),
       body: TabBarView(
        controller: _tabController,
        children: [
          // Appointments Tab
          RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              itemCount: _allAppointments.length,
              itemBuilder: (context, index) {
                final app = _allAppointments[index];
                return GestureDetector(
                  onTap: () => _showAppointmentActions(app),
                  child: AppointmentCard(appointment: app),
                );
              },
            ),
          ),
          // Announcements Tab
          RefreshIndicator(
            onRefresh: _refreshData,
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: _announcements.length,
                  itemBuilder: (context, index) {
                    final ann = _announcements[index];
                    return InkWell(
                      onLongPress: () => _deleteAnnouncement(ann.id!),
                      child: AnnouncementCard(announcement: ann),
                    );
                  },
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _showCreateAnnouncementDialog,
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
