class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  // Convert Firestore doc → Model
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }

  // Convert Model → Map (Firestore save)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }
}
