class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;

  UserModel(
    this.id,
    this.name,
    this.email,
    this.avatarUrl,
  );

  UserModel.fromMap(this.id, Map<String, dynamic> map)
      : name = map['name'],
        email = map['email'],
        avatarUrl = map['avatarUrl'];
}
