import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/announcement_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'barangay_scheduler.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users Table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT
      )
    ''');

    // Appointments Table
    await db.execute('''
      CREATE TABLE appointments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        service_type TEXT,
        date TEXT,
        time TEXT,
        status TEXT,
        details TEXT,
        description TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');

    // Announcements Table
    await db.execute('''
      CREATE TABLE announcements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        created_at TEXT
      )
    ''');
    
    // Seed Default Admin
    await db.insert('users', User(
      name: 'Admin Staff',
      username: 'admin',
      password: 'adminpassword', // In production, hash this
      role: 'admin'
    ).toMap());
  }

  // User Helpers
  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String username, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
  
  Future<User?> getUserById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Appointment Helpers
  Future<int> insertAppointment(Appointment appointment) async {
    Database db = await database;
    return await db.insert('appointments', appointment.toMap());
  }

  Future<List<Appointment>> getAppointmentsByUserId(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, time DESC',
    );
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }
  
  Future<List<Appointment>> getAllAppointments() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('appointments', orderBy: 'date DESC, time DESC');
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<List<Appointment>> getAppointmentsForDate(String date) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
        'appointments',
        where: 'date = ? AND status != ?',
        whereArgs: [date, 'rejected'] // Don't count rejected apps as blocking
    );
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<int> updateAppointmentStatus(int id, String status) async {
    Database db = await database;
    return await db.update(
      'appointments',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Announcement Helpers
  Future<int> insertAnnouncement(Announcement announcement) async {
    Database db = await database;
    return await db.insert('announcements', announcement.toMap());
  }

  Future<List<Announcement>> getAnnouncements() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('announcements', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => Announcement.fromMap(maps[i]));
  }
  
  Future<int> deleteAnnouncement(int id) async {
    Database db = await database;
    return await db.delete('announcements', where: 'id = ?', whereArgs: [id]);
  }
}
