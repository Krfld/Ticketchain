class UserModel {
  final String id;
  String name;
  final String email;
  String avatarUrl; // .replaceAll("s96-c", "s1024-c");

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

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
      };
}
