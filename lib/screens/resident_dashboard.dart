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
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }

  Future<void> _refreshData() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user != null) {
      final apps = await _dbHelper.getAppointmentsByUserId(user.id!);
      final anns = await _dbHelper.getAnnouncements();
      setState(() {
        _myAppointments = apps;
        _announcements = anns;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.name}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Appointments', icon: Icon(Icons.event)),
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
            child: _myAppointments.isEmpty
              ? const Center(child: Text("No appointments yet."))
              : ListView.builder(
                  itemCount: _myAppointments.length,
                  itemBuilder: (context, index) => AppointmentCard(appointment: _myAppointments[index]),
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
