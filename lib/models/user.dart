class User {
  final String username;
  final String password;
  final String? gender;
  final String? dob;

  User({
    required this.username,
    required this.password,
    this.gender,
    this.dob,
  });

  Map<String, String?> toMap() {
    return {
      'username': username,
      'password': password,
      'gender': gender,
      'dob': dob,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'],
      password: map['password'],
      gender: map['gender'],
      dob: map['dob'],
    );
  }
}
