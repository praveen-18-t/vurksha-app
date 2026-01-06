class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String profilePictureUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profilePictureUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone'] as String? ?? '',
      profilePictureUrl: json['profilePicture'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'name': name,
      'email': email,
      'phone': phoneNumber,
      'profilePicture': profilePictureUrl,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}
