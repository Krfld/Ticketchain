class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatar;

  UserModel(
    this.id,
    this.name,
    this.email,
    this.avatar,
  );

  UserModel.fromMap(this.id, Map<String, dynamic> map)
      : name = map['name'],
        email = map['email'],
        avatar = map['avatar'];

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'avatar': avatar,
      };
}
