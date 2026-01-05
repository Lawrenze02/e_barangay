import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/announcement_model.dart';
import '../data/db_helper.dart';
import '../widgets/appointment_card.dart';
import '../widgets/announcement_card.dart';
import 'appointment_request_screen.dart';
import 'profile_screen.dart';
import 'queue_screen.dart';

class ResidentDashboard extends StatefulWidget {
  const ResidentDashboard({super.key});

  @override
  State<ResidentDashboard> createState() => _ResidentDashboardState();
}

class _ResidentDashboardState extends State<ResidentDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DBHelper _dbHelper = DBHelper();
  List<Appointment> _myAppointments = [];
  List<Announcement> _announcements = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Changed to 3 tabs
    _refreshData();
  }

  Future<void> _refreshData() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user != null) {
      final apps = await _dbHelper.getAppointmentsByUserId(user.id!);
      final anns = await _dbHelper.getAnnouncements();
      setState(() {
        // Filter: Show only Pending or Approved in Dashboard
        _myAppointments = apps.where((a) => ['pending', 'approved'].contains(a.status.toLowerCase())).toList();
        _announcements = anns;
      });
    }
  }

  Future<void> _cancelAppointment(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Appointment?"),
        content: const Text("Are you sure you want to cancel this request?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.cancelAppointment(id);
      _refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Appointment cancelled.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthService>(context, listen: false).logout(),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Apps.', icon: Icon(Icons.event)),
            Tab(text: 'Updates', icon: Icon(Icons.campaign)),
            Tab(text: 'Queue', icon: Icon(Icons.list_alt)), // New Tab
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Appointments Tab (Active Only)
          RefreshIndicator(
            onRefresh: _refreshData,
            child: _myAppointments.isEmpty
              ? const Center(child: Text("No active appointments."))
              : ListView.builder(
                  itemCount: _myAppointments.length,
                  itemBuilder: (context, index) => AppointmentCard(
                    appointment: _myAppointments[index],
                    onCancel: _myAppointments[index].status == 'pending' 
                      ? () => _cancelAppointment(_myAppointments[index].id!) 
                      : null,
                  ),
                ),
          ),
          // Announcements Tab
          RefreshIndicator(
            onRefresh: _refreshData,
            child: _announcements.isEmpty
              ? const Center(child: Text("No announcements."))
              : ListView.builder(
                  itemCount: _announcements.length,
                  itemBuilder: (context, index) => AnnouncementCard(announcement: _announcements[index]),
                ),
          ),
          // Queue Tab
          const QueueScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const AppointmentRequestScreen())
          );
          if (result == true) {
            _refreshData();
          }
        },
        label: const Text("New Appointment"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
