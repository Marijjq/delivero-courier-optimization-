class UserModel {
  final String name;
  final String email;
  final String? phone;
  final String? vehicle;
  final String? avatar;
  final bool isOnline;

  UserModel({
    required this.name,
    required this.email,
    this.phone,
    this.vehicle,
    this.avatar,
    this.isOnline = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      vehicle: json['vehicle'],
      avatar: json['avatar'],
      isOnline: json['is_online'] ?? false,
    );
  }
}
