class User {
  final int? id;
  final String name;
  final String username;
  final String password;
  final String role; // 'admin' or 'resident'

  User({
    this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
    );
  }
}
