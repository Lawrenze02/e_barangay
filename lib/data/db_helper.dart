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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT,
        profile_picture TEXT
      )
    ''');

    
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

   
    await db.execute('''
      CREATE TABLE announcements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        created_at TEXT
      )
    ''');
    
    
    await db.insert('users', User(
      name: 'Admin Staff',
      username: 'admin',
      password: 'adminpassword', 
      role: 'admin'
    ).toMap());
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN profile_picture TEXT');
    }
  }

  
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

  Future<int> updateUserImage(int id, String path) async {
    Database db = await database;
    return await db.update(
      'users',
      {'profile_picture': path},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  
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
        where: 'date = ? AND status != ? AND status != ?',
        whereArgs: [date, 'rejected', 'cancelled'] // Update to exclude cancelled too
    );
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<List<Appointment>> getFutureAppointments() async {
    Database db = await database;
    final now = DateTime.now();
    final todayStr = now.toString().split(' ')[0]; // yyyy-mm-dd

    List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'date >= ? AND status != ? AND status != ?',
      whereArgs: [todayStr, 'rejected', 'cancelled'],
      orderBy: 'date ASC, time ASC',
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

  Future<int> cancelAppointment(int id) async {
    return await updateAppointmentStatus(id, 'cancelled');
  }

  
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
